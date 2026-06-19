// tb_flash_spi.v - functional test suite for flash_spi.v
//
// A behavioral SPI mode-0 slave captures MOSI bytes and returns a known pattern
// (0xA0 + byte index) on MISO. The do_xfer task runs one CS-framed transfer of
// a given length and checks both directions:
//   - MOSI bytes the slave received == the TX pattern we loaded
//   - RX bytes captured back into the buffer == the slave's 0xA0+index pattern
//
// Cases: 1-byte (min), 5-byte (crosses a word boundary), 256-byte, 512-byte
// (full buffer), and two back-to-back transfers (CS re-framing + handshake).

`timescale 1ns / 1ps

module tb_flash_spi;
    reg         clk = 0, rst = 1;
    reg  [6:0]  buf_addr = 0;
    reg  [31:0] buf_wdata = 0;
    reg         buf_we = 0;
    wire [31:0] buf_rdata;
    reg  [9:0]  len = 0;
    reg         go = 0;
    wire        busy, scs, sck, mosi;
    wire        miso;

    flash_spi #(.CLK_DIV(8'd2)) dut (
        .clk(clk), .rst(rst),
        .buf_addr(buf_addr), .buf_wdata(buf_wdata), .buf_we(buf_we), .buf_rdata(buf_rdata),
        .len(len), .go(go), .busy(busy),
        .spi_scs(scs), .spi_sck(sck), .spi_sdo(mosi), .spi_sdi(miso)
    );

    always #5 clk = ~clk;

    // ---- behavioral SPI mode-0 slave ----
    reg [7:0]  recv [0:511];
    integer    rcount = 0, nbit = 0, fcount = 0;
    reg [7:0]  cur_mosi = 0;
    reg [7:0]  miso_byte = 8'hA0;
    reg [2:0]  miso_bit = 7;
    assign miso = miso_byte[miso_bit];

    always @(negedge scs) begin
        nbit = 0; rcount = 0; cur_mosi = 0; fcount = 0;
        miso_byte = 8'hA0; miso_bit = 7;
    end
    always @(posedge sck) if (!scs) begin       // sample MOSI on the rising edge
        cur_mosi = {cur_mosi[6:0], mosi};
        nbit = nbit + 1;
        if ((nbit % 8) == 0) begin recv[rcount] = cur_mosi; rcount = rcount + 1; end
    end
    // mode-3: on each falling edge, present the bit to be sampled at the next
    // rising edge. fcount = number of sample-bits presented so far.
    always @(negedge sck) if (!scs) begin
        miso_byte = 8'hA0 + (fcount / 8);
        miso_bit  = 7 - (fcount % 8);
        fcount = fcount + 1;
    end

    integer errors = 0;

    function [7:0] tx_pat(input integer i);
        tx_pat = (i * 3 + 1) & 8'hFF;
    endfunction

    task do_xfer(input [9:0] n);
        integer i, w, nwords, e0;
        reg [7:0] got;
        begin
            e0 = errors;
            nwords = (n + 3) / 4;
            for (w = 0; w < nwords; w = w + 1) begin
                @(negedge clk);
                buf_addr  = w[6:0];
                buf_wdata = {tx_pat(4*w+3), tx_pat(4*w+2), tx_pat(4*w+1), tx_pat(4*w+0)};
                buf_we    = 1;
                @(negedge clk); buf_we = 0;
            end
            @(negedge clk); len = n;
            @(negedge clk); go = 1; @(negedge clk); go = 0;
            wait (busy == 1'b1); wait (busy == 1'b0);
            repeat (4) @(posedge clk);
            for (i = 0; i < n; i = i + 1)
                if (recv[i] !== tx_pat(i)) begin
                    $display("  FAIL n=%0d MOSI[%0d]=0x%02x want 0x%02x", n, i, recv[i], tx_pat(i));
                    errors = errors + 1;
                end
            for (i = 0; i < n; i = i + 1) begin
                buf_addr = i / 4;
                @(posedge clk); @(posedge clk);
                got = buf_rdata[8*(i % 4) +: 8];
                if (got !== ((8'hA0 + i) & 8'hFF)) begin
                    $display("  FAIL n=%0d RX[%0d]=0x%02x want 0x%02x", n, i, got, (8'hA0+i)&8'hFF);
                    errors = errors + 1;
                end
            end
            if (errors == e0) $display("  PASS A: flash_spi %0d-byte transfer", n);
        end
    endtask

    initial begin
        repeat (4) @(negedge clk); rst = 0; @(negedge clk);

        do_xfer(10'd1);     // A3 min
        do_xfer(10'd5);     // crosses a word boundary
        do_xfer(10'd256);   // A1 partial
        do_xfer(10'd512);   // A1 full buffer

        // A2: two back-to-back transfers (CS must re-frame each time)
        do_xfer(10'd8);
        do_xfer(10'd12);

        if (errors == 0) $display("ALL FLASH_SPI TESTS PASS");
        else $display("RESULT: %0d error(s)", errors);
        $finish;
    end

    initial begin #20000000; $display("FAIL: timeout"); $finish; end
endmodule
