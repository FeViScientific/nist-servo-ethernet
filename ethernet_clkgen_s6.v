// Ethernet Clock Generation for Spartan-6 (from 100 MHz system clock)
//
// Generates all Ethernet-related clocks from the 100 MHz board oscillator.
// Used when the FPGA provides the 50 MHz reference clock to the LAN8720A PHY
// (REF_CLK In mode - PHY has no crystal).
//
// PLL_BASE: 100 MHz * 8 = 800 MHz VCO
//   CLKOUT0: 800 / 16 = 50 MHz   (RMII PHY timing + output to PHY)
//   CLKOUT1: 800 / 4  = 200 MHz  (TX ODDR phase control)
//   CLKOUT2: 800 / 64 = 12.5 MHz (GMII clock for Badger stack)
//
module ethernet_clkgen_s6 (
    input  clk_100mhz,      // 100 MHz system clock (already buffered)
    output clk_50mhz,       // 50 MHz RMII clock (phase-shifted 90 deg for RX margin)
    output clk_200mhz,      // 200 MHz for ODDR TX phase control
    output clk_12p5mhz,     // 12.5 MHz GMII clock for Badger
    output locked            // PLL locked indicator
);

`ifdef SIMULATE

// Simulation: derive clocks from 100 MHz
reg [1:0] sim_div4 = 2'd0;
reg [2:0] sim_div8 = 3'd0;
reg sim_50mhz = 0;
reg sim_200mhz = 0;

assign clk_50mhz = sim_50mhz;
assign clk_200mhz = sim_200mhz;
assign clk_12p5mhz = sim_div8[2];
assign locked = 1'b1;

always @(posedge clk_100mhz) sim_50mhz <= ~sim_50mhz;
always #1.25 sim_200mhz = ~sim_200mhz;
always @(posedge clk_50mhz) sim_div4 <= sim_div4 + 1'd1;
always @(posedge clk_50mhz) sim_div8 <= sim_div8 + 1'd1;

`else

wire clk_50mhz_unbuf;
wire clk_200mhz_unbuf;
wire clk_12p5mhz_unbuf;
wire clkfb;
wire pll_locked;

// PLL reset with AUTOMATIC RETRY: a Spartan-6 PLL_BASE with RST tied low comes
// out of config never having been reset and can INTERMITTENTLY fail to lock --
// when it does, LOCKED stays low, the downstream reset never releases, and the
// design "goes quiet". A single reset pulse is not enough (one failed attempt
// and it stays unlocked forever). Instead: while unlocked, assert RST for
// ~2.5 us, then release it for a ~10 ms window to let the PLL lock; if it still
// hasn't locked, pulse RST again -- repeat until LOCKED asserts. Once locked the
// counter clears and RST stays deasserted (no glitching in normal operation).
// clk_100mhz (board oscillator) is free-running, so this runs even while the
// PLL outputs are down.
reg [19:0] pll_rst_cnt = 20'd0;
reg        pll_rst     = 1'b1;
always @(posedge clk_100mhz) begin
    if (pll_locked) begin
        pll_rst_cnt <= 20'd0;
        pll_rst     <= 1'b0;
    end else begin
        pll_rst_cnt <= pll_rst_cnt + 20'd1;
        pll_rst     <= (pll_rst_cnt < 20'd256);  // ~2.5 us reset, then retry window
    end
end

PLL_BASE #(
    .CLKIN_PERIOD(10.0),           // 100 MHz = 10 ns
    .CLKFBOUT_MULT(8),             // 100 MHz * 8 = 800 MHz VCO
    .CLKFBOUT_PHASE(0.0),
    .CLKOUT0_DIVIDE(16),           // 800 / 16 = 50 MHz
    .CLKOUT0_PHASE(0.0),          // No phase shift
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DIVIDE(4),            // 800 / 4 = 200 MHz
    .CLKOUT1_PHASE(0.0),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT2_DIVIDE(64),           // 800 / 64 = 12.5 MHz
    .CLKOUT2_PHASE(0.0),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .DIVCLK_DIVIDE(1),
    .COMPENSATION("INTERNAL"),
    .BANDWIDTH("OPTIMIZED"),
    .REF_JITTER(0.100)
) pll_inst (
    .CLKIN(clk_100mhz),
    .CLKFBIN(clkfb),              // INTERNAL compensation: direct connection
    .RST(pll_rst),
    .CLKOUT0(clk_50mhz_unbuf),
    .CLKOUT1(clk_200mhz_unbuf),
    .CLKOUT2(clk_12p5mhz_unbuf),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKFBOUT(clkfb),
    .LOCKED(pll_locked)
);

// Buffer output clocks
BUFG bufg_50mhz (
    .I(clk_50mhz_unbuf),
    .O(clk_50mhz)
);

BUFG bufg_200mhz (
    .I(clk_200mhz_unbuf),
    .O(clk_200mhz)
);

BUFG bufg_12p5mhz (
    .I(clk_12p5mhz_unbuf),
    .O(clk_12p5mhz)
);

assign locked = pll_locked;

`endif

endmodule
