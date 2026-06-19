///////////////////////////////////////////////////////////////////////////////
// net_config_loader.v
//
// Boot-time loader for the FPGA's own network identity (MAC + IP).
//
// The board's MAC/IP cannot be configured over the network (the host reaches
// the board *using* that address), so they must be loaded autonomously at boot.
// Right after reset this module:
//
//   1. Runs a hardware RECOVERY test: drives a known pattern on a loopback
//      output (DOUT1) and checks it reads back on a loopback input (DIN1). If
//      the two are jumpered together the test passes -> recovery requested.
//   2. If recovery is NOT requested, reads a 16-byte config block from flash
//      (magic + MAC + IP + checksum) by driving the shared flash_spi engine,
//      validates it, and writes the 10 MAC/IP bytes into the Badger stack's
//      ip_mem via the config_a/config_d/config_s interface.
//   3. If recovery IS requested, or the flash block is blank/invalid, it writes
//      nothing -> the Badger stack keeps its compile-time default MAC/IP, which
//      is the known recovery address.
//
// After it finishes it asserts boot_done and idles; the host (lbus) then owns
// the flash_spi engine. All logic runs in the flash_spi / lbus clock domain.
//
// Flash block layout (16 bytes at FLASH_ADDR):
//   [0..3]   magic = "NCF1" (0x4E 0x43 0x46 0x31)
//   [4..9]   MAC, byte 0 (OUI MSB) first
//   [10..13] IP, MSB first
//   [14..15] checksum = (sum of bytes [0..13]) & 0xFFFF, little-endian
//
///////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module net_config_loader #(
    parameter [23:0] FLASH_ADDR = 24'h3D0000,  // flash byte address of net config (sector 61)
    parameter [7:0]  LB_PATTERN = 8'hB2        // loopback recovery test pattern
)(
    input  wire        clk,
    input  wire        rst,

    // Loopback recovery test (DOUT1 driven, DIN1 sensed)
    output reg         lb_drive,        // value to drive on DOUT1 during the test
    output reg         lb_test_active,  // high while the test owns DOUT1
    input  wire        lb_sense,        // raw DIN1

    // flash_spi control port (driven only while !boot_done)
    output reg  [6:0]  fs_buf_addr,
    output reg  [31:0] fs_buf_wdata,
    output reg         fs_buf_we,
    output reg  [9:0]  fs_len,
    output reg         fs_go,
    input  wire [31:0] fs_buf_rdata,
    input  wire        fs_busy,

    // Badger MAC/IP config write interface (config_clk = clk)
    output reg  [3:0]  cfg_a,
    output reg  [7:0]  cfg_d,
    output reg         cfg_s,

    output reg         boot_done,       // 1 = loader finished, flash_spi released to host
    output reg         recovery_active  // 1 = recovery loopback detected (default addr forced)
);

// Synchronize the loopback sense input
reg lb_meta, lb_sync;
always @(posedge clk) begin
    lb_meta <= lb_sense;
    lb_sync <= lb_meta;
end

localparam [5:0] SETTLE = 6'd40;  // cycles to let DOUT1->DIN1 settle per loopback bit

// FSM states
localparam S_RST     = 4'd0;
localparam S_LB      = 4'd1;   // drive/sense one loopback bit
localparam S_LB_CHK  = 4'd2;
localparam S_DECIDE  = 4'd3;
localparam S_FILL    = 4'd4;   // write read command into flash buffer
localparam S_GO      = 4'd5;
localparam S_WSTART  = 4'd6;   // wait for flash_spi to start (busy high)
localparam S_WDONE   = 4'd7;   // wait for flash_spi to finish (busy low)
localparam S_READ    = 4'd8;   // set buffer word address
localparam S_READ_RD = 4'd9;   // sample byte, accumulate / latch
localparam S_APPLY   = 4'd10;  // write latched MAC/IP bytes to ip_mem
localparam S_DONE    = 4'd11;

reg [3:0]  state;
reg [5:0]  settle_cnt;
reg [2:0]  lb_idx;        // loopback bit index 0..7
reg        lb_ok;         // loopback all-bits-matched so far

reg [4:0]  byte_idx;      // 0..15 over the config block (validate); 0..9 (apply)
reg [15:0] sum;           // running checksum of bytes [0..13]
reg [15:0] stored_cksum;  // checksum read from flash
reg        magic_ok;
reg [7:0]  netbytes [0:9];// latched MAC(0..5) + IP(6..9)

