// RMII IOB Registers for LAN8720A PHY
//
// Provides IOB-constrained flip-flops for RMII signals to/from the PHY.
// The (* IOB = "TRUE" *) attribute ensures the flip-flops are placed
// in the I/O block for minimal and deterministic timing.
//
// RX path: PHY pins -> IOB registers -> internal RMII signals
// TX path: Uses ODDR at 200 MHz for 8-phase selection (45 degree steps)
//
module rmii_iob (
    input  clk,              // 50 MHz system clock (for RX and TX logic)
    input  clk_200mhz,       // 200 MHz clock for ODDR TX phase control

    // Phase selection (0-7 = 0, 45, 90, 135, 180, 225, 270, 315 degrees)
    input  [2:0] tx_phase,

    // PHY-side pins (directly connected to FPGA pads)
    input  [1:0] phy_rxd,    // lan8720_rxd
    input  phy_crs_dv,       // lan8720_crs_dv
    output [1:0] phy_txd,    // lan8720_txd
    output phy_tx_en,        // lan8720_tx_en

    // Internal RMII signals (to/from rmii_gmii converter)
    output [1:0] rmii_rxd,   // Registered RX data
    output rmii_crs_dv,      // Registered CRS_DV
    input  [1:0] rmii_txd,   // TX data to register
    input  rmii_tx_en        // TX enable to register
);

// RX path: PHY -> IOB register -> internal
(* IOB = "TRUE" *) FDRE #(
    .INIT(1'b0)
) fdre_rxd0 (
    .C(clk),
    .CE(1'b1),
    .D(phy_rxd[0]),
    .R(1'b0),
    .Q(rmii_rxd[0])
);

(* IOB = "TRUE" *) FDRE #(
    .INIT(1'b0)
) fdre_rxd1 (
    .C(clk),
    .CE(1'b1),
    .D(phy_rxd[1]),
    .R(1'b0),
    .Q(rmii_rxd[1])
);

(* IOB = "TRUE" *) FDRE #(
    .INIT(1'b0)
) fdre_crs_dv (
    .C(clk),
    .CE(1'b1),
    .D(phy_crs_dv),
    .R(1'b0),
    .Q(rmii_crs_dv)
);

// TX path: ODDR at 200 MHz for phase-shifted 50 MHz output
// 200 MHz = 4x 50 MHz, so each 50 MHz period has 4 rising edges of 200 MHz
// ODDR outputs D1 on rising edge, D2 on falling edge -> 8 edges per 50 MHz period
// Phase 0: output changes at 0 degrees of 50 MHz cycle
// Phase 1: output changes at 45 degrees, etc.

// Generate 8-bit shift patterns for each phase (repeating 11110000 pattern shifted)
// At 200 MHz with ODDR: each 50 MHz period = 4 ODDR cycles = 8 output edges
// We need to generate the right D1/D2 sequence based on phase and current 50 MHz position

// Synchronize TX data to 200 MHz domain and generate phase-shifted output
// Use a counter to track position within 50 MHz cycle, synced via toggle FF

// Toggle FF in 50 MHz domain - changes every 50 MHz cycle
reg toggle_50 = 0;
always @(posedge clk) begin
    toggle_50 <= ~toggle_50;
end

// Sample toggle in 200 MHz domain to detect 50 MHz edges
reg toggle_d1 = 0, toggle_d2 = 0;
always @(posedge clk_200mhz) begin
    toggle_d1 <= toggle_50;
    toggle_d2 <= toggle_d1;
end
wire toggle_edge = toggle_d1 ^ toggle_d2;  // Detects any edge of toggle

// Counter synced to 50 MHz edge (via toggle)
reg [1:0] cycle_200 = 2'd0;  // 0-3 counts 200 MHz cycles within 50 MHz period

always @(posedge clk_200mhz) begin
    if (toggle_edge)
        cycle_200 <= 2'd1;  // We're 1 cycle after the edge
    else
        cycle_200 <= cycle_200 + 1'd1;
end

// Sample TX data at 50 MHz boundaries (when cycle_200 == 0)
reg [1:0] txd_sync = 2'd0;
reg tx_en_sync = 1'b0;
reg [1:0] txd_prev = 2'd0;
reg tx_en_prev = 1'b0;

always @(posedge clk_200mhz) begin
    if (cycle_200 == 2'd3) begin
        // Sample new value just before cycle 0
        txd_prev <= txd_sync;
        tx_en_prev <= tx_en_sync;
        txd_sync <= rmii_txd;
        tx_en_sync <= rmii_tx_en;
    end
end

// Calculate which value to output based on phase and cycle position
// phase 0: switch at cycle 0, edge 0 (D1)
// phase 1: switch at cycle 0, edge 1 (D2)
// phase 2: switch at cycle 1, edge 0 (D1)
// etc.
wire [2:0] current_edge = {cycle_200, 1'b0};  // D1 edge
wire [2:0] current_edge_d2 = {cycle_200, 1'b1};  // D2 edge

// Determine if we should output new or old value
wire use_new_d1 = (current_edge >= tx_phase);
wire use_new_d2 = (current_edge_d2 >= tx_phase);

wire [1:0] txd_d1 = use_new_d1 ? txd_sync : txd_prev;
wire [1:0] txd_d2 = use_new_d2 ? txd_sync : txd_prev;
wire tx_en_d1 = use_new_d1 ? tx_en_sync : tx_en_prev;
wire tx_en_d2 = use_new_d2 ? tx_en_sync : tx_en_prev;

// ODDR for txd[0]
ODDR2 #(
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC")
) oddr_txd0 (
    .Q(phy_txd[0]),
    .C0(clk_200mhz),
    .C1(~clk_200mhz),
    .CE(1'b1),
    .D0(txd_d1[0]),
    .D1(txd_d2[0]),
    .R(1'b0),
    .S(1'b0)
);

// ODDR for txd[1]
ODDR2 #(
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC")
) oddr_txd1 (
    .Q(phy_txd[1]),
    .C0(clk_200mhz),
    .C1(~clk_200mhz),
    .CE(1'b1),
    .D0(txd_d1[1]),
    .D1(txd_d2[1]),
    .R(1'b0),
    .S(1'b0)
);

// ODDR for tx_en
ODDR2 #(
    .DDR_ALIGNMENT("C0"),
    .INIT(1'b0),
    .SRTYPE("ASYNC")
) oddr_tx_en (
    .Q(phy_tx_en),
    .C0(clk_200mhz),
    .C1(~clk_200mhz),
    .CE(1'b1),
    .D0(tx_en_d1),
    .D1(tx_en_d2),
    .R(1'b0),
    .S(1'b0)
);

endmodule
