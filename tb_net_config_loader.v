// tb_net_config_loader.v - test suite for net_config_loader + flash_spi.
//
// A behavioral flash returns a 16-byte block on MISO (byte index >= 4). Each
// scenario resets the loader, sets up the flash block + loopback mode, runs to
// boot_done, and checks recovery_active + the MAC/IP bytes written to ip_mem.
//
// Scenarios:
//   A  valid block, no loopback      -> loads MAC/IP (recovery=0, 10 cfg writes)
//   B  loopback connected            -> recovery=1, default kept (0 writes)
//   C  bad magic                     -> default kept (0 writes)
//   D  valid magic, bad checksum     -> default kept (0 writes)
//   E  blank flash (0xFF)            -> default kept (0 writes)
//   F  inverted (wrong) loopback     -> NOT recovery, falls through to flash load

`timescale 1ns / 1ps

module tb_net_config_loader;
    reg clk = 0, rst = 1;
    always #5 clk = ~clk;

    // loopback: 0=disconnected, 1=connected, 2=inverted
    reg [1:0] lb_mode = 0;
    wire lb_drive, lb_test_active;
    wire lb_sense = (lb_mode == 2'd1) ? lb_drive :
                    (lb_mode == 2'd2) ? ~lb_drive : 1'b0;

    wire [6:0]  fs_buf_addr;
    wire [31:0] fs_buf_wdata, fs_buf_rdata;
    wire        fs_buf_we, fs_go, fs_busy;
    wire [9:0]  fs_len;
    wire [3:0]  cfg_a;  wire [7:0] cfg_d;  wire cfg_s;
    wire boot_done, recovery_active;
    wire scs, sck, mosi;  wire miso;

    net_config_loader #(.FLASH_ADDR(24'h3D0000), .LB_PATTERN(8'hB2)) ldr (
        .clk(clk), .rst(rst),
        .lb_drive(lb_drive), .lb_test_active(lb_test_active), .lb_sense(lb_sense),
        .fs_buf_addr(fs_buf_addr), .fs_buf_wdata(fs_buf_wdata), .fs_buf_we(fs_buf_we),
        .fs_len(fs_len), .fs_go(fs_go), .fs_buf_rdata(fs_buf_rdata), .fs_busy(fs_busy),
        .cfg_a(cfg_a), .cfg_d(cfg_d), .cfg_s(cfg_s),
        .boot_done(boot_done), .recovery_active(recovery_active)
    );

    flash_spi #(.CLK_DIV(8'd2)) fs (
        .clk(clk), .rst(rst),
        .buf_addr(fs_buf_addr), .buf_wdata(fs_buf_wdata), .buf_we(fs_buf_we),
        .buf_rdata(fs_buf_rdata), .len(fs_len), .go(fs_go), .busy(fs_busy),
        .spi_scs(scs), .spi_sck(sck), .spi_sdo(mosi), .spi_sdi(miso)
    );

    // ---- behavioral flash: emit block[] on MISO for byte index >= 4 ----
    reg [7:0] block [0:15];
    integer nbit = 0, fcount = 0;
    reg [7:0] miso_byte = 8'hFF;
    reg [2:0] miso_bit = 7;
    assign miso = miso_byte[miso_bit];

    function [7:0] outbyte(input integer n);
        outbyte = (n < 4) ? 8'hFF : block[n-4];
    endfunction

    always @(negedge scs) begin
        nbit = 0; fcount = 0; miso_bit = 7; miso_byte = outbyte(0);
    end
    always @(posedge sck) if (!scs) begin       // count clocked bits (MOSI ignored)
        nbit = nbit + 1;
    end
    // mode-3: present the next sample-bit on each falling edge
    always @(negedge sck) if (!scs) begin
        miso_byte = outbyte(fcount / 8);
        miso_bit  = 7 - (fcount % 8);
        fcount = fcount + 1;
    end

    // ---- capture cfg writes ----
    reg [7:0] cfg_seen [0:15];
    integer cfg_n = 0;
    always @(posedge clk) if (cfg_s) begin
        cfg_seen[cfg_a] = cfg_d;
        if (cfg_a + 1 > cfg_n) cfg_n = cfg_a + 1;
    end

    integer k, errors = 0;
    reg [15:0] cks;

    task fill_valid;
        begin
            block[0]=8'h4E; block[1]=8'h43; block[2]=8'h46; block[3]=8'h31;
            block[4]=8'hAA; block[5]=8'h00; block[6]=8'h55; block[7]=8'h00;
            block[8]=8'h01; block[9]=8'h23;
            block[10]=8'hC0; block[11]=8'hA8; block[12]=8'h07; block[13]=8'h8C;
            cks = 0; for (k=0;k<14;k=k+1) cks = cks + block[k];
            block[14]=cks[7:0]; block[15]=cks[15:8];
        end
    endtask

    task fill_blank; begin for (k=0;k<16;k=k+1) block[k]=8'hFF; end endtask

    task run_loader;
        begin
            cfg_n = 0;
            @(negedge clk); rst = 1;
            repeat (4) @(negedge clk); rst = 0;
            wait (boot_done); repeat (4) @(posedge clk);
        end
    endtask

    // check recovery flag and number of cfg writes; tag is for the message
    task expect_rc(input integer want_rec, input integer want_n, input [63:0] tag);
        begin
            if (recovery_active !== want_rec[0]) begin
                $display("  FAIL %0s: recovery_active=%b want %0d", tag, recovery_active, want_rec);
                errors = errors + 1;
            end else if (cfg_n != want_n) begin
                $display("  FAIL %0s: cfg writes=%0d want %0d", tag, cfg_n, want_n);
                errors = errors + 1;
            end else
                $display("  PASS %0s (recovery=%0d, writes=%0d)", tag, want_rec, want_n);
        end
    endtask

    task check_bytes;
        begin
            for (k=0;k<10;k=k+1)
                if (cfg_seen[k] !== block[k+4]) begin
                    $display("  FAIL bytes: ip_mem[%0d]=0x%02x want 0x%02x", k, cfg_seen[k], block[k+4]);
                    errors = errors + 1;
                end
        end
    endtask

    initial begin
        // A: valid block, no loopback -> loads MAC/IP
        fill_valid; lb_mode = 0; run_loader;
        expect_rc(0, 10, "A:valid"); check_bytes;

        // B: loopback connected -> recovery, default kept
        fill_valid; lb_mode = 1; run_loader;
        expect_rc(1, 0, "B:recov");

        // C: bad magic -> default kept
        fill_valid; block[0] = 8'hFF; lb_mode = 0; run_loader;
        expect_rc(0, 0, "C:magic");

        // D: valid magic, bad checksum -> default kept
        fill_valid; block[14] = block[14] ^ 8'hFF; lb_mode = 0; run_loader;
        expect_rc(0, 0, "D:cksum");

        // E: blank flash -> default kept
        fill_blank; lb_mode = 0; run_loader;
        expect_rc(0, 0, "E:blank");

        // F: inverted (wrong) loopback -> NOT recovery, loads from valid flash
        fill_valid; lb_mode = 2; run_loader;
        expect_rc(0, 10, "F:badlb"); check_bytes;

        if (errors == 0) $display("ALL NET-CONFIG-LOADER TESTS PASS");
        else $display("RESULT: %0d error(s)", errors);
        $finish;
    end

    initial begin #6000000; $display("FAIL: timeout"); $finish; end
endmodule
