///////////////////////////////////////////////////////////////////////////////
// flash_spi.v
//
// Dumb full-duplex SPI transport for the on-board M25P32 configuration flash.
//
// This module has NO knowledge of M25P32 commands. It exposes a byte buffer and
// a "shift N bytes" engine: the host (Python) fills the buffer with a complete
// SPI transaction (command + address + payload, plus dummy bytes where it wants
// to read), sets the byte count, and pulses GO. The engine asserts chip-select,
// clocks the whole buffer out MOSI while capturing MISO back into the SAME buffer
// (in place), then deasserts chip-select. The host reads the buffer back to get
// the response. All flash protocol (READ/WREN/SE/PP/RDSR) lives in software.
//
// Buffer is 512 bytes = 128 x 32-bit words. Byte i lives in word (i>>2),
// little-endian within the word: byte 0 -> bits [7:0], byte 1 -> [15:8], etc.
// Bytes are shifted in ascending index order, MSB-first within each byte.
//
// SPI MODE 3 (CPOL=1, CPHA=1): SCK idles HIGH; MOSI is driven on the falling
// edge and both master and slave sample on the rising edge; CS is deasserted
// with SCK stable HIGH in a separate state. This matches the proven NIST
// M25P32_CONFIG.v timing -- the M25P32 PAGE PROGRAM data phase is rejected by
// some silicon revisions if CS rises while SCK is low (mode 0) or off a clean
// byte boundary.
//
///////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module flash_spi #(
    parameter [7:0] CLK_DIV = 8'd2  // half-bit period = CLK_DIV input clocks
                                    // (clk_12p5mhz / (2*2) = ~3.1 MHz SCK)
)(
    input  wire        clk,
    input  wire        rst,

    // Buffer access port (32-bit word, 128 words). Single port shared by the
    // host for read/write; only valid while !busy.
    input  wire [6:0]  buf_addr,
    input  wire [31:0] buf_wdata,
    input  wire        buf_we,
    output wire [31:0] buf_rdata,

    // Control
    input  wire [9:0]  len,    // number of bytes to transfer (1..512)
    input  wire        go,     // 1-cycle pulse to start a transfer
    output reg         busy,

    // Diagnostic: count of SCK rising edges emitted in the last transfer
    // (should equal 8*len). Lets the host verify the multiple-of-8 clock count
    // the M25P32 requires for PAGE PROGRAM, with no external logic analyzer.
    output reg [15:0]  sck_count,

    // SPI to flash. The output registers are forced into the I/O block (IOB)
    // so SCK/MOSI/CS are clocked right at the pad: aligned to each other,
    // controlled clock-to-output, and glitch-free (no fabric routing between
    // the flip-flop and the pin). The M25P32 counts SCK pulses for PROGRAM/
    // ERASE, so a fabric-routed clock with skew/glitches can corrupt it.
    (* IOB = "TRUE" *) output reg spi_scs,  // chip select, active low
    (* IOB = "TRUE" *) output reg spi_sck,  // serial clock (idles high, mode 3)
    (* IOB = "TRUE" *) output reg spi_sdo,  // MOSI (FPGA -> flash)
    input  wire        spi_sdi   // MISO (flash -> FPGA)
);

// Register MISO in the input IOB flip-flop for clean, deterministic input
// timing (sampled right at the pad, no fabric delay/skew).
(* IOB = "TRUE" *) reg spi_sdi_r;
always @(posedge clk) spi_sdi_r <= spi_sdi;

// Transfer buffer: 128 x 32-bit words (512 bytes)
reg [31:0] mem [0:127];

// FSM state
localparam S_IDLE  = 3'd0;
localparam S_START = 3'd1;  // CS asserted, SCK idle-high (CS->clock setup)
localparam S_LOW   = 3'd2;  // SCK low (falling edge): drive MOSI bit
localparam S_HIGH  = 3'd3;  // SCK high (rising edge): sample MISO
localparam S_END   = 3'd4;  // last bit done, SCK idle-high (clock->CS setup)
localparam S_RAISE = 3'd5;  // deassert CS with SCK stable high

reg [2:0]  state;
reg [9:0]  byte_idx;   // current byte index (0..len-1)
reg [2:0]  bit_idx;    // current bit within byte (7 down to 0)
reg [7:0]  tx_sh;      // outgoing shift register (MSB first)
reg [6:0]  rx_sh;      // incoming shift register (holds first 7 bits of a byte)

// Byte addressing for the byte currently being processed
wire [6:0]  cur_word = byte_idx[8:2];
wire [1:0]  cur_sub  = byte_idx[1:0];

