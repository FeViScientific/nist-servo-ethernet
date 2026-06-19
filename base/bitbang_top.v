///////////////////////////////////////////////////////////////////////////////
// bitbang_top.v
//
// Base scaffold (clocks + reset + RMII + Badger lbus) with the M25P32 config-
// flash pins driven DIRECTLY by the host, one level at a time -- a software
// bit-bang interface. No flash_spi shift engine: the host owns SCK/MOSI/CS as
// raw register bits and reads MISO back, so it can clock the flash edge by edge
// with full control over framing and timing. This is the lowest-level probe for
// the PAGE PROGRAM rejection: it removes every FPGA-side FSM/timing assumption.
//
// Register map (delta from base_top):
//   0x050 (R/W): pin drive   bit0 = SCK, bit1 = MOSI (flash_sdi out),
//                            bit2 = CS (flash_scs).  Reset = CS high, SCK/MOSI 0.
//   0x051 (RO):  bit0 = MISO (flash_sdo, double-synchronized)
//
// Multiple lbus writes/reads in one LASS packet execute in order, so a host can
// shift a whole byte (set MOSI+SCK low, set SCK high, repeat) and capture the
// MISO bits in a single round-trip.
//
// Firmware ID (reg 0x020) = 0xBA5E0B1B ("...0 B(it)B(ang)").
///////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module bitbang_top (
    input  wire        clk1_in,       // 100 MHz system clock (CY22393 CLKA)
    // RMII PHY (LAN8720A)
    output wire        phy_clk_out,
    input  wire [1:0]  phy_rxd,
    input  wire        phy_crs_dv,
    output wire [1:0]  phy_txd,
    output wire        phy_tx_en,
    // M25P32 config flash (raw SPI, host bit-banged)
    output reg         flash_scs,
    output reg         flash_sck,
    output reg         flash_sdi,     // MOSI (FPGA -> flash)
    input  wire        flash_sdo,     // MISO (flash -> FPGA)
    // Status LEDs
    output wire [7:0]  led
);

///////////////////////////////////////////////////////////////////////////////
// Clocks
///////////////////////////////////////////////////////////////////////////////
wire clk1;
BUFG bufg_sys_clk1 (.I(clk1_in), .O(clk1));

wire clk_50mhz, clk_200mhz, clk_12p5mhz, eth_clk_locked;
ethernet_clkgen_s6 eth_clkgen_inst (
    .clk_100mhz(clk1),
    .clk_50mhz(clk_50mhz),
    .clk_200mhz(clk_200mhz),
    .clk_12p5mhz(clk_12p5mhz),
    .locked(eth_clk_locked)
);

// 50 MHz output to PHY
ODDR2 #(.DDR_ALIGNMENT("NONE"), .INIT(1'b0), .SRTYPE("SYNC"))
oddr_phy_clk (
    .Q(phy_clk_out), .C0(clk_50mhz), .C1(~clk_50mhz),
    .CE(1'b1), .D0(1'b1), .D1(1'b0), .R(1'b0), .S(1'b0)
);

///////////////////////////////////////////////////////////////////////////////
// Reset
///////////////////////////////////////////////////////////////////////////////
wire power_on_reset;
SRL16 #(.INIT(16'hFFFF)) reset_sr (
    .D(1'b0), .CLK(clk1), .Q(power_on_reset),
    .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1)
);
reg rst1 = 1'b1, rst1_2 = 1'b1;
always @(posedge clk1) begin
    rst1   <= power_on_reset | ~eth_clk_locked;
    rst1_2 <= rst1;
end
wire rst = rst1_2;

///////////////////////////////////////////////////////////////////////////////
// RMII -> GMII
///////////////////////////////////////////////////////////////////////////////
wire [1:0] rmii_rxd, rmii_txd;
wire rmii_crs_dv, rmii_tx_en;
wire [7:0] gmii_rxd, gmii_txd;
wire gmii_rx_dv, gmii_rx_er, gmii_tx_en, gmii_tx_er;

