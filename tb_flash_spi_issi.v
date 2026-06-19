// tb_flash_spi_issi.v - reproduce the flash_spi MISO misread in simulation.
//
// The original tb_flash_spi.v slave presents MISO combinationally on the SCK
// falling edge (ZERO output delay), so flash_spi passes. Real flash (the ISSI
// IS25LP032 on this board) drives MISO some nanoseconds AFTER the falling edge
// (clock-to-output, tV) plus board round-trip. This testbench models that delay
// and sweeps it, doing an RDID read (0x9F + 3 dummy) and printing the 3 ID bytes
// flash_spi captures vs the true 9D 40 16 -- to see at what delay the engine
// starts losing the early bytes (the hardware symptom was 00 00 16).
//
//   iverilog -g2012 -o /tmp/t.vvp tb_flash_spi_issi.v flash_spi.v && vvp /tmp/t.vvp

`timescale 1ns / 1ps

module tb_flash_spi_issi;
    reg         clk = 0, rst = 1;
    reg  [6:0]  buf_addr = 0;
    reg  [31:0] buf_wdata = 0;
    reg         buf_we = 0;
    wire [31:0] buf_rdata;
    reg  [9:0]  len = 0;
    reg         go = 0;
    wire        busy, scs, sck, mosi;
    wire        miso;

    // MISO output-valid delay from the SCK falling edge (swept by the test)
    real tv = 0.0;

    flash_spi #(.CLK_DIV(8'd2)) dut (
        .clk(clk), .rst(rst),
        .buf_addr(buf_addr), .buf_wdata(buf_wdata), .buf_we(buf_we), .buf_rdata(buf_rdata),
        .len(len), .go(go), .busy(busy),
        .spi_scs(scs), .spi_sck(sck), .spi_sdo(mosi), .spi_sdi(miso)
    );

    always #5 clk = ~clk;     // 100 MHz sim clock -> SCK = 25 MHz, half-bit 20 ns

    // ---- realistic flash read slave: RDID -> 9D 40 16 ----
    reg [7:0] idrom [0:2];
    initial begin idrom[0] = 8'h9D; idrom[1] = 8'h40; idrom[2] = 8'h16; end

    integer fall = 0;
    reg     miso_r = 1'b0;
    assign miso = miso_r;

    always @(negedge scs) begin fall = 0; miso_r = 1'b0; end

    // Flash changes MISO on each SCK falling edge, valid tv ns later. The first
    // 8 falling edges clock in the command (MISO idle); data starts on the 9th.
    integer di;
    always @(negedge sck) if (!scs) begin
        if (fall >= 8) begin
            di = fall - 8;                       // 0-based output bit index
            #(tv) miso_r = idrom[di/8][7 - (di%8)];
        end
        fall = fall + 1;
    end

    // ---- run one RDID transfer and report the captured ID bytes ----
    task rdid_read;
        reg [7:0] b1, b2, b3;
        begin
            // fill buffer word 0 = {dummy, dummy, dummy, 0x9F}
            @(negedge clk); buf_addr = 0; buf_wdata = 32'h0000009F; buf_we = 1;
            @(negedge clk); buf_we = 0;
            @(negedge clk); len = 10'd4;
            @(negedge clk); go = 1; @(negedge clk); go = 0;
            wait (busy == 1'b1); wait (busy == 1'b0);
            repeat (4) @(posedge clk);
            buf_addr = 0; @(posedge clk); @(posedge clk);
            b1 = buf_rdata[15:8];
            b2 = buf_rdata[23:16];
            b3 = buf_rdata[31:24];
            $display("  tv=%4.1f ns : flash_spi read ID = %02X %02X %02X   (true 9D 40 16)%s",
                     tv, b1, b2, b3,
                     (b1===8'h9D && b2===8'h40 && b3===8'h16) ? "  OK" : "  <-- MISREAD");
        end
    endtask

    initial begin
        repeat (4) @(negedge clk); rst = 0; @(negedge clk);
        $display("flash_spi MISO read vs output-valid delay (SCK half-bit = 20 ns):");
        tv = 0.0;  rdid_read();
        tv = 2.0;  rdid_read();
        tv = 5.0;  rdid_read();
        tv = 8.0;  rdid_read();
        tv = 12.0; rdid_read();
        tv = 16.0; rdid_read();
        tv = 19.0; rdid_read();
        $finish;
    end

    initial begin #500000; $display("FAIL: timeout"); $finish; end
endmodule