// TX word cache. mem is read ONLY as full 32-bit words: an 8-bit slice read
// like mem[w][8*sub +: 8] leaves 24 of each read port's output bits driving no
// load, which produces dozens of (benign) PhysDesignRules:367 warnings. Instead
// the outgoing byte is muxed from a cached word register, and mem is re-read
// only when the transfer crosses into a new word.
reg  [31:0] tx_word;                     // cached word currently shifting out
wire [8:0]  nxt_idx       = byte_idx[8:0] + 9'd1;
wire [6:0]  nxt_word      = nxt_idx[8:2];
wire [1:0]  nxt_sub       = nxt_idx[1:0];
wire [31:0] mem_word0     = mem[7'd0];     // first word, loaded at transfer start
wire [31:0] mem_word_nx   = mem[nxt_word]; // next word, loaded at a word boundary

// SPI clock divider tick (only runs during a transfer)
reg [7:0] div_cnt;
wire tick = (div_cnt == CLK_DIV - 8'd1);
always @(posedge clk) begin
    if (rst || !busy)
        div_cnt <= 8'd0;
    else if (tick)
        div_cnt <= 8'd0;
    else
        div_cnt <= div_cnt + 8'd1;
end

// RX accumulation. Received bytes are packed into a 32-bit word register and
// the WHOLE word is written to mem -- never individual byte lanes. Byte-lane
// writes into the 32-bit-wide distributed RAM do NOT synthesize correctly on
// Spartan-6: XST splits `mem` into per-lane RAMs and leaves many nodes
// unconnected (48 PhysDesignRules:367 warnings), which silently corrupts
// multi-byte reads on hardware (only the last lane written to a word survives)
// while simulating perfectly. Full-word writes keep `mem` a single clean RAM.
reg        rx_we;        // full-word write strobe
reg [6:0]  rx_word;      // destination word
reg [31:0] rx_wdata;     // word to write
reg [31:0] rx_acc;       // running accumulator for the word in progress

// rx_acc with the just-completed byte packed into its lane (combinational), and
// the assembled byte itself. Built with explicit per-lane muxes so XST infers
// no byte-lane RAM write.
wire [7:0]  rx_new_byte = {rx_sh[6:0], spi_sdi_r};
wire [31:0] acc_n = {
    (cur_sub == 2'd3) ? rx_new_byte : rx_acc[31:24],
    (cur_sub == 2'd2) ? rx_new_byte : rx_acc[23:16],
    (cur_sub == 2'd1) ? rx_new_byte : rx_acc[15:8],
    (cur_sub == 2'd0) ? rx_new_byte : rx_acc[7:0]
};

// Single write port into mem: RX writeback (during transfer) has priority over
// host buffer writes (only allowed while idle). Both are full 32-bit words.
always @(posedge clk) begin
    if (rx_we)
        mem[rx_word] <= rx_wdata;
    else if (buf_we && !busy)
        mem[buf_addr] <= buf_wdata;
end

assign buf_rdata = mem[buf_addr];

// Diagnostic: count SCK rising edges actually emitted during a transfer.
// Reset when a transfer starts; the final value persists for the host to read.
reg sck_d;
always @(posedge clk) begin
    if (rst) begin
        sck_d     <= 1'b1;   // mode 3 idle high
        sck_count <= 16'd0;
    end else begin
        sck_d <= spi_sck;
        if (state == S_IDLE && go && len != 10'd0)
            sck_count <= 16'd0;
        else if (spi_sck && !sck_d)            // rising edge of SCK
            sck_count <= sck_count + 16'd1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        state    <= S_IDLE;
        busy     <= 1'b0;
        spi_scs  <= 1'b1;
        spi_sck  <= 1'b1;   // mode 3: idle high
        spi_sdo  <= 1'b1;
        rx_we    <= 1'b0;
        byte_idx <= 10'd0;
        bit_idx  <= 3'd0;
    end else begin
        rx_we <= 1'b0;  // default: single-cycle writeback strobe

        case (state)
            S_IDLE: begin
                spi_sck <= 1'b1;   // idle high
                spi_sdo <= 1'b1;
                if (go && len != 10'd0) begin
                    busy     <= 1'b1;
                    spi_scs  <= 1'b0;     // assert CS (SCK stays idle-high)
                    byte_idx <= 10'd0;
                    bit_idx  <= 3'd7;
                    tx_word  <= mem_word0;
                    tx_sh    <= mem_word0[7:0];
                    state    <= S_START;
                end else begin
                    busy    <= 1'b0;
                    spi_scs <= 1'b1;
                end
            end

            // Hold SCK high with CS asserted for one half-bit (CS->clock setup)
            S_START: begin
                spi_sck <= 1'b1;
                if (tick)
                    state <= S_LOW;
            end

            // SCK low (falling edge): present the MOSI bit
            S_LOW: begin
                spi_sck <= 1'b0;
                spi_sdo <= tx_sh[7];
                if (tick)
                    state <= S_HIGH;
            end

            // SCK high (rising edge): flash samples MOSI; we sample MISO
            S_HIGH: begin
                spi_sck <= 1'b1;
                if (tick) begin
                    rx_sh <= {rx_sh[5:0], spi_sdi_r};
                    tx_sh <= {tx_sh[6:0], 1'b0};
                    if (bit_idx == 3'd0) begin
                        // Byte complete: pack the received byte into its lane of
                        // the running word accumulator, and flush the whole word
                        // to mem at the top lane (sub 3) or on the final byte.
                        rx_acc <= acc_n;
                        if (cur_sub == 2'd3 || byte_idx == len - 10'd1) begin
                            rx_we    <= 1'b1;
                            rx_word  <= cur_word;
                            rx_wdata <= acc_n;
                        end
                        if (byte_idx == len - 10'd1) begin
                            state <= S_END;
                        end else begin
                            byte_idx <= byte_idx + 10'd1;
                            bit_idx  <= 3'd7;
                            // Reload the word cache only when crossing into a new
                            // word; otherwise mux the next byte from the cache.
                            if (nxt_sub == 2'd0) begin
                                tx_word <= mem_word_nx;
                                tx_sh   <= mem_word_nx[7:0];
                            end else begin
                                tx_sh   <= tx_word[8*nxt_sub +: 8];
                            end
                            state    <= S_LOW;
                        end
                    end else begin
                        bit_idx <= bit_idx - 3'd1;
                        state   <= S_LOW;
                    end
                end
            end

            // Last bit sampled on the rising edge; hold SCK high before CS rise
            S_END: begin
                spi_sck <= 1'b1;
                if (tick)
                    state <= S_RAISE;
            end

            // Deassert CS with SCK stable high (clean mode-3 framing)
            S_RAISE: begin
                spi_scs <= 1'b1;
                spi_sdo <= 1'b1;
                busy    <= 1'b0;
                state   <= S_IDLE;
            end

            default: state <= S_IDLE;
        endcase
    end
end

endmodule