// flash read command for FLASH_ADDR: byte0=0x03(READ), byte1..3 = addr MSB..LSB
// buffer word0 (little-endian, byte0 in [7:0]) = {addr[7:0], addr[15:8], addr[23:16], 0x03}
wire [31:0] cmd_word0 = {FLASH_ADDR[7:0], FLASH_ADDR[15:8], FLASH_ADDR[23:16], 8'h03};

// Config-block byte `byte_idx` lives at flash buffer byte (4 + byte_idx).
wire [4:0] buf_byte = byte_idx + 5'd4;   // 4..19
wire [6:0] buf_word = {4'd0, buf_byte[4:2]};
wire [1:0] buf_sub  = buf_byte[1:0];
wire [7:0] cur_data = fs_buf_rdata[8*buf_sub +: 8];
wire [3:0] nb_idx   = byte_idx[3:0] - 4'd4;  // MAC/IP byte index (valid for byte_idx 4..13)

// Expected magic byte for index 0..3
function [7:0] magic_byte(input [1:0] i);
    case (i)
        2'd0: magic_byte = 8'h4E; // 'N'
        2'd1: magic_byte = 8'h43; // 'C'
        2'd2: magic_byte = 8'h46; // 'F'
        2'd3: magic_byte = 8'h31; // '1'
    endcase
endfunction

always @(posedge clk) begin
    if (rst) begin
        state          <= S_RST;
        boot_done      <= 1'b0;
        recovery_active<= 1'b0;
        lb_drive       <= 1'b0;
        lb_test_active <= 1'b0;
        fs_buf_we      <= 1'b0;
        fs_go          <= 1'b0;
        fs_len         <= 10'd0;
        fs_buf_addr    <= 7'd0;
        fs_buf_wdata   <= 32'd0;
        cfg_s          <= 1'b0;
        cfg_a          <= 4'd0;
        cfg_d          <= 8'd0;
        settle_cnt     <= 6'd0;
        lb_idx         <= 3'd0;
        lb_ok          <= 1'b1;
        byte_idx       <= 5'd0;
        sum            <= 16'd0;
        magic_ok       <= 1'b1;
    end else begin
        // one-shot strobes default low
        fs_buf_we <= 1'b0;
        fs_go     <= 1'b0;
        cfg_s     <= 1'b0;

        case (state)
            S_RST: begin
                lb_test_active <= 1'b1;
                lb_idx     <= 3'd0;
                lb_ok      <= 1'b1;
                settle_cnt <= 6'd0;
                lb_drive   <= LB_PATTERN[7];
                state      <= S_LB;
            end

            // Drive the current loopback bit, wait for it to settle
            S_LB: begin
                lb_drive <= LB_PATTERN[3'd7 - lb_idx];
                if (settle_cnt == SETTLE) begin
                    settle_cnt <= 6'd0;
                    state <= S_LB_CHK;
                end else begin
                    settle_cnt <= settle_cnt + 6'd1;
                end
            end

            S_LB_CHK: begin
                if (lb_sync != LB_PATTERN[3'd7 - lb_idx])
                    lb_ok <= 1'b0;
                if (lb_idx == 3'd7) begin
                    state <= S_DECIDE;
                end else begin
                    lb_idx <= lb_idx + 3'd1;
                    state  <= S_LB;
                end
            end

            S_DECIDE: begin
                lb_test_active <= 1'b0;     // release DOUT1 back to normal
                if (lb_ok) begin
                    recovery_active <= 1'b1; // recovery: keep default MAC/IP
                    state <= S_DONE;
                end else begin
                    byte_idx <= 5'd0;
                    state    <= S_FILL;
                end
            end

            // Write the 20-byte read transaction into the flash buffer:
            // word0 = READ cmd + addr; words 1..4 = 0 (dummy to clock in 16 bytes)
            S_FILL: begin
                fs_buf_we    <= 1'b1;
                fs_buf_addr  <= {2'b0, byte_idx};            // word counter 0..4
                fs_buf_wdata <= (byte_idx == 5'd0) ? cmd_word0 : 32'd0;
                if (byte_idx == 5'd4) begin
                    byte_idx <= 5'd0;
                    state    <= S_GO;
                end else begin
                    byte_idx <= byte_idx + 5'd1;
                end
            end

            S_GO: begin
                fs_len <= 10'd20;   // 4 cmd/addr + 16 data
                fs_go  <= 1'b1;
                state  <= S_WSTART;
            end

            S_WSTART: if (fs_busy) state <= S_WDONE;   // engine has started

            S_WDONE: if (!fs_busy) begin               // transfer complete
                byte_idx <= 5'd0;
                sum      <= 16'd0;
                magic_ok <= 1'b1;
                state    <= S_READ;
            end

            // Read pass: set buffer word address (buf_word is combinational on byte_idx)
            S_READ: begin
                fs_buf_addr <= buf_word;
                state       <= S_READ_RD;
            end

            // Sample the byte (buf_rdata now valid), accumulate / latch
            S_READ_RD: begin
                if (byte_idx < 5'd4) begin
                    if (cur_data != magic_byte(byte_idx[1:0]))
                        magic_ok <= 1'b0;
                end
                if (byte_idx >= 5'd4 && byte_idx <= 5'd13)
                    netbytes[nb_idx] <= cur_data;
                if (byte_idx < 5'd14)
                    sum <= sum + {8'd0, cur_data};
                if (byte_idx == 5'd14)
                    stored_cksum[7:0]  <= cur_data;
                if (byte_idx == 5'd15)
                    stored_cksum[15:8] <= cur_data;

                if (byte_idx == 5'd15) begin
                    byte_idx <= 5'd0;
                    state    <= S_APPLY;
                end else begin
                    byte_idx <= byte_idx + 5'd1;
                    state    <= S_READ;
                end
            end

            // Apply: only if magic + checksum valid; otherwise leave default
            S_APPLY: begin
                if (magic_ok && (sum == stored_cksum)) begin
                    cfg_a <= byte_idx[3:0];
                    cfg_d <= netbytes[byte_idx[3:0]];
                    cfg_s <= 1'b1;
                    if (byte_idx == 5'd9) begin
                        state <= S_DONE;
                    end else begin
                        byte_idx <= byte_idx + 5'd1;
                    end
                end else begin
                    state <= S_DONE;
                end
            end

            S_DONE: boot_done <= 1'b1;

            default: state <= S_DONE;
        endcase
    end
end
endmodule