rmii_iob iob_inst (
    .clk(clk_50mhz), .clk_200mhz(clk_200mhz), .tx_phase(3'd0),
    .phy_rxd(phy_rxd), .phy_crs_dv(phy_crs_dv),
    .phy_txd(phy_txd), .phy_tx_en(phy_tx_en),
    .rmii_rxd(rmii_rxd), .rmii_crs_dv(rmii_crs_dv),
    .rmii_txd(rmii_txd), .rmii_tx_en(rmii_tx_en)
);

rmii_gmii rmii_gmii_inst (
    .sys_clk(clk_50mhz), .sys_rst(rst),
    .rmii_rxd(rmii_rxd), .rmii_crs_dv(rmii_crs_dv),
    .rmii_txd(rmii_txd), .rmii_tx_en(rmii_tx_en),
    .gmii_rxd(gmii_rxd), .gmii_rx_dv(gmii_rx_dv), .gmii_rx_er(gmii_rx_er),
    .gmii_txd(gmii_txd), .gmii_tx_en(gmii_tx_en), .in_packet()
);

///////////////////////////////////////////////////////////////////////////////
// Badger (lbus register access over UDP/LASS, port 803)
///////////////////////////////////////////////////////////////////////////////
wire [23:0] lb_addr;
wire lb_valid, lb_rnw, lb_renable;
wire [31:0] lb_wdata;
reg  [31:0] lb_rdata = 32'd0;

rtefi_blob #(
    .ip({8'd192, 8'd168, 8'd7, 8'd140}),
    .mac(48'hAA0055000123),
    .mac_aw(4'd10), .n_lat(4'd8), .paw(4'd11),
    .p3_enable_bursts(1'b0), .p3_read_pipe_len(3),
    .udp_port0(16'd7), .udp_port1(16'd801), .udp_port2(16'd802),
    .udp_port3(16'd803), .udp_port4(16'd804),
    .udp_port5(16'd0), .udp_port6(16'd0), .udp_port7(16'd0)
) rtefi_blob_inst (
    .rx_clk(clk_12p5mhz), .rxd(gmii_rxd), .rx_dv(gmii_rx_dv), .rx_er(gmii_rx_er),
    .tx_clk(clk_12p5mhz), .txd(gmii_txd), .tx_en(gmii_tx_en), .tx_er(gmii_tx_er),
    .p3_addr(lb_addr), .p3_control_strobe(lb_valid),
    .p3_control_rd(lb_rnw), .p3_control_rd_valid(lb_renable),
    .p3_control_prefill(), .p3_data_out(lb_wdata), .p3_data_in(lb_rdata),
    .enable_rx(1'b1),
    .config_clk(1'b0), .config_a(4'd0), .config_d(8'd0), .config_s(1'b0), .config_p(1'b0),
    .host_rdata(16'd0), .buf_start_addr(10'd0),
    .tx_mac_start(1'b0), .rx_mac_hbank(1'b0), .rx_mac_accept(1'b0), .p2_nomangle(1'b0),
    .rx_mon(), .tx_mon(),
    .scanner_debug(), .scanner_busy(),
    .badger_tx_active(), .response_pending(),
    .ext_tx_data(8'd0), .ext_tx_strobe_s(1'b0), .ext_tx_strobe_l(1'b0),
    .dbg_stream_clear_to_send(), .dbg_stream_request_to_send(),
    .dbg_stream_payload_ready(), .dbg_stream_state(), .dbg_collision_count()
);

///////////////////////////////////////////////////////////////////////////////
// Flash pin bit-bang
//   0x050 bit0 = SCK, bit1 = MOSI, bit2 = CS. Output pins are registered in the
//   IOB for clean edges. MISO is double-synchronized into the lbus clock domain.
///////////////////////////////////////////////////////////////////////////////
(* IOB = "TRUE" *) reg miso_sync;
reg miso_meta;
always @(posedge clk_12p5mhz) begin
    miso_meta <= flash_sdo;
    miso_sync <= miso_meta;
end

always @(posedge clk_12p5mhz) begin
    if (rst) begin
        flash_scs <= 1'b1;     // CS deasserted
        flash_sck <= 1'b0;
        flash_sdi <= 1'b0;
    end else if (lb_valid && !lb_rnw && (lb_addr[11:0] == 12'h050)) begin
        flash_sck <= lb_wdata[0];
        flash_sdi <= lb_wdata[1];
        flash_scs <= lb_wdata[2];
    end
end

///////////////////////////////////////////////////////////////////////////////
// lbus register file (clk_12p5mhz)
///////////////////////////////////////////////////////////////////////////////
reg [31:0] scratch0 = 32'd0, scratch1 = 32'd0;
reg [7:0]  led_reg = 8'h01;
reg [2:0]  read_delay = 3'd2;
reg [31:0] uptime = 32'd0;

always @(posedge clk_12p5mhz) uptime <= uptime + 1'd1;

always @(posedge clk_12p5mhz) begin
    if (lb_valid && !lb_rnw) begin
        case (lb_addr[11:0])
            12'h000: scratch0   <= lb_wdata;
            12'h001: scratch1   <= lb_wdata;
            12'h002: led_reg    <= lb_wdata[7:0];
            12'h004: read_delay <= lb_wdata[2:0];
        endcase
    end
end
assign led = led_reg;

reg [31:0] rd_pipe [0:7];
integer pi;
always @(posedge clk_12p5mhz) begin
    case (lb_addr[11:0])
        12'h000: rd_pipe[0] <= scratch0;
        12'h001: rd_pipe[0] <= scratch1;
        12'h002: rd_pipe[0] <= {24'd0, led_reg};
        12'h004: rd_pipe[0] <= {29'd0, read_delay};
        12'h012: rd_pipe[0] <= uptime;
        12'h020: rd_pipe[0] <= 32'hBA5E_0B1B;     // bit-bang firmware ID
        12'h021: rd_pipe[0] <= {31'd0, eth_clk_locked};
        12'h050: rd_pipe[0] <= {29'd0, flash_scs, flash_sdi, flash_sck};
        12'h051: rd_pipe[0] <= {31'd0, miso_sync};
        default: rd_pipe[0] <= 32'hDEAD_DEAD;
    endcase
    for (pi = 1; pi < 8; pi = pi + 1)
        rd_pipe[pi] <= rd_pipe[pi-1];
    lb_rdata <= rd_pipe[read_delay];
end

endmodule
