///////////////////////////////////////////////////////////////////////////////
// SuperLaserLand_Ethernet_Bare.v
//
// Incremental Ethernet build. Started bare (ping + lbus only), now adding
// hardware modules one by one with direct lbus registers.
//
// Currently enabled:
//   - Badger Ethernet (ping, LASS register R/W on port 803)
//   - LTC2195 ADC (2ch @ 100 MSPS) + IIR1stOrder filter
//   - AD8251 input PGA
//   - AD9783 fast DAC (2ch via FractionalDAC delta-sigma)
//   - AD5791 precision DAC
//   - AD8251 output PGA
//   - 3-channel servo loop (IIR chain, Sweep, Relock, DigitalDelay, Limit)
//
///////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module SuperLaserLand_Ethernet_Bare(
    input  wire        clk1_in,
    output wire        phy_clk_out,
    input  wire [1:0]  phy_rxd,
    input  wire        phy_crs_dv,
    output wire [1:0]  phy_txd,
    output wire        phy_tx_en,
    output wire [7:0]  led,

    // Digital I/O
    input  wire [2:0]  DIN,
    output wire [2:0]  DOUT,
    output wire [2:0]  LED_G,
    output wire [2:0]  LED_R,

    // LTC2195 ADC
    output wire        LTC2195_SCS,
    output wire        LTC2195_SCK,
    output wire        LTC2195_SDI,
    input  wire        LTC2195_SDO,
    output wire        LTC2195_ENC_P,
    output wire        LTC2195_ENC_N,
    input  wire        LTC2195_FR_P,
    input  wire        LTC2195_FR_N,
    input  wire        LTC2195_DCO_P,
    input  wire        LTC2195_DCO_N,
    input  wire [3:0]  LTC2195_D0_P,
    input  wire [3:0]  LTC2195_D0_N,
    input  wire [3:0]  LTC2195_D1_P,
    input  wire [3:0]  LTC2195_D1_N,

    // Input PGA (AD8251)
    output wire        AD8251_IN_A0,
    output wire        AD8251_IN_A1,
    output wire        AD8251_IN_WR0,
    output wire        AD8251_IN_WR1,

    // AD9783 Fast DAC
    output wire        AD9783_RST,
    output wire        AD9783_SCS,
    output wire        AD9783_SCK,
    output wire        AD9783_SDI,
    input  wire        AD9783_SDO,
    output wire        AD9783_CLK_P,
    output wire        AD9783_CLK_N,
    output wire        AD9783_DCI_P,
    output wire        AD9783_DCI_N,
    output wire [15:0] AD9783_D_P,
    output wire [15:0] AD9783_D_N,

    // AD5791 Precision DAC
    output wire        AD5791_LDAC,
    output wire        AD5791_CLR,
    output wire        AD5791_RST,
    output wire        AD5791_SCS,
    output wire        AD5791_SCK,
    output wire        AD5791_SDI,
    input  wire        AD5791_SDO,

    // Output PGA (AD8251)
    output wire        AD8251_OUT_A0,
    output wire        AD8251_OUT_A1,
    output wire        AD8251_OUT_WR0,
    output wire        AD8251_OUT_WR1,

    // M25P32 configuration flash (raw SPI transport for non-volatile config)
    output wire        flash_scs,   // chip select (active low)
    output wire        flash_sck,   // serial clock
    output wire        flash_sdi,   // MOSI (FPGA -> flash)
    input  wire        flash_sdo,   // MISO (flash -> FPGA)

    // DDR2 memory interface
    inout  wire [15:0] mcb3_dram_dq,
    output wire [12:0] mcb3_dram_a,
    output wire [2:0]  mcb3_dram_ba,
    output wire        mcb3_dram_ras_n,
    output wire        mcb3_dram_cas_n,
    output wire        mcb3_dram_we_n,
    output wire        mcb3_dram_odt,
    output wire        mcb3_dram_cke,
    output wire        mcb3_dram_dm,
    inout  wire        mcb3_dram_udqs,
    inout  wire        mcb3_dram_udqs_n,
    inout  wire        mcb3_rzq,
    inout  wire        mcb3_zio,
    output wire        mcb3_dram_udm,
    inout  wire        mcb3_dram_dqs,
    inout  wire        mcb3_dram_dqs_n,
    output wire        mcb3_dram_ck,
    output wire        mcb3_dram_ck_n,
    output wire        mcb3_dram_cs_n,
    input  wire        c3_sys_rst_n
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

// 50 MHz output to PHY (same clock as RMII logic, 90 deg phase shift)
ODDR2 #(.DDR_ALIGNMENT("NONE"), .INIT(1'b0), .SRTYPE("SYNC"))
oddr_phy_clk (
    .Q(phy_clk_out), .C0(clk_50mhz), .C1(~clk_50mhz),
    .CE(1'b1), .D0(1'b1), .D1(1'b0), .R(1'b0), .S(1'b0)
);

// 25 MHz DSP clock and clock enable
reg [1:0] clk_div_counter = 2'd0;
always @(posedge clk1) clk_div_counter <= clk_div_counter + 1'd1;
wire ce = (clk_div_counter == 2'b00);

wire clk_dsp;
BUFG bufg_clk_dsp (.I(clk_div_counter[1]), .O(clk_dsp));

///////////////////////////////////////////////////////////////////////////////
// Reset
///////////////////////////////////////////////////////////////////////////////

wire power_on_reset;
SRL16 #(.INIT(16'hFFFF)) reset_sr (
    .D(1'b0), .CLK(clk1), .Q(power_on_reset),
    .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1)
);

// Async-assert source shared by every domain's reset synchronizer. The PLL
// outputs (clk_50mhz, clk_12p5mhz) only run once eth_clk_locked is high, so all
// domains stay async-held in reset until then. KEEP so the net survives for the
// `NET "por_or_unlocked" TIG;` constraint (its async deassert must be ignored by
// timing -- the synchronizers below resolve any metastability).
(* KEEP = "TRUE" *) wire por_or_unlocked = power_on_reset | ~eth_clk_locked;

// Per-domain reset synchronizers: async assert, SYNCHRONOUS deassert, each
// clocked by its own domain clock. The reset RELEASE is triggered by the
// asynchronous PLL LOCKED, so even though all clocks are phase-locked, the
// release edge must be re-registered in each receiving domain -- otherwise it
// lands at a random phase there and the logic can come out of reset metastably
// (the intermittent "comes up dead", especially the clk_50mhz RMII datapath,
// which is the only Ethernet block that has a reset).
(* ASYNC_REG = "TRUE" *) reg [1:0] rst_clk1_sync = 2'b11;
always @(posedge clk1 or posedge por_or_unlocked)
    if (por_or_unlocked) rst_clk1_sync <= 2'b11;
    else                 rst_clk1_sync <= {rst_clk1_sync[0], 1'b0};

(* ASYNC_REG = "TRUE" *) reg [1:0] rst_50_sync = 2'b11;
always @(posedge clk_50mhz or posedge por_or_unlocked)
    if (por_or_unlocked) rst_50_sync <= 2'b11;
    else                 rst_50_sync <= {rst_50_sync[0], 1'b0};

(* ASYNC_REG = "TRUE" *) reg [1:0] rst_125_sync = 2'b11;
always @(posedge clk_12p5mhz or posedge por_or_unlocked)
    if (por_or_unlocked) rst_125_sync <= 2'b11;
    else                 rst_125_sync <= {rst_125_sync[0], 1'b0};

(* ASYNC_REG = "TRUE" *) reg [1:0] rst_dsp_sync = 2'b11;
always @(posedge clk_dsp or posedge por_or_unlocked)
    if (por_or_unlocked) rst_dsp_sync <= 2'b11;
    else                 rst_dsp_sync <= {rst_dsp_sync[0], 1'b0};

wire rst_50  = rst_50_sync[1];    // clk_50mhz   (RMII datapath)
wire rst_125 = rst_125_sync[1];   // clk_12p5mhz (flash_spi, net_config_loader)
wire rst_dsp = rst_dsp_sync[1];   // clk_dsp     (servo / LockIn DSP)
wire rst     = rst_clk1_sync[1];  // clk1        (everything else)

///////////////////////////////////////////////////////////////////////////////
// Digital I/O registers
///////////////////////////////////////////////////////////////////////////////

reg [2:0] DIN_f;
always @(posedge clk1) DIN_f <= DIN;

reg [2:0] DOUT_f;
// Per-pin relock-hold status (clk1), the default DOUT source. The final DOUT_f
// is selected from this or the sweep sync by dout_src (see DOUT source mux below).
reg [2:0] relock_hold_status;
// DOUT[1] is overridden at boot by the network-config recovery loopback test
// (see assign near net_config_loader_inst); bits 0 and 2 are normal status.
assign DOUT[0] = DOUT_f[0];
assign DOUT[2] = DOUT_f[2];

reg [2:0] LED_G_f, LED_R_f;
assign LED_G = LED_G_f;
assign LED_R = LED_R_f;

///////////////////////////////////////////////////////////////////////////////
// RMII -> GMII
///////////////////////////////////////////////////////////////////////////////

reg [2:0]  tx_phase_reg = 3'd0;

wire [1:0] rmii_rxd, rmii_txd;
wire rmii_crs_dv, rmii_tx_en;
wire [7:0] gmii_rxd, gmii_txd;
wire gmii_rx_dv, gmii_rx_er, gmii_tx_en, gmii_tx_er;

rmii_iob iob_inst (
    .clk(clk_50mhz), .clk_200mhz(clk_200mhz), .tx_phase(tx_phase_reg),
    .phy_rxd(phy_rxd), .phy_crs_dv(phy_crs_dv),
    .phy_txd(phy_txd), .phy_tx_en(phy_tx_en),
    .rmii_rxd(rmii_rxd), .rmii_crs_dv(rmii_crs_dv),
    .rmii_txd(rmii_txd), .rmii_tx_en(rmii_tx_en)
);

rmii_gmii rmii_gmii_inst (
    .sys_clk(clk_50mhz), .sys_rst(rst_50),
    .rmii_rxd(rmii_rxd), .rmii_crs_dv(rmii_crs_dv),
    .rmii_txd(rmii_txd), .rmii_tx_en(rmii_tx_en),
    .gmii_rxd(gmii_rxd), .gmii_rx_dv(gmii_rx_dv), .gmii_rx_er(gmii_rx_er),
    .gmii_txd(gmii_txd), .gmii_tx_en(gmii_tx_en), .in_packet()
);

///////////////////////////////////////////////////////////////////////////////
// Badger
///////////////////////////////////////////////////////////////////////////////

// Boot-time network-config loader outputs (driven below near flash_spi).
// Declared here so the rtefi_blob config interface can connect to them.
wire        boot_done;
wire        net_recovery;
wire        loop_drive, loop_active;
wire [6:0]  ldr_buf_addr;
wire [31:0] ldr_buf_wdata;
wire        ldr_buf_we;
wire [9:0]  ldr_len;
wire        ldr_go;
wire [3:0]  ncfg_a;
wire [7:0]  ncfg_d;
wire        ncfg_s;

wire [23:0] lb_addr;
wire lb_valid, lb_rnw, lb_renable;
wire [31:0] lb_wdata;
reg  [31:0] lb_rdata = 32'd0;
wire rx_mon, tx_mon, scanner_busy, response_pending;

// Stream TX signals (declared here, driven by stream_tx instance below)
wire [7:0] stream_txd;
wire stream_tx_strobe_s;
wire stream_tx_strobe_l;

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
    .config_clk(clk_12p5mhz), .config_a(ncfg_a), .config_d(ncfg_d), .config_s(ncfg_s), .config_p(1'b0),
    .host_rdata(16'd0), .buf_start_addr(10'd0),
    .tx_mac_start(1'b0), .rx_mac_hbank(1'b0), .rx_mac_accept(1'b0), .p2_nomangle(1'b0),
    .rx_mon(rx_mon), .tx_mon(tx_mon),
    .scanner_debug(), .scanner_busy(scanner_busy),
    .badger_tx_active(), .response_pending(response_pending),
    .ext_tx_data(stream_txd), .ext_tx_strobe_s(stream_tx_strobe_s), .ext_tx_strobe_l(stream_tx_strobe_l),
    .dbg_stream_clear_to_send(), .dbg_stream_request_to_send(),
    .dbg_stream_payload_ready(), .dbg_stream_state(), .dbg_collision_count()
);

///////////////////////////////////////////////////////////////////////////////
// lbus registers (all in clk_12p5mhz)
//
// Test registers:
//   0x000-0x004, 0x010-0x012, 0x020-0x021: scratch, LED, counters, FW ID
//
// Stream TX destination (0x030):
//   0x030: dest_mac[47:16]   (R/W, upper 4 bytes)
//   0x031: dest_mac[15:0]    (R/W, lower 2 bytes)
//   0x032: dest_ip[31:0]     (R/W)
//   0x033: dest_port[15:0]   (R/W)
//   0x034: ip_checksum[15:0] (R/W)
//
// Configuration flash, raw M25P32 SPI transport (0x044-0x046, 0x800-0x87F):
//   0x044: flash_len[9:0]  (R/W) - number of bytes to shift (1..512)
//   0x045: flash_go        (W)   - write to start the transfer
//   0x046: flash_busy      (RO)  - bit0 = transfer in progress
//   0x800-0x87F: 512-byte transfer buffer, 128 x 32-bit words (R/W).
//     Byte i is in word (i>>2), little-endian: byte0=[7:0]..byte3=[31:24].
//     Host fills with a full SPI transaction, sets len, pulses go; MISO is
//     captured back into the same buffer in place. No flash-protocol logic
//     lives in the FPGA -- the host (servo_device.py) implements M25P32.
//
// DAC registers (0x100):
//   0x100-0x102: DAC0/1/2 value [23:0] signed (R/W, used when servo_on=0)
//   0x103: output gain (R/W)
//   0x104: ramp enable (R/W)
//
// SPI command interface (0x110, shared by AD9783 + LTC2195):
//   0x110: cmd_addr [15:0] (R/W)
//   0x111: cmd_data [15:0] (R/W) / SPI readback
//   0x112: cmd_trig (W)
//   0x113: AD9783 PLL locked (RO)
//
// ADC registers (0x200):
//   0x200-0x201: ADCraw[0:1] (RO)
//   0x202-0x203: ADCout[0:1] (RO, after IIR)
//   0x204: Input PGA gain (R/W)
//   0x205: IIR enable (R/W)
//   0x206-0x211: IIR coefficients (R/W)
//   0x212: FR_out (RO)
//
// Servo channel 0 (0x300-0x33F):
// Servo channel 1 (0x400-0x43F):
// Servo channel 2 (0x500-0x53F):
//   See register map below.
//
///////////////////////////////////////////////////////////////////////////////

// Test registers
reg [31:0] scratch0 = 32'd0;
reg [31:0] scratch1 = 32'd0;
reg [7:0]  led_reg = 8'hFF;
reg [31:0] rx_pkt_count = 32'd0;
reg [31:0] tx_pkt_count = 32'd0;
reg [31:0] uptime = 32'd0;

// DOUT source select (0x022): 3 pins x 2-bit field.
//   field == 0 -> relock-hold status (default); 1/2/3 -> sweep-sync from ch0/1/2.
//   bits [1:0]=DOUT[0], [3:2]=DOUT[1], [5:4]=DOUT[2].
reg [5:0] dout_src = 6'd0;

// Packet counters
reg rx_mon_d = 1'b0, tx_mon_d = 1'b0;
always @(posedge clk_12p5mhz) begin
    rx_mon_d <= rx_mon;
    tx_mon_d <= tx_mon;
    if (rx_mon && !rx_mon_d) rx_pkt_count <= rx_pkt_count + 1'd1;
    if (tx_mon && !tx_mon_d) tx_pkt_count <= tx_pkt_count + 1'd1;
    uptime <= uptime + 1'd1;
end

// Stream TX destination registers (lbus domain, 0x030-0x034)
//   0x030: dest_mac[47:16] (upper 4 bytes)
//   0x031: {dest_mac[15:0], dest_port[15:0]}
//   0x032: dest_ip[31:0]
//   0x033: ip_checksum[15:0]
reg [47:0] stream_dest_mac  = 48'h5c857e32af37;
reg [31:0] stream_dest_ip   = {8'd192, 8'd168, 8'd7, 8'd4};
reg [15:0] stream_dest_port = 16'd5000;
reg [15:0] stream_ip_cksum  = 16'hAA70;

// DAC registers (lbus domain)
reg [23:0] dac0_value = 24'd0;
reg [23:0] dac1_value = 24'd0;
reg [23:0] dac2_value = 24'd0;
reg [3:0]  dac_gain = 4'd0;
reg        ramp_enable = 1'b0;

// SPI command interface (shared by AD9783 + LTC2195)
reg [15:0] spi_cmd_addr = 16'd0;
reg [15:0] spi_cmd_data = 16'd0;
reg        cmd_trig_pending = 1'b0;
wire       cmd_trig_clear;

// Configuration flash (raw M25P32 SPI transport, lbus domain)
reg  [9:0]  flash_len = 10'd0;
wire        flash_busy;
wire [31:0] flash_buf_rdata;
wire [15:0] flash_sck_count;   // diagnostic: SCK rising edges in last transfer
wire        flash_buf_we = lb_valid && !lb_rnw && (lb_addr[11:7] == 5'b10000); // 0x800-0x87F
wire        flash_go     = lb_valid && !lb_rnw && (lb_addr[11:0] == 12'h045);

// ADC registers (lbus domain)
reg [3:0]  adc_gain = 4'd0;    // {gain1[1:0], gain0[1:0]}
reg [1:0]  iir_enable = 2'b0;  // {ch1, ch0}
reg [34:0] iir_a1 [0:1];
reg [34:0] iir_b0 [0:1];
reg [34:0] iir_b1 [0:1];

initial begin
    iir_a1[0] = 35'd0; iir_a1[1] = 35'd0;
    iir_b0[0] = 35'd0; iir_b0[1] = 35'd0;
    iir_b1[0] = 35'd0; iir_b1[1] = 35'd0;
end

///////////////////////////////////////////////////////////////////////////////
// Servo channel registers (lbus domain, clk_12p5mhz)
//
// Per-channel register map (offset from channel base 0x300/0x400/0x500):
//   +0x00: servo_on                       (R/W, bit 0)
//   +0x01: input_mux[3:0]                (R/W, {source[2:0], invert})
//   +0x02: offset[15:0]                  (R/W, signed)
//   +0x03: limit_min[15:0]               (R/W, signed)
//   +0x04: limit_max[15:0]               (R/W, signed)
//   +0x05: limit_center_when_railed      (R/W, bit 0)
//
//   IIR0 (2nd order anti-windup):
//   +0x10: iir0_on                        (R/W, bit 0)
//   +0x11: iir0_a1[31:0]                (R/W)
//   +0x12: iir0_a1[34:32]               (R/W)
//   +0x13: iir0_a2[31:0]                (R/W)
//   +0x14: iir0_a2[34:32]               (R/W)
//   +0x15: iir0_b0[31:0]                (R/W)
//   +0x16: iir0_b0[34:32]               (R/W)
//   +0x17: iir0_b1[31:0]                (R/W)
//   +0x18: iir0_b1[34:32]               (R/W)
//   +0x19: iir0_b2[31:0]                (R/W)
//   +0x1A: iir0_b2[34:32]               (R/W)
//
//   IIR1 (1st order anti-windup):
//   +0x1B: iir1_on                        (R/W, bit 0)
//   +0x1C: iir1_a1[31:0]                (R/W)
//   +0x1D: iir1_a1[34:32]               (R/W)
//   +0x1E: iir1_b0[31:0]                (R/W)
//   +0x1F: iir1_b0[34:32]               (R/W)
//   +0x20: iir1_b1[31:0]                (R/W)
//   +0x21: iir1_b1[34:32]               (R/W)
//
//   IIR2 (1st order, ch0/ch1 only):
//   +0x22: iir2_on                        (R/W, bit 0)
//   +0x23: iir2_a1[31:0]                (R/W)
//   +0x24: iir2_a1[34:32]               (R/W)
//   +0x25: iir2_b0[31:0]                (R/W)
//   +0x26: iir2_b0[34:32]               (R/W)
//   +0x27: iir2_b1[31:0]                (R/W)
//   +0x28: iir2_b1[34:32]               (R/W)
//
//   IIR3 (1st order, ch0/ch1 only):
//   +0x29: iir3_on                        (R/W, bit 0)
//   +0x2A: iir3_a1[31:0]                (R/W)
//   +0x2B: iir3_a1[34:32]               (R/W)
//   +0x2C: iir3_b0[31:0]                (R/W)
//   +0x2D: iir3_b0[34:32]               (R/W)
//   +0x2E: iir3_b1[31:0]                (R/W)
//   +0x2F: iir3_b1[34:32]               (R/W)
//
//   Sweep:
//   +0x30: sweep_on                       (R/W, bit 0)
//   +0x31: sweep_minval[15:0]            (R/W, signed)
//   +0x32: sweep_maxval[15:0]            (R/W, signed)
//   +0x33: sweep_stepsize[31:0]          (R/W)
//
//   Relock:
//   +0x34: relock_on                      (R/W, bit 0)
//   +0x35: relock_input_select[3:0]      (R/W)
//   +0x36: relock_minval[15:0]           (R/W, signed)
//   +0x37: relock_maxval[15:0]           (R/W, signed)
//   +0x38: relock_stepsize[31:0]         (R/W)
//
//   DigitalDelay:
//   +0x39: hold_source[4:0]              (R/W)
//   +0x3A: delay_falling[31:0]           (R/W)
//   +0x3B: delay_rising[31:0]            (R/W)
//
//   Modulation:
//   +0x3C: lockin_lo_shift[4:0]          (R/W)
//
//   Readback:
//   +0x3E: DACin[23:0]                   (RO, signed, servo output)
//   +0x3F: status {relock_hold, railed[1:0]} (RO)
//
///////////////////////////////////////////////////////////////////////////////

// Servo registers (lbus domain) - arrays indexed by channel [0:2]
reg         ch_servo_on      [0:2];
reg  [3:0]  ch_input_mux     [0:2];
reg  [15:0] ch_offset        [0:2];
reg  [15:0] ch_limit_min     [0:2];
reg  [15:0] ch_limit_max     [0:2];
reg         ch_limit_center  [0:2];

// IIR0 (2nd order)
reg         ch_iir0_on       [0:2];
reg  [34:0] ch_iir0_a1       [0:2];
reg  [34:0] ch_iir0_a2       [0:2];
reg  [34:0] ch_iir0_b0       [0:2];
reg  [34:0] ch_iir0_b1       [0:2];
reg  [34:0] ch_iir0_b2       [0:2];

// IIR1 (1st order)
reg         ch_iir1_on       [0:2];
reg  [34:0] ch_iir1_a1       [0:2];
reg  [34:0] ch_iir1_b0       [0:2];
reg  [34:0] ch_iir1_b1       [0:2];

// IIR2 (1st order, ch0/ch1 only)
reg         ch_iir2_on       [0:2];
reg  [34:0] ch_iir2_a1       [0:2];
reg  [34:0] ch_iir2_b0       [0:2];
reg  [34:0] ch_iir2_b1       [0:2];

// IIR3 (1st order, ch0/ch1 only)
reg         ch_iir3_on       [0:2];
reg  [34:0] ch_iir3_a1       [0:2];
reg  [34:0] ch_iir3_b0       [0:2];
reg  [34:0] ch_iir3_b1       [0:2];

// Sweep
reg         ch_sweep_on      [0:2];
reg  [15:0] ch_sweep_min     [0:2];
reg  [15:0] ch_sweep_max     [0:2];
reg  [31:0] ch_sweep_step    [0:2];

// Relock
reg         ch_relock_on     [0:2];
reg  [3:0]  ch_relock_sel    [0:2];
reg  [15:0] ch_relock_min    [0:2];
reg  [15:0] ch_relock_max    [0:2];
reg  [31:0] ch_relock_step   [0:2];

// DigitalDelay
reg  [4:0]  ch_hold_source   [0:2];
reg  [31:0] ch_delay_fall    [0:2];
reg  [31:0] ch_delay_rise    [0:2];

// Modulation
reg  [4:0]  ch_lo_shift      [0:2];

// Initialize all servo registers
integer ch_init;
initial begin
    for (ch_init = 0; ch_init < 3; ch_init = ch_init + 1) begin
        ch_servo_on[ch_init]     = 1'b0;
        ch_input_mux[ch_init]    = 4'd0;
        ch_offset[ch_init]       = 16'd0;
        ch_limit_min[ch_init]    = 16'h8000;
        ch_limit_max[ch_init]    = 16'h7FFF;
        ch_limit_center[ch_init] = 1'b0;
        ch_iir0_on[ch_init] = 1'b0;
        ch_iir0_a1[ch_init] = 35'd0; ch_iir0_a2[ch_init] = 35'd0;
        ch_iir0_b0[ch_init] = 35'd0; ch_iir0_b1[ch_init] = 35'd0;
        ch_iir0_b2[ch_init] = 35'd0;
        ch_iir1_on[ch_init] = 1'b0;
        ch_iir1_a1[ch_init] = 35'd0;
        ch_iir1_b0[ch_init] = 35'd0; ch_iir1_b1[ch_init] = 35'd0;
        ch_iir2_on[ch_init] = 1'b0;
        ch_iir2_a1[ch_init] = 35'd0;
        ch_iir2_b0[ch_init] = 35'd0; ch_iir2_b1[ch_init] = 35'd0;
        ch_iir3_on[ch_init] = 1'b0;
        ch_iir3_a1[ch_init] = 35'd0;
        ch_iir3_b0[ch_init] = 35'd0; ch_iir3_b1[ch_init] = 35'd0;
        ch_sweep_on[ch_init]   = 1'b0;
        ch_sweep_min[ch_init]  = 16'd0; ch_sweep_max[ch_init] = 16'd0;
        ch_sweep_step[ch_init] = 32'd0;
        ch_relock_on[ch_init]   = 1'b0;
        ch_relock_sel[ch_init]  = 4'd0;
        ch_relock_min[ch_init]  = 16'd0; ch_relock_max[ch_init] = 16'd0;
        ch_relock_step[ch_init] = 32'd0;
        ch_hold_source[ch_init] = 5'd0;
        ch_delay_fall[ch_init]  = 32'd0;
        ch_delay_rise[ch_init]  = 32'd0;
        ch_lo_shift[ch_init]    = 5'd0;
    end
end

///////////////////////////////////////////////////////////////////////////////
// LockIn registers (0x600-0x63F, lbus domain)
//
//   +0x00: input_select (bit 0: 0=ADC0, 1=ADC1)
//   +0x01: NCO pinc[23:0]
//   +0x02: NCO poff[23:0] (signed)
//
//   IIR0 (pre-filter, 2nd order):
//   +0x10: on
//   +0x11-0x12: a1, +0x13-0x14: a2, +0x15-0x16: b0, +0x17-0x18: b1, +0x19-0x1A: b2
//
//   IIR1 (post-filter, 2nd order):
//   +0x1B: on
//   +0x1C-0x1D: a1, +0x1E-0x1F: a2, +0x20-0x21: b0, +0x22-0x23: b1, +0x24-0x25: b2
//
//   Readback:
//   +0x30: LOCKINout[23:0] (RO)
//   +0x31: LOCKINlo[23:0] (RO)
//
///////////////////////////////////////////////////////////////////////////////

reg         li_input_sel = 1'b0;
reg  [23:0] li_pinc = 24'd0;
reg  [23:0] li_poff = 24'd0;

reg         li_iir0_on = 1'b0;
reg  [34:0] li_iir0_a1 = 35'd0, li_iir0_a2 = 35'd0;
reg  [34:0] li_iir0_b0 = 35'd0, li_iir0_b1 = 35'd0, li_iir0_b2 = 35'd0;

reg         li_iir1_on = 1'b0;
reg  [34:0] li_iir1_a1 = 35'd0, li_iir1_a2 = 35'd0;
reg  [34:0] li_iir1_b0 = 35'd0, li_iir1_b1 = 35'd0, li_iir1_b2 = 35'd0;

///////////////////////////////////////////////////////////////////////////////
// PhaseDetector registers (0x700-0x73F, lbus domain)
//
//   +0x00: input_select (bit 0: 0=ADC0, 1=ADC1)
//   +0x01: use_ext_clk (bit 0)
//   +0x02: pinc[31:0]
//
//   LP filter:
//   +0x10: on
//   +0x11-0x12: a1
//   +0x13-0x14: b0
//
//   Readback:
//   +0x30: PHASEDETraw[31:0] (RO)
//
///////////////////////////////////////////////////////////////////////////////

reg         pd_input_sel = 1'b0;
reg         pd_use_ext_clk = 1'b0;
reg  [31:0] pd_pinc = 32'd0;

reg         pd_lp_on = 1'b0;
reg  [34:0] pd_lp_a1 = 35'd0;
reg  [34:0] pd_lp_b0 = 35'd0;

///////////////////////////////////////////////////////////////////////////////
// TransferFunction: uses shared SPI command interface (cmd_trig + cmd_addr)
// Add cmd_data2 register at 0x114 for 32-bit frequency word
///////////////////////////////////////////////////////////////////////////////

reg [15:0] spi_cmd_data2 = 16'd0;

///////////////////////////////////////////////////////////////////////////////
// lbus read/write logic (clk_12p5mhz domain)
///////////////////////////////////////////////////////////////////////////////

// Read pipeline
reg [2:0] read_delay = 3'd2;
reg [31:0] rd_pipe [0:7];
integer pi;

// Channel address decode: 0x3xx=ch0, 0x4xx=ch1, 0x5xx=ch2
wire [1:0] ch_sel = lb_addr[10:8] - 2'd3;
wire [7:0] ch_off = lb_addr[7:0];
wire       ch_wr  = lb_valid && !lb_rnw &&
                    (lb_addr[11:8] >= 4'h3) && (lb_addr[11:8] <= 4'h5);

// Channel read data (computed below)
reg [31:0] ch_rd_data;

// LockIn/PhaseDetector read data
reg [31:0] li_rd_data;
reg [31:0] pd_rd_data;

// DSP chain outputs for readback
localparam SIGNAL_SIZE = 24;
wire signed [SIGNAL_SIZE-1:0] DACin [0:2];
wire [1:0]  ch_railed   [0:2];
wire        ch_relock_hold [0:2];

always @(posedge clk_12p5mhz) begin
    // Writes
    if (cmd_trig_clear)
        cmd_trig_pending <= 1'b0;
    if (lb_valid && !lb_rnw) begin
        case (lb_addr[11:0])
            12'h000: scratch0   <= lb_wdata;
            12'h001: scratch1   <= lb_wdata;
            12'h002: led_reg    <= lb_wdata[7:0];
            12'h003: tx_phase_reg <= lb_wdata[2:0];
            12'h004: read_delay <= lb_wdata[2:0];
            12'h022: dout_src   <= lb_wdata[5:0];
            12'h100: dac0_value <= lb_wdata[23:0];
            12'h101: dac1_value <= lb_wdata[23:0];
            12'h102: dac2_value <= lb_wdata[23:0];
            12'h103: dac_gain   <= lb_wdata[3:0];
            12'h104: ramp_enable <= lb_wdata[0];
            // Stream TX destination (0x030-0x034)
            12'h030: stream_dest_mac[47:16] <= lb_wdata;
            12'h031: stream_dest_mac[15:0]  <= lb_wdata[15:0];
            12'h032: stream_dest_ip         <= lb_wdata;
            12'h033: stream_dest_port       <= lb_wdata[15:0];
            12'h034: stream_ip_cksum        <= lb_wdata[15:0];
            // Configuration flash transport (0x044 len; 0x045 go is a wire;
            // buffer 0x800-0x87F is written inside flash_spi via flash_buf_we)
            12'h044: flash_len <= lb_wdata[9:0];
            12'h110: spi_cmd_addr <= lb_wdata[15:0];
            12'h111: spi_cmd_data <= lb_wdata[15:0];
            12'h112: cmd_trig_pending <= 1'b1;
            12'h114: spi_cmd_data2 <= lb_wdata[15:0];
            // ADC registers
            12'h204: adc_gain   <= lb_wdata[3:0];
            12'h205: iir_enable <= lb_wdata[1:0];
            12'h206: iir_a1[0][31:0]  <= lb_wdata;
            12'h207: iir_a1[0][34:32] <= lb_wdata[2:0];
            12'h208: iir_b0[0][31:0]  <= lb_wdata;
            12'h209: iir_b0[0][34:32] <= lb_wdata[2:0];
            12'h20A: iir_b1[0][31:0]  <= lb_wdata;
            12'h20B: iir_b1[0][34:32] <= lb_wdata[2:0];
            12'h20C: iir_a1[1][31:0]  <= lb_wdata;
            12'h20D: iir_a1[1][34:32] <= lb_wdata[2:0];
            12'h20E: iir_b0[1][31:0]  <= lb_wdata;
            12'h20F: iir_b0[1][34:32] <= lb_wdata[2:0];
            12'h210: iir_b1[1][31:0]  <= lb_wdata;
            12'h211: iir_b1[1][34:32] <= lb_wdata[2:0];
            // LockIn registers (0x600)
            12'h600: li_input_sel <= lb_wdata[0];
            12'h601: li_pinc <= lb_wdata[23:0];
            12'h602: li_poff <= lb_wdata[23:0];
            12'h610: li_iir0_on        <= lb_wdata[0];
            12'h611: li_iir0_a1[31:0]  <= lb_wdata;
            12'h612: li_iir0_a1[34:32] <= lb_wdata[2:0];
            12'h613: li_iir0_a2[31:0]  <= lb_wdata;
            12'h614: li_iir0_a2[34:32] <= lb_wdata[2:0];
            12'h615: li_iir0_b0[31:0]  <= lb_wdata;
            12'h616: li_iir0_b0[34:32] <= lb_wdata[2:0];
            12'h617: li_iir0_b1[31:0]  <= lb_wdata;
            12'h618: li_iir0_b1[34:32] <= lb_wdata[2:0];
            12'h619: li_iir0_b2[31:0]  <= lb_wdata;
            12'h61A: li_iir0_b2[34:32] <= lb_wdata[2:0];
            12'h61B: li_iir1_on        <= lb_wdata[0];
            12'h61C: li_iir1_a1[31:0]  <= lb_wdata;
            12'h61D: li_iir1_a1[34:32] <= lb_wdata[2:0];
            12'h61E: li_iir1_a2[31:0]  <= lb_wdata;
            12'h61F: li_iir1_a2[34:32] <= lb_wdata[2:0];
            12'h620: li_iir1_b0[31:0]  <= lb_wdata;
            12'h621: li_iir1_b0[34:32] <= lb_wdata[2:0];
            12'h622: li_iir1_b1[31:0]  <= lb_wdata;
            12'h623: li_iir1_b1[34:32] <= lb_wdata[2:0];
            12'h624: li_iir1_b2[31:0]  <= lb_wdata;
            12'h625: li_iir1_b2[34:32] <= lb_wdata[2:0];
            // PhaseDetector registers (0x700)
            12'h700: pd_input_sel  <= lb_wdata[0];
            12'h701: pd_use_ext_clk <= lb_wdata[0];
            12'h702: pd_pinc       <= lb_wdata;
            12'h710: pd_lp_on        <= lb_wdata[0];
            12'h711: pd_lp_a1[31:0]  <= lb_wdata;
            12'h712: pd_lp_a1[34:32] <= lb_wdata[2:0];
            12'h713: pd_lp_b0[31:0]  <= lb_wdata;
            12'h714: pd_lp_b0[34:32] <= lb_wdata[2:0];
            default: ;
        endcase
    end

    // Channel register writes (0x300-0x5FF)
    if (ch_wr) begin
        case (ch_off)
            // Control
            8'h00: ch_servo_on[ch_sel]     <= lb_wdata[0];
            8'h01: ch_input_mux[ch_sel]    <= lb_wdata[3:0];
            8'h02: ch_offset[ch_sel]       <= lb_wdata[15:0];
            8'h03: ch_limit_min[ch_sel]    <= lb_wdata[15:0];
            8'h04: ch_limit_max[ch_sel]    <= lb_wdata[15:0];
            8'h05: ch_limit_center[ch_sel] <= lb_wdata[0];
            // IIR0
            8'h10: ch_iir0_on[ch_sel]        <= lb_wdata[0];
            8'h11: ch_iir0_a1[ch_sel][31:0]  <= lb_wdata;
            8'h12: ch_iir0_a1[ch_sel][34:32] <= lb_wdata[2:0];
            8'h13: ch_iir0_a2[ch_sel][31:0]  <= lb_wdata;
            8'h14: ch_iir0_a2[ch_sel][34:32] <= lb_wdata[2:0];
            8'h15: ch_iir0_b0[ch_sel][31:0]  <= lb_wdata;
            8'h16: ch_iir0_b0[ch_sel][34:32] <= lb_wdata[2:0];
            8'h17: ch_iir0_b1[ch_sel][31:0]  <= lb_wdata;
            8'h18: ch_iir0_b1[ch_sel][34:32] <= lb_wdata[2:0];
            8'h19: ch_iir0_b2[ch_sel][31:0]  <= lb_wdata;
            8'h1A: ch_iir0_b2[ch_sel][34:32] <= lb_wdata[2:0];
            // IIR1
            8'h1B: ch_iir1_on[ch_sel]        <= lb_wdata[0];
            8'h1C: ch_iir1_a1[ch_sel][31:0]  <= lb_wdata;
            8'h1D: ch_iir1_a1[ch_sel][34:32] <= lb_wdata[2:0];
            8'h1E: ch_iir1_b0[ch_sel][31:0]  <= lb_wdata;
            8'h1F: ch_iir1_b0[ch_sel][34:32] <= lb_wdata[2:0];
            8'h20: ch_iir1_b1[ch_sel][31:0]  <= lb_wdata;
            8'h21: ch_iir1_b1[ch_sel][34:32] <= lb_wdata[2:0];
            // IIR2
            8'h22: ch_iir2_on[ch_sel]        <= lb_wdata[0];
            8'h23: ch_iir2_a1[ch_sel][31:0]  <= lb_wdata;
            8'h24: ch_iir2_a1[ch_sel][34:32] <= lb_wdata[2:0];
            8'h25: ch_iir2_b0[ch_sel][31:0]  <= lb_wdata;
            8'h26: ch_iir2_b0[ch_sel][34:32] <= lb_wdata[2:0];
            8'h27: ch_iir2_b1[ch_sel][31:0]  <= lb_wdata;
            8'h28: ch_iir2_b1[ch_sel][34:32] <= lb_wdata[2:0];
            // IIR3
            8'h29: ch_iir3_on[ch_sel]        <= lb_wdata[0];
            8'h2A: ch_iir3_a1[ch_sel][31:0]  <= lb_wdata;
            8'h2B: ch_iir3_a1[ch_sel][34:32] <= lb_wdata[2:0];
            8'h2C: ch_iir3_b0[ch_sel][31:0]  <= lb_wdata;
            8'h2D: ch_iir3_b0[ch_sel][34:32] <= lb_wdata[2:0];
            8'h2E: ch_iir3_b1[ch_sel][31:0]  <= lb_wdata;
            8'h2F: ch_iir3_b1[ch_sel][34:32] <= lb_wdata[2:0];
            // Sweep
            8'h30: ch_sweep_on[ch_sel]       <= lb_wdata[0];
            8'h31: ch_sweep_min[ch_sel]      <= lb_wdata[15:0];
            8'h32: ch_sweep_max[ch_sel]      <= lb_wdata[15:0];
            8'h33: ch_sweep_step[ch_sel]     <= lb_wdata;
            // Relock
            8'h34: ch_relock_on[ch_sel]      <= lb_wdata[0];
            8'h35: ch_relock_sel[ch_sel]     <= lb_wdata[3:0];
            8'h36: ch_relock_min[ch_sel]     <= lb_wdata[15:0];
            8'h37: ch_relock_max[ch_sel]     <= lb_wdata[15:0];
            8'h38: ch_relock_step[ch_sel]    <= lb_wdata;
            // DigitalDelay
            8'h39: ch_hold_source[ch_sel]    <= lb_wdata[4:0];
            8'h3A: ch_delay_fall[ch_sel]     <= lb_wdata;
            8'h3B: ch_delay_rise[ch_sel]     <= lb_wdata;
            // Modulation
            8'h3C: ch_lo_shift[ch_sel]       <= lb_wdata[4:0];
            default: ;
        endcase
    end

    // Read mux: channel register readback
    case (ch_off)
        8'h00: ch_rd_data <= {31'd0, ch_servo_on[ch_sel]};
        8'h01: ch_rd_data <= {28'd0, ch_input_mux[ch_sel]};
        8'h02: ch_rd_data <= {{16{ch_offset[ch_sel][15]}}, ch_offset[ch_sel]};
        8'h03: ch_rd_data <= {{16{ch_limit_min[ch_sel][15]}}, ch_limit_min[ch_sel]};
        8'h04: ch_rd_data <= {{16{ch_limit_max[ch_sel][15]}}, ch_limit_max[ch_sel]};
        8'h05: ch_rd_data <= {31'd0, ch_limit_center[ch_sel]};
        8'h10: ch_rd_data <= {31'd0, ch_iir0_on[ch_sel]};
        8'h11: ch_rd_data <= ch_iir0_a1[ch_sel][31:0];
        8'h12: ch_rd_data <= {29'd0, ch_iir0_a1[ch_sel][34:32]};
        8'h13: ch_rd_data <= ch_iir0_a2[ch_sel][31:0];
        8'h14: ch_rd_data <= {29'd0, ch_iir0_a2[ch_sel][34:32]};
        8'h15: ch_rd_data <= ch_iir0_b0[ch_sel][31:0];
        8'h16: ch_rd_data <= {29'd0, ch_iir0_b0[ch_sel][34:32]};
        8'h17: ch_rd_data <= ch_iir0_b1[ch_sel][31:0];
        8'h18: ch_rd_data <= {29'd0, ch_iir0_b1[ch_sel][34:32]};
        8'h19: ch_rd_data <= ch_iir0_b2[ch_sel][31:0];
        8'h1A: ch_rd_data <= {29'd0, ch_iir0_b2[ch_sel][34:32]};
        8'h1B: ch_rd_data <= {31'd0, ch_iir1_on[ch_sel]};
        8'h1C: ch_rd_data <= ch_iir1_a1[ch_sel][31:0];
        8'h1D: ch_rd_data <= {29'd0, ch_iir1_a1[ch_sel][34:32]};
        8'h1E: ch_rd_data <= ch_iir1_b0[ch_sel][31:0];
        8'h1F: ch_rd_data <= {29'd0, ch_iir1_b0[ch_sel][34:32]};
        8'h20: ch_rd_data <= ch_iir1_b1[ch_sel][31:0];
        8'h21: ch_rd_data <= {29'd0, ch_iir1_b1[ch_sel][34:32]};
        8'h22: ch_rd_data <= {31'd0, ch_iir2_on[ch_sel]};
        8'h23: ch_rd_data <= ch_iir2_a1[ch_sel][31:0];
        8'h24: ch_rd_data <= {29'd0, ch_iir2_a1[ch_sel][34:32]};
        8'h25: ch_rd_data <= ch_iir2_b0[ch_sel][31:0];
        8'h26: ch_rd_data <= {29'd0, ch_iir2_b0[ch_sel][34:32]};
        8'h27: ch_rd_data <= ch_iir2_b1[ch_sel][31:0];
        8'h28: ch_rd_data <= {29'd0, ch_iir2_b1[ch_sel][34:32]};
        8'h29: ch_rd_data <= {31'd0, ch_iir3_on[ch_sel]};
        8'h2A: ch_rd_data <= ch_iir3_a1[ch_sel][31:0];
        8'h2B: ch_rd_data <= {29'd0, ch_iir3_a1[ch_sel][34:32]};
        8'h2C: ch_rd_data <= ch_iir3_b0[ch_sel][31:0];
        8'h2D: ch_rd_data <= {29'd0, ch_iir3_b0[ch_sel][34:32]};
        8'h2E: ch_rd_data <= ch_iir3_b1[ch_sel][31:0];
        8'h2F: ch_rd_data <= {29'd0, ch_iir3_b1[ch_sel][34:32]};
        8'h30: ch_rd_data <= {31'd0, ch_sweep_on[ch_sel]};
        8'h31: ch_rd_data <= {{16{ch_sweep_min[ch_sel][15]}}, ch_sweep_min[ch_sel]};
        8'h32: ch_rd_data <= {{16{ch_sweep_max[ch_sel][15]}}, ch_sweep_max[ch_sel]};
        8'h33: ch_rd_data <= ch_sweep_step[ch_sel];
        8'h34: ch_rd_data <= {31'd0, ch_relock_on[ch_sel]};
        8'h35: ch_rd_data <= {28'd0, ch_relock_sel[ch_sel]};
        8'h36: ch_rd_data <= {{16{ch_relock_min[ch_sel][15]}}, ch_relock_min[ch_sel]};
        8'h37: ch_rd_data <= {{16{ch_relock_max[ch_sel][15]}}, ch_relock_max[ch_sel]};
        8'h38: ch_rd_data <= ch_relock_step[ch_sel];
        8'h39: ch_rd_data <= {27'd0, ch_hold_source[ch_sel]};
        8'h3A: ch_rd_data <= ch_delay_fall[ch_sel];
        8'h3B: ch_rd_data <= ch_delay_rise[ch_sel];
        8'h3C: ch_rd_data <= {27'd0, ch_lo_shift[ch_sel]};
        8'h3E: ch_rd_data <= {{8{DACin[ch_sel][SIGNAL_SIZE-1]}}, DACin[ch_sel]};
        8'h3F: ch_rd_data <= {29'd0, ch_relock_hold[ch_sel], ch_railed[ch_sel]};
        default: ch_rd_data <= 32'hDEAD_DEAD;
    endcase

    // Read mux: LockIn registers
    case (lb_addr[7:0])
        8'h00: li_rd_data <= {31'd0, li_input_sel};
        8'h01: li_rd_data <= {8'd0, li_pinc};
        8'h02: li_rd_data <= {{8{li_poff[23]}}, li_poff};
        8'h10: li_rd_data <= {31'd0, li_iir0_on};
        8'h11: li_rd_data <= li_iir0_a1[31:0];
        8'h12: li_rd_data <= {29'd0, li_iir0_a1[34:32]};
        8'h13: li_rd_data <= li_iir0_a2[31:0];
        8'h14: li_rd_data <= {29'd0, li_iir0_a2[34:32]};
        8'h15: li_rd_data <= li_iir0_b0[31:0];
        8'h16: li_rd_data <= {29'd0, li_iir0_b0[34:32]};
        8'h17: li_rd_data <= li_iir0_b1[31:0];
        8'h18: li_rd_data <= {29'd0, li_iir0_b1[34:32]};
        8'h19: li_rd_data <= li_iir0_b2[31:0];
        8'h1A: li_rd_data <= {29'd0, li_iir0_b2[34:32]};
        8'h1B: li_rd_data <= {31'd0, li_iir1_on};
        8'h1C: li_rd_data <= li_iir1_a1[31:0];
        8'h1D: li_rd_data <= {29'd0, li_iir1_a1[34:32]};
        8'h1E: li_rd_data <= li_iir1_a2[31:0];
        8'h1F: li_rd_data <= {29'd0, li_iir1_a2[34:32]};
        8'h20: li_rd_data <= li_iir1_b0[31:0];
        8'h21: li_rd_data <= {29'd0, li_iir1_b0[34:32]};
        8'h22: li_rd_data <= li_iir1_b1[31:0];
        8'h23: li_rd_data <= {29'd0, li_iir1_b1[34:32]};
        8'h24: li_rd_data <= li_iir1_b2[31:0];
        8'h25: li_rd_data <= {29'd0, li_iir1_b2[34:32]};
        8'h30: li_rd_data <= {{8{LOCKINout[SIGNAL_SIZE-1]}}, LOCKINout};
        8'h31: li_rd_data <= {8'd0, LOCKINlo};
        default: li_rd_data <= 32'hDEAD_DEAD;
    endcase

    // Read mux: PhaseDetector registers
    case (lb_addr[7:0])
        8'h00: pd_rd_data <= {31'd0, pd_input_sel};
        8'h01: pd_rd_data <= {31'd0, pd_use_ext_clk};
        8'h02: pd_rd_data <= pd_pinc;
        8'h10: pd_rd_data <= {31'd0, pd_lp_on};
        8'h11: pd_rd_data <= pd_lp_a1[31:0];
        8'h12: pd_rd_data <= {29'd0, pd_lp_a1[34:32]};
        8'h13: pd_rd_data <= pd_lp_b0[31:0];
        8'h14: pd_rd_data <= {29'd0, pd_lp_b0[34:32]};
        8'h30: pd_rd_data <= PHASEDETraw;
        default: pd_rd_data <= 32'hDEAD_DEAD;
    endcase

    // Read mux: global registers
    case (lb_addr[11:0])
        12'h000: rd_pipe[0] <= scratch0;
        12'h001: rd_pipe[0] <= scratch1;
        12'h002: rd_pipe[0] <= {24'd0, led_reg};
        12'h003: rd_pipe[0] <= {29'd0, tx_phase_reg};
        12'h004: rd_pipe[0] <= {29'd0, read_delay};
        12'h010: rd_pipe[0] <= rx_pkt_count;
        12'h011: rd_pipe[0] <= tx_pkt_count;
        12'h012: rd_pipe[0] <= uptime;
        12'h020: rd_pipe[0] <= 32'h0000_0202;  // FW ID: +DOUT sweep-sync source select
        12'h021: rd_pipe[0] <= {29'd0, boot_done, net_recovery, eth_clk_locked};
        12'h022: rd_pipe[0] <= {26'd0, dout_src};
        12'h030: rd_pipe[0] <= stream_dest_mac[47:16];
        12'h031: rd_pipe[0] <= {16'd0, stream_dest_mac[15:0]};
        12'h032: rd_pipe[0] <= stream_dest_ip;
        12'h033: rd_pipe[0] <= {16'd0, stream_dest_port};
        12'h034: rd_pipe[0] <= {16'd0, stream_ip_cksum};
        12'h044: rd_pipe[0] <= {22'd0, flash_len};
        12'h046: rd_pipe[0] <= {31'd0, flash_busy};
        12'h047: rd_pipe[0] <= {16'd0, flash_sck_count};   // diag: SCK edges last xfer
        12'h100: rd_pipe[0] <= {{8{dac0_value[23]}}, dac0_value};
        12'h101: rd_pipe[0] <= {{8{dac1_value[23]}}, dac1_value};
        12'h102: rd_pipe[0] <= {{8{dac2_value[23]}}, dac2_value};
        12'h103: rd_pipe[0] <= {28'd0, dac_gain};
        12'h104: rd_pipe[0] <= {31'd0, ramp_enable};
        12'h110: rd_pipe[0] <= {16'd0, spi_cmd_addr};
        12'h111: rd_pipe[0] <= {16'd0, spi_readback};
        12'h112: rd_pipe[0] <= {31'd0, cmd_trig_pending};
        12'h113: rd_pipe[0] <= {31'd0, ad9783_pll_locked};
        12'h114: rd_pipe[0] <= {16'd0, spi_cmd_data2};
        12'h115: rd_pipe[0] <= {{16{TRANSFERsin[15]}}, TRANSFERsin};
        12'h116: rd_pipe[0] <= {{16{TRANSFERcos[15]}}, TRANSFERcos};
        12'h120: rd_pipe[0] <= {16'd0, ad5791_spi_count};
        12'h121: rd_pipe[0] <= {16'd0, ad9783_spi_count};
        12'h122: rd_pipe[0] <= {29'd0, AD5791_RST, AD5791_CLR, AD5791_SCS};
        12'h200: rd_pipe[0] <= {{16{ADCraw[0][15]}}, ADCraw[0]};
        12'h201: rd_pipe[0] <= {{16{ADCraw[1][15]}}, ADCraw[1]};
        12'h202: rd_pipe[0] <= {{8{ADCout[0][23]}}, ADCout[0]};
        12'h203: rd_pipe[0] <= {{8{ADCout[1][23]}}, ADCout[1]};
        12'h204: rd_pipe[0] <= {28'd0, adc_gain};
        12'h205: rd_pipe[0] <= {30'd0, iir_enable};
        12'h206: rd_pipe[0] <= iir_a1[0][31:0];
        12'h207: rd_pipe[0] <= {29'd0, iir_a1[0][34:32]};
        12'h208: rd_pipe[0] <= iir_b0[0][31:0];
        12'h209: rd_pipe[0] <= {29'd0, iir_b0[0][34:32]};
        12'h20A: rd_pipe[0] <= iir_b1[0][31:0];
        12'h20B: rd_pipe[0] <= {29'd0, iir_b1[0][34:32]};
        12'h20C: rd_pipe[0] <= iir_a1[1][31:0];
        12'h20D: rd_pipe[0] <= {29'd0, iir_a1[1][34:32]};
        12'h20E: rd_pipe[0] <= iir_b0[1][31:0];
        12'h20F: rd_pipe[0] <= {29'd0, iir_b0[1][34:32]};
        12'h210: rd_pipe[0] <= iir_b1[1][31:0];
        12'h211: rd_pipe[0] <= {29'd0, iir_b1[1][34:32]};
        12'h212: rd_pipe[0] <= {28'd0, FR_out};
        default: begin
            if (lb_addr[11:8] >= 4'h3 && lb_addr[11:8] <= 4'h5)
                rd_pipe[0] <= ch_rd_data;
            else if (lb_addr[11:8] == 4'h6)
                rd_pipe[0] <= li_rd_data;
            else if (lb_addr[11:8] == 4'h7)
                rd_pipe[0] <= pd_rd_data;
            else if (lb_addr[11:7] == 5'b10000)  // 0x800-0x87F flash buffer
                rd_pipe[0] <= flash_buf_rdata;
            else
                rd_pipe[0] <= 32'hDEAD_DEAD;
        end
    endcase

    // Shift pipeline
    for (pi = 1; pi < 8; pi = pi + 1)
        rd_pipe[pi] <= rd_pipe[pi-1];

    // Select tap
    lb_rdata <= rd_pipe[read_delay];
end

///////////////////////////////////////////////////////////////////////////////
// Shared SPI command interface (cmd_trig CDC: clk_12p5mhz -> clk1)
///////////////////////////////////////////////////////////////////////////////

reg [1:0] trig_sync = 2'b0;
reg       cmd_trig = 1'b0;

always @(posedge clk1) begin
    trig_sync <= {trig_sync[0], cmd_trig_pending};
    cmd_trig  <= trig_sync[0] && !trig_sync[1];
end

reg [1:0] trig_done_sync = 2'b0;
always @(posedge clk_12p5mhz) begin
    trig_done_sync <= {trig_done_sync[0], trig_sync[1]};
end
assign cmd_trig_clear = trig_done_sync[1];

///////////////////////////////////////////////////////////////////////////////
// Configuration flash: raw M25P32 SPI transport (lbus domain, no CDC)
//
// The flash_spi engine is shared between the boot-time net_config_loader (which
// owns it until boot_done) and the host (lbus) afterwards. The boot loader reads
// the FPGA's own MAC/IP from flash and writes them into the Badger ip_mem.
///////////////////////////////////////////////////////////////////////////////

// (loader/arbitration wires declared up in the Badger section)
// flash_spi control mux: loader owns the engine until boot_done, then the host
wire [6:0]  fs_buf_addr  = boot_done ? lb_addr[6:0] : ldr_buf_addr;
wire [31:0] fs_buf_wdata = boot_done ? lb_wdata     : ldr_buf_wdata;
wire        fs_buf_we    = boot_done ? flash_buf_we : ldr_buf_we;
wire [9:0]  fs_len       = boot_done ? flash_len    : ldr_len;
wire        fs_go        = boot_done ? flash_go     : ldr_go;

flash_spi #(
    .CLK_DIV(8'd2)   // clk_12p5mhz / 4 ~= 3.1 MHz SCK
) flash_spi_inst (
    .clk(clk_12p5mhz),
    .rst(rst_125),
    .buf_addr(fs_buf_addr),
    .buf_wdata(fs_buf_wdata),
    .buf_we(fs_buf_we),
    .buf_rdata(flash_buf_rdata),
    .len(fs_len),
    .go(fs_go),
    .busy(flash_busy),
    .sck_count(flash_sck_count),
    .spi_scs(flash_scs),
    .spi_sck(flash_sck),
    .spi_sdo(flash_sdi),   // FPGA MOSI -> flash data in
    .spi_sdi(flash_sdo)    // flash data out -> FPGA MISO
);

net_config_loader #(
    .FLASH_ADDR(24'h3D0000)   // sector 61, separate from servo configs
) net_config_loader_inst (
    .clk(clk_12p5mhz),
    .rst(rst_125),
    .lb_drive(loop_drive),
    .lb_test_active(loop_active),
    .lb_sense(DIN[1]),        // recovery loopback: jumper DOUT[1] -> DIN[1]
    .fs_buf_addr(ldr_buf_addr),
    .fs_buf_wdata(ldr_buf_wdata),
    .fs_buf_we(ldr_buf_we),
    .fs_len(ldr_len),
    .fs_go(ldr_go),
    .fs_buf_rdata(flash_buf_rdata),
    .fs_busy(flash_busy),
    .cfg_a(ncfg_a),
    .cfg_d(ncfg_d),
    .cfg_s(ncfg_s),
    .boot_done(boot_done),
    .recovery_active(net_recovery)
);

// Recovery loopback drives DOUT[1] during the boot test, then it reverts to
// the normal channel-1 relock-hold status output.
assign DOUT[1] = loop_active ? loop_drive : DOUT_f[1];

///////////////////////////////////////////////////////////////////////////////
// ADC hardware
///////////////////////////////////////////////////////////////////////////////

wire signed [15:0]            ADCraw[0:1];
wire signed [SIGNAL_SIZE-1:0] ADCout[0:1];
wire [3:0]                    FR_out;

// CDC: input PGA gain from clk_12p5mhz to clk1 (quasi-static)
reg [1:0] adc_gain0_clk1 = 2'd0;
reg [1:0] adc_gain1_clk1 = 2'd0;
always @(posedge clk1) begin
    adc_gain0_clk1 <= adc_gain[1:0];
    adc_gain1_clk1 <= adc_gain[3:2];
end

AD8251x2 AD8251x2_in (
    .clk_in(clk1),
    .rst_in(rst),
    .gain0_in(2'b11 - adc_gain0_clk1),
    .gain1_in(2'b11 - adc_gain1_clk1),
    .A0_out(AD8251_IN_A0),
    .A1_out(AD8251_IN_A1),
    .WR0_out(AD8251_IN_WR0),
    .WR1_out(AD8251_IN_WR1)
);

LTC2195 LTC2195_inst (
    .clk_in(clk1),
    .rst_in(rst),
    .cmd_trig_in(cmd_trig),
    .cmd_addr_in(spi_cmd_addr),
    .cmd_data_in(spi_cmd_data),
    .spi_scs_out(LTC2195_SCS),
    .spi_sck_out(LTC2195_SCK),
    .spi_sdo_out(LTC2195_SDI),
    .spi_sdi_in(LTC2195_SDO),
    .ENC_out_p(LTC2195_ENC_P),
    .ENC_out_n(LTC2195_ENC_N),
    .FR_in_p(LTC2195_FR_P),
    .FR_in_n(LTC2195_FR_N),
    .DCO_in_p(LTC2195_DCO_P),
    .DCO_in_n(LTC2195_DCO_N),
    .D0_in_p(LTC2195_D0_P),
    .D0_in_n(LTC2195_D0_N),
    .D1_in_p(LTC2195_D1_P),
    .D1_in_n(LTC2195_D1_N),
    .ADC0_out(ADCraw[0]),
    .ADC1_out(ADCraw[1]),
    .FR_out(FR_out)
);

// CDC: IIR coefficients from clk_12p5mhz to clk_dsp (quasi-static)
reg [1:0]  iir_enable_dsp = 2'b0;
reg [34:0] iir_a1_dsp [0:1];
reg [34:0] iir_b0_dsp [0:1];
reg [34:0] iir_b1_dsp [0:1];

initial begin
    iir_a1_dsp[0] = 35'd0; iir_a1_dsp[1] = 35'd0;
    iir_b0_dsp[0] = 35'd0; iir_b0_dsp[1] = 35'd0;
    iir_b1_dsp[0] = 35'd0; iir_b1_dsp[1] = 35'd0;
end

always @(posedge clk_dsp) begin
    iir_enable_dsp <= iir_enable;
    iir_a1_dsp[0]  <= iir_a1[0];
    iir_b0_dsp[0]  <= iir_b0[0];
    iir_b1_dsp[0]  <= iir_b1[0];
    iir_a1_dsp[1]  <= iir_a1[1];
    iir_b0_dsp[1]  <= iir_b0[1];
    iir_b1_dsp[1]  <= iir_b1[1];
end

genvar adc_index;
generate for (adc_index = 0; adc_index < 2; adc_index = adc_index + 1) begin: adcs
`ifdef BYPASS_IIR
    reg signed [SIGNAL_SIZE-1:0] adc_pass;
    always @(posedge clk_dsp) adc_pass <= ADCraw[adc_index] <<< (SIGNAL_SIZE - 16);
    assign ADCout[adc_index] = adc_pass;
`else
    IIRfilter1stOrder #(
        .SIGNAL_IN_SIZE(16),
        .SIGNAL_OUT_SIZE(SIGNAL_SIZE)
    ) IIR0 (
        .clk_in(clk_dsp),
        .on_in(iir_enable_dsp[adc_index]),
        .a1_in(iir_a1_dsp[adc_index]),
        .b0_in(iir_b0_dsp[adc_index]),
        .b1_in(iir_b1_dsp[adc_index]),
        .signal_in(ADCraw[adc_index]),
        .signal_out(ADCout[adc_index])
    );
`endif
end
endgenerate

// ADC difference (for input mux option)
reg signed [SIGNAL_SIZE-1:0] ADCdiff;
always @(posedge clk_dsp) ADCdiff <= ADCout[0] - ADCout[1];

///////////////////////////////////////////////////////////////////////////////
// Servo loop DSP chain (3 channels, clk_dsp domain)
///////////////////////////////////////////////////////////////////////////////

// Signal wires for LockIn, PhaseDetector, TransferFunction
wire signed [SIGNAL_SIZE-1:0] LOCKINout;
wire signed [SIGNAL_SIZE-1:0] PHASEDETout;
wire signed [23:0]            LOCKINlo;
wire signed [23:0]            TRANSFERmod [0:2];
wire signed [15:0]            TRANSFERsin, TRANSFERcos;
wire signed [31:0]            PHASEDETraw;

// External clock buffer and conditioning (for PhaseDetector)
wire ext_clk_10MHz_w = DIN[0];
reg [3:0] ext_clk_10MHz_f1;
reg ext_clk_10MHz_f2, ext_clk_10MHz;
always @(posedge clk1) begin
    ext_clk_10MHz_f1 <= {ext_clk_10MHz_f1[2:0], ext_clk_10MHz_w};
    ext_clk_10MHz_f2 <= ext_clk_10MHz_f1[3] & (!ext_clk_10MHz_f1[2]);
    ext_clk_10MHz <= ext_clk_10MHz_f2;
end

///////////////////////////////////////////////////////////////////////////////
// LockIn demodulator (clk_dsp domain)
///////////////////////////////////////////////////////////////////////////////

// CDC: LockIn registers from clk_12p5mhz to clk_dsp (quasi-static)
reg         dsp_li_input_sel = 1'b0;
reg  [23:0] dsp_li_pinc = 24'd0, dsp_li_poff = 24'd0;
reg         dsp_li_iir0_on = 1'b0;
reg  [34:0] dsp_li_iir0_a1 = 35'd0, dsp_li_iir0_a2 = 35'd0;
reg  [34:0] dsp_li_iir0_b0 = 35'd0, dsp_li_iir0_b1 = 35'd0, dsp_li_iir0_b2 = 35'd0;
reg         dsp_li_iir1_on = 1'b0;
reg  [34:0] dsp_li_iir1_a1 = 35'd0, dsp_li_iir1_a2 = 35'd0;
reg  [34:0] dsp_li_iir1_b0 = 35'd0, dsp_li_iir1_b1 = 35'd0, dsp_li_iir1_b2 = 35'd0;

always @(posedge clk_dsp) begin
    dsp_li_input_sel <= li_input_sel;
    dsp_li_pinc <= li_pinc;
    dsp_li_poff <= li_poff;
    dsp_li_iir0_on  <= li_iir0_on;
    dsp_li_iir0_a1  <= li_iir0_a1;  dsp_li_iir0_a2 <= li_iir0_a2;
    dsp_li_iir0_b0  <= li_iir0_b0;  dsp_li_iir0_b1 <= li_iir0_b1;
    dsp_li_iir0_b2  <= li_iir0_b2;
    dsp_li_iir1_on  <= li_iir1_on;
    dsp_li_iir1_a1  <= li_iir1_a1;  dsp_li_iir1_a2 <= li_iir1_a2;
    dsp_li_iir1_b0  <= li_iir1_b0;  dsp_li_iir1_b1 <= li_iir1_b1;
    dsp_li_iir1_b2  <= li_iir1_b2;
end

// LockIn input mux
reg signed [SIGNAL_SIZE-1:0] LOCKINin;
always @(posedge clk_dsp) begin
    case (dsp_li_input_sel)
        1'b0:    LOCKINin <= ADCout[0];
        1'b1:    LOCKINin <= ADCout[1];
        default: LOCKINin <= {SIGNAL_SIZE{1'b0}};
    endcase
end

// LockIn pre-filter (IIR 2nd order)
wire signed [15:0] LOCKIN0;

`ifdef BYPASS_IIR
assign LOCKIN0 = LOCKINin[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
`else
IIRfilter2ndOrderSlow #(
    .SIGNAL_IN_SIZE(SIGNAL_SIZE),
    .SIGNAL_OUT_SIZE(16)
) LI_IIR0 (
    .clk_in(clk_dsp),
    .rst_in(rst_dsp),
    .on_in(dsp_li_iir0_on),
    .a1_in(dsp_li_iir0_a1),
    .a2_in(dsp_li_iir0_a2),
    .b0_in(dsp_li_iir0_b0),
    .b1_in(dsp_li_iir0_b1),
    .b2_in(dsp_li_iir0_b2),
    .signal_in(LOCKINin),
    .signal_out(LOCKIN0)
);
`endif

// LockIn NCO mixer
wire signed [31:0] LOCKIN1;

LockIn LockIn_inst (
    .clk_in(clk_dsp),
    .rst_in(rst_dsp),
    .pinc_in(dsp_li_pinc),
    .poff_in(dsp_li_poff),
    .signal_in(LOCKIN0),
    .signal_out(LOCKIN1),
    .LO_out(LOCKINlo)
);

// LockIn post-filter (IIR 2nd order)
`ifdef BYPASS_IIR
assign LOCKINout = LOCKIN1[SIGNAL_SIZE-1:0];
`else
IIRfilter2ndOrderSlow #(
    .SIGNAL_IN_SIZE(32),
    .SIGNAL_OUT_SIZE(SIGNAL_SIZE)
) LI_IIR1 (
    .clk_in(clk_dsp),
    .rst_in(rst_dsp),
    .on_in(dsp_li_iir1_on),
    .a1_in(dsp_li_iir1_a1),
    .a2_in(dsp_li_iir1_a2),
    .b0_in(dsp_li_iir1_b0),
    .b1_in(dsp_li_iir1_b1),
    .b2_in(dsp_li_iir1_b2),
    .signal_in(LOCKIN1),
    .signal_out(LOCKINout)
);
`endif

///////////////////////////////////////////////////////////////////////////////
// PhaseDetector (dual clock: clk1 for PLL, clk_dsp for signal processing)
///////////////////////////////////////////////////////////////////////////////

// CDC: PhaseDetector registers from clk_12p5mhz to clk_dsp (quasi-static)
reg         dsp_pd_input_sel = 1'b0;
reg         dsp_pd_use_ext_clk = 1'b0;
reg  [31:0] dsp_pd_pinc = 32'd0;
reg         dsp_pd_lp_on = 1'b0;
reg  [34:0] dsp_pd_lp_a1 = 35'd0;
reg  [34:0] dsp_pd_lp_b0 = 35'd0;

always @(posedge clk_dsp) begin
    dsp_pd_input_sel   <= pd_input_sel;
    dsp_pd_use_ext_clk <= pd_use_ext_clk;
    dsp_pd_pinc        <= pd_pinc;
    dsp_pd_lp_on       <= pd_lp_on;
    dsp_pd_lp_a1       <= pd_lp_a1;
    dsp_pd_lp_b0       <= pd_lp_b0;
end

// PhaseDetector input mux
reg signed [15:0] PHASEDETin;
always @(posedge clk_dsp) begin
    case (dsp_pd_input_sel)
        1'b0:    PHASEDETin <= ADCout[0] >>> (SIGNAL_SIZE - 16);
        1'b1:    PHASEDETin <= ADCout[1] >>> (SIGNAL_SIZE - 16);
        default: PHASEDETin <= 16'b0;
    endcase
end

PhaseDetector #(
    .PHASE_OUT_SIZE(32)
) PhaseDetector_inst (
    .clk_in(clk1),
    .clk_dsp_in(clk_dsp),
    .rst_in(rst),
    .ext_clk_10MHz_in(ext_clk_10MHz),
    .use_ext_clk_in(dsp_pd_use_ext_clk),
    .pinc_in(dsp_pd_pinc),
    .on_in(dsp_pd_lp_on),
    .a1_in(dsp_pd_lp_a1),
    .b0_in(dsp_pd_lp_b0),
    .signal_in(PHASEDETin),
    .I_out(),
    .Q_out(),
    .phase_out(PHASEDETraw)
);

assign PHASEDETout = PHASEDETraw[SIGNAL_SIZE-1:0];

///////////////////////////////////////////////////////////////////////////////
// TransferFunction (clk1 domain, uses shared SPI command interface)
///////////////////////////////////////////////////////////////////////////////

TransferFunction TransferFunction_inst (
    .clk_in(clk1),
    .rst_in(rst),
    .cmd_trig_in(cmd_trig),
    .cmd_addr_in(spi_cmd_addr),
    .cmd_data1_in(spi_cmd_data),
    .cmd_data2_in(spi_cmd_data2),
    .sin_out(TRANSFERsin),
    .cos_out(TRANSFERcos),
    .mod0_out(TRANSFERmod[0]),
    .mod1_out(TRANSFERmod[1]),
    .mod2_out(TRANSFERmod[2])
);

// LED color parameters
localparam LED2off   = 2'b00;
localparam LED2red   = 2'b10;
localparam LED2green = 2'b01;

// Per-channel DSP chain
wire signed [SIGNAL_SIZE+1:0] SWEEPout       [0:2];
wire        [2:0]             sweep_rising_dsp;   // per-ch sweep sync (clk_dsp)
reg  signed [SIGNAL_SIZE-1:0] LOOPFILTERin   [0:2];
wire signed [SIGNAL_SIZE+1:0] LOOPFILTER0    [0:2];
wire signed [SIGNAL_SIZE+1:0] LOOPFILTER1    [0:2];
wire signed [SIGNAL_SIZE+1:0] LOOPFILTER2    [0:2];
wire signed [SIGNAL_SIZE+1:0] LOOPFILTER3    [0:2];
reg  signed [SIGNAL_SIZE+1:0] LOOPFILTERout  [0:2];
reg                           LOOPFILTERholdin [0:2];
wire                          LOOPFILTERhold [0:2];
reg  signed [15:0]            RELOCKin       [0:2];
wire signed [SIGNAL_SIZE+1:0] RELOCKout      [0:2];
wire                          RELOCKhold     [0:2];
wire                          RELOCKclear    [0:2];
reg  signed [SIGNAL_SIZE+3:0] MODsum         [0:2];
wire signed [SIGNAL_SIZE+3:0] LIMITin        [0:2];
wire        [1:0]             LIMITrailed    [0:2];
wire                          LIMITclear     [0:2];

// Expose railed/relock status for readback
assign ch_railed[0]      = LIMITrailed[0];
assign ch_railed[1]      = LIMITrailed[1];
assign ch_railed[2]      = LIMITrailed[2];
assign ch_relock_hold[0] = RELOCKhold[0];
assign ch_relock_hold[1] = RELOCKhold[1];
assign ch_relock_hold[2] = RELOCKhold[2];

// CDC: servo registers from clk_12p5mhz to clk_dsp (quasi-static)
// These are human-initiated writes, stable for millions of cycles.
reg         dsp_servo_on     [0:2];
reg  [3:0]  dsp_input_mux    [0:2];
reg  [15:0] dsp_offset       [0:2];
reg  [15:0] dsp_limit_min    [0:2];
reg  [15:0] dsp_limit_max    [0:2];
reg         dsp_limit_center [0:2];

reg         dsp_iir0_on  [0:2];
reg  [34:0] dsp_iir0_a1  [0:2]; reg [34:0] dsp_iir0_a2 [0:2];
reg  [34:0] dsp_iir0_b0  [0:2]; reg [34:0] dsp_iir0_b1 [0:2];
reg  [34:0] dsp_iir0_b2  [0:2];
reg         dsp_iir1_on  [0:2];
reg  [34:0] dsp_iir1_a1  [0:2];
reg  [34:0] dsp_iir1_b0  [0:2]; reg [34:0] dsp_iir1_b1 [0:2];
reg         dsp_iir2_on  [0:2];
reg  [34:0] dsp_iir2_a1  [0:2];
reg  [34:0] dsp_iir2_b0  [0:2]; reg [34:0] dsp_iir2_b1 [0:2];
reg         dsp_iir3_on  [0:2];
reg  [34:0] dsp_iir3_a1  [0:2];
reg  [34:0] dsp_iir3_b0  [0:2]; reg [34:0] dsp_iir3_b1 [0:2];

reg         dsp_sweep_on  [0:2];
reg  [15:0] dsp_sweep_min [0:2]; reg [15:0] dsp_sweep_max [0:2];
reg  [31:0] dsp_sweep_step [0:2];
reg         dsp_relock_on  [0:2];
reg  [3:0]  dsp_relock_sel [0:2];
reg  [15:0] dsp_relock_min [0:2]; reg [15:0] dsp_relock_max [0:2];
reg  [31:0] dsp_relock_step [0:2];
reg  [4:0]  dsp_hold_source [0:2];
reg  [31:0] dsp_delay_fall  [0:2]; reg [31:0] dsp_delay_rise [0:2];
reg  [4:0]  dsp_lo_shift    [0:2];

integer dsp_i;
initial begin
    for (dsp_i = 0; dsp_i < 3; dsp_i = dsp_i + 1) begin
        dsp_servo_on[dsp_i] = 1'b0; dsp_input_mux[dsp_i] = 4'd0;
        dsp_offset[dsp_i] = 16'd0;
        dsp_limit_min[dsp_i] = 16'h8000; dsp_limit_max[dsp_i] = 16'h7FFF;
        dsp_limit_center[dsp_i] = 1'b0;
        dsp_iir0_on[dsp_i] = 1'b0;
        dsp_iir0_a1[dsp_i] = 35'd0; dsp_iir0_a2[dsp_i] = 35'd0;
        dsp_iir0_b0[dsp_i] = 35'd0; dsp_iir0_b1[dsp_i] = 35'd0;
        dsp_iir0_b2[dsp_i] = 35'd0;
        dsp_iir1_on[dsp_i] = 1'b0;
        dsp_iir1_a1[dsp_i] = 35'd0;
        dsp_iir1_b0[dsp_i] = 35'd0; dsp_iir1_b1[dsp_i] = 35'd0;
        dsp_iir2_on[dsp_i] = 1'b0;
        dsp_iir2_a1[dsp_i] = 35'd0;
        dsp_iir2_b0[dsp_i] = 35'd0; dsp_iir2_b1[dsp_i] = 35'd0;
        dsp_iir3_on[dsp_i] = 1'b0;
        dsp_iir3_a1[dsp_i] = 35'd0;
        dsp_iir3_b0[dsp_i] = 35'd0; dsp_iir3_b1[dsp_i] = 35'd0;
        dsp_sweep_on[dsp_i] = 1'b0;
        dsp_sweep_min[dsp_i] = 16'd0; dsp_sweep_max[dsp_i] = 16'd0;
        dsp_sweep_step[dsp_i] = 32'd0;
        dsp_relock_on[dsp_i] = 1'b0; dsp_relock_sel[dsp_i] = 4'd0;
        dsp_relock_min[dsp_i] = 16'd0; dsp_relock_max[dsp_i] = 16'd0;
        dsp_relock_step[dsp_i] = 32'd0;
        dsp_hold_source[dsp_i] = 5'd0;
        dsp_delay_fall[dsp_i] = 32'd0; dsp_delay_rise[dsp_i] = 32'd0;
        dsp_lo_shift[dsp_i] = 5'd0;
    end
end

// Mirror lbus registers into clk_dsp domain (quasi-static CDC)
integer cdc_i;
always @(posedge clk_dsp) begin
    for (cdc_i = 0; cdc_i < 3; cdc_i = cdc_i + 1) begin
        dsp_servo_on[cdc_i]     <= ch_servo_on[cdc_i];
        dsp_input_mux[cdc_i]    <= ch_input_mux[cdc_i];
        dsp_offset[cdc_i]       <= ch_offset[cdc_i];
        dsp_limit_min[cdc_i]    <= ch_limit_min[cdc_i];
        dsp_limit_max[cdc_i]    <= ch_limit_max[cdc_i];
        dsp_limit_center[cdc_i] <= ch_limit_center[cdc_i];
        dsp_iir0_on[cdc_i]  <= ch_iir0_on[cdc_i];
        dsp_iir0_a1[cdc_i]  <= ch_iir0_a1[cdc_i];
        dsp_iir0_a2[cdc_i]  <= ch_iir0_a2[cdc_i];
        dsp_iir0_b0[cdc_i]  <= ch_iir0_b0[cdc_i];
        dsp_iir0_b1[cdc_i]  <= ch_iir0_b1[cdc_i];
        dsp_iir0_b2[cdc_i]  <= ch_iir0_b2[cdc_i];
        dsp_iir1_on[cdc_i]  <= ch_iir1_on[cdc_i];
        dsp_iir1_a1[cdc_i]  <= ch_iir1_a1[cdc_i];
        dsp_iir1_b0[cdc_i]  <= ch_iir1_b0[cdc_i];
        dsp_iir1_b1[cdc_i]  <= ch_iir1_b1[cdc_i];
        dsp_iir2_on[cdc_i]  <= ch_iir2_on[cdc_i];
        dsp_iir2_a1[cdc_i]  <= ch_iir2_a1[cdc_i];
        dsp_iir2_b0[cdc_i]  <= ch_iir2_b0[cdc_i];
        dsp_iir2_b1[cdc_i]  <= ch_iir2_b1[cdc_i];
        dsp_iir3_on[cdc_i]  <= ch_iir3_on[cdc_i];
        dsp_iir3_a1[cdc_i]  <= ch_iir3_a1[cdc_i];
        dsp_iir3_b0[cdc_i]  <= ch_iir3_b0[cdc_i];
        dsp_iir3_b1[cdc_i]  <= ch_iir3_b1[cdc_i];
        dsp_sweep_on[cdc_i]   <= ch_sweep_on[cdc_i];
        dsp_sweep_min[cdc_i]  <= ch_sweep_min[cdc_i];
        dsp_sweep_max[cdc_i]  <= ch_sweep_max[cdc_i];
        dsp_sweep_step[cdc_i] <= ch_sweep_step[cdc_i];
        dsp_relock_on[cdc_i]   <= ch_relock_on[cdc_i];
        dsp_relock_sel[cdc_i]  <= ch_relock_sel[cdc_i];
        dsp_relock_min[cdc_i]  <= ch_relock_min[cdc_i];
        dsp_relock_max[cdc_i]  <= ch_relock_max[cdc_i];
        dsp_relock_step[cdc_i] <= ch_relock_step[cdc_i];
        dsp_hold_source[cdc_i] <= ch_hold_source[cdc_i];
        dsp_delay_fall[cdc_i]  <= ch_delay_fall[cdc_i];
        dsp_delay_rise[cdc_i]  <= ch_delay_rise[cdc_i];
        dsp_lo_shift[cdc_i]    <= ch_lo_shift[cdc_i];
    end
end

// Also need servo_on in clk1 domain for DAC mux
reg dsp_servo_on_clk1 [0:2];
initial begin
    dsp_servo_on_clk1[0] = 1'b0;
    dsp_servo_on_clk1[1] = 1'b0;
    dsp_servo_on_clk1[2] = 1'b0;
end
always @(posedge clk1) begin
    dsp_servo_on_clk1[0] <= ch_servo_on[0];
    dsp_servo_on_clk1[1] <= ch_servo_on[1];
    dsp_servo_on_clk1[2] <= ch_servo_on[2];
end

// Re-register DIN for hold/relock (per original design)
reg [2:0] DIN_f_hold   [0:2];
reg [2:0] DIN_f_relock [0:2];

genvar dac_index;
generate for (dac_index = 0; dac_index < 3; dac_index = dac_index + 1) begin: dacs

    always @(posedge clk_dsp) DIN_f_hold[dac_index]   <= DIN_f;
    always @(posedge clk_dsp) DIN_f_relock[dac_index]  <= DIN_f;

    // Sweep generator
    Sweep #(
        .SIGNAL_OUT_SIZE(SIGNAL_SIZE)
    ) SWEEP0 (
        .clk_in(clk_dsp),
        .on_in(dsp_sweep_on[dac_index]),
        .minval_in(dsp_sweep_min[dac_index]),
        .maxval_in(dsp_sweep_max[dac_index]),
        .stepsize_in(dsp_sweep_step[dac_index]),
        .signal_out(SWEEPout[dac_index]),
        .phase_out(sweep_rising_dsp[dac_index])
    );

    // Input mux: select error signal source and apply offset
    always @(posedge clk_dsp) begin
        case (dsp_input_mux[dac_index])
            {3'h0, 1'b0}: LOOPFILTERin[dac_index] <=   ADCout[0] - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16));
            {3'h0, 1'b1}: LOOPFILTERin[dac_index] <= -(ADCout[0] - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16)));
            {3'h1, 1'b0}: LOOPFILTERin[dac_index] <=   ADCout[1] - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16));
            {3'h1, 1'b1}: LOOPFILTERin[dac_index] <= -(ADCout[1] - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16)));
            {3'h2, 1'b0}: LOOPFILTERin[dac_index] <=   ADCdiff   - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16));
            {3'h2, 1'b1}: LOOPFILTERin[dac_index] <= -(ADCdiff   - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16)));
            {3'h3, 1'b0}: LOOPFILTERin[dac_index] <=   LOCKINout - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16));
            {3'h3, 1'b1}: LOOPFILTERin[dac_index] <= -(LOCKINout - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16)));
            {3'h4, 1'b0}: LOOPFILTERin[dac_index] <=   PHASEDETout - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16));
            {3'h4, 1'b1}: LOOPFILTERin[dac_index] <= -(PHASEDETout - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16)));
            {3'h5, 1'b0}: LOOPFILTERin[dac_index] <=   DACin[0]  - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16));
            {3'h5, 1'b1}: LOOPFILTERin[dac_index] <= -(DACin[0]  - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16)));
            {3'h6, 1'b0}: LOOPFILTERin[dac_index] <=   DACin[1]  - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16));
            {3'h6, 1'b1}: LOOPFILTERin[dac_index] <= -(DACin[1]  - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16)));
            {3'h7, 1'b0}: LOOPFILTERin[dac_index] <=   DACin[2]  - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16));
            {3'h7, 1'b1}: LOOPFILTERin[dac_index] <= -(DACin[2]  - ($signed(dsp_offset[dac_index]) <<< (SIGNAL_SIZE - 16)));
            default:       LOOPFILTERin[dac_index] <= {SIGNAL_SIZE{1'b0}};
        endcase
    end

    // Hold source mux
    always @(posedge clk_dsp) begin
        case (dsp_hold_source[dac_index])
            {4'h0, 1'b1}: LOOPFILTERholdin[dac_index] <= RELOCKhold[0];
            {4'h1, 1'b1}: LOOPFILTERholdin[dac_index] <= RELOCKhold[1];
            {4'h2, 1'b1}: LOOPFILTERholdin[dac_index] <= RELOCKhold[2];
            {4'h3, 1'b1}: LOOPFILTERholdin[dac_index] <= DIN_f_hold[dac_index][0];
            {4'h4, 1'b1}: LOOPFILTERholdin[dac_index] <= DIN_f_hold[dac_index][1];
            {4'h5, 1'b1}: LOOPFILTERholdin[dac_index] <= DIN_f_hold[dac_index][2];
            {4'h6, 1'b1}: LOOPFILTERholdin[dac_index] <= !(DIN_f_hold[dac_index][0]);
            {4'h7, 1'b1}: LOOPFILTERholdin[dac_index] <= !(DIN_f_hold[dac_index][1]);
            {4'h8, 1'b1}: LOOPFILTERholdin[dac_index] <= !(DIN_f_hold[dac_index][2]);
            default:       LOOPFILTERholdin[dac_index] <= 1'b0;
        endcase
    end

    DigitalDelay DELAY0 (
        .clk_in(clk_dsp),
        .rst_in(rst_dsp),
        .falling_delay_in(dsp_delay_fall[dac_index]),
        .rising_delay_in(dsp_delay_rise[dac_index]),
        .signal_in(LOOPFILTERholdin[dac_index]),
        .signal_out(LOOPFILTERhold[dac_index])
    );

`ifdef BYPASS_IIR
    // Bypass all servo IIR filters: input passes straight to output
    assign LOOPFILTER0[dac_index] = {{2{LOOPFILTERin[dac_index][SIGNAL_SIZE-1]}},
                                     LOOPFILTERin[dac_index]};
    assign LOOPFILTER1[dac_index] = {(SIGNAL_SIZE+2){1'b0}};
    assign LOOPFILTER2[dac_index] = {(SIGNAL_SIZE+2){1'b0}};
    assign LOOPFILTER3[dac_index] = {(SIGNAL_SIZE+2){1'b0}};
    always @(posedge clk_dsp) LOOPFILTERout[dac_index] <= LOOPFILTER0[dac_index];
`else
    // IIR0: 2nd order anti-windup
    IIRfilter2ndOrderSlowAntiWindup #(
        .SIGNAL_IN_SIZE(SIGNAL_SIZE),
        .SIGNAL_OUT_SIZE(SIGNAL_SIZE)
    ) IIR0 (
        .clk_in(clk_dsp),
        .rst_in(rst_dsp),
        .on_in(dsp_servo_on[dac_index] && dsp_iir0_on[dac_index]
               && (!RELOCKclear[dac_index]) && (!LIMITclear[dac_index])),
        .a1_in(dsp_iir0_a1[dac_index]),
        .a2_in(dsp_iir0_a2[dac_index]),
        .b0_in(dsp_iir0_b0[dac_index]),
        .b1_in(dsp_iir0_b1[dac_index]),
        .b2_in(dsp_iir0_b2[dac_index]),
        .railed_in(LIMITrailed[dac_index]),
        .hold_in(LOOPFILTERhold[dac_index] || RELOCKhold[dac_index]),
        .signal_in(LOOPFILTERin[dac_index]),
        .signal_out(LOOPFILTER0[dac_index])
    );

    // IIR1: 1st order anti-windup
    IIRfilter1stOrderAntiWindup #(
        .SIGNAL_IN_SIZE(SIGNAL_SIZE),
        .SIGNAL_OUT_SIZE(SIGNAL_SIZE)
    ) IIR1 (
        .clk_in(clk_dsp),
        .on_in(dsp_servo_on[dac_index] && dsp_iir1_on[dac_index]
               && (!RELOCKclear[dac_index]) && (!LIMITclear[dac_index])),
        .a1_in(dsp_iir1_a1[dac_index]),
        .b0_in(dsp_iir1_b0[dac_index]),
        .b1_in(dsp_iir1_b1[dac_index]),
        .railed_in(LIMITrailed[dac_index]),
        .hold_in(LOOPFILTERhold[dac_index] || RELOCKhold[dac_index]),
        .signal_in(LOOPFILTER0[dac_index]),
        .signal_out(LOOPFILTER1[dac_index])
    );

    // IIR2 + IIR3: ch0 and ch1 only (extra filtering stages)
    if (dac_index < 2) begin : gen_iir23
        IIRfilter1stOrderAntiWindup #(
            .SIGNAL_IN_SIZE(SIGNAL_SIZE),
            .SIGNAL_OUT_SIZE(SIGNAL_SIZE)
        ) IIR2 (
            .clk_in(clk_dsp),
            .on_in(dsp_servo_on[dac_index] && dsp_iir2_on[dac_index]
                   && (!RELOCKclear[dac_index]) && (!LIMITclear[dac_index])),
            .a1_in(dsp_iir2_a1[dac_index]),
            .b0_in(dsp_iir2_b0[dac_index]),
            .b1_in(dsp_iir2_b1[dac_index]),
            .railed_in(LIMITrailed[dac_index]),
            .hold_in(LOOPFILTERhold[dac_index] || RELOCKhold[dac_index]),
            .signal_in(LOOPFILTER1[dac_index]),
            .signal_out(LOOPFILTER2[dac_index])
        );

        IIRfilter1stOrderAntiWindup #(
            .SIGNAL_IN_SIZE(SIGNAL_SIZE),
            .SIGNAL_OUT_SIZE(SIGNAL_SIZE)
        ) IIR3 (
            .clk_in(clk_dsp),
            .on_in(dsp_servo_on[dac_index] && dsp_iir3_on[dac_index]
                   && (!RELOCKclear[dac_index]) && (!LIMITclear[dac_index])),
            .a1_in(dsp_iir3_a1[dac_index]),
            .b0_in(dsp_iir3_b0[dac_index]),
            .b1_in(dsp_iir3_b1[dac_index]),
            .railed_in(LIMITrailed[dac_index]),
            .hold_in(LOOPFILTERhold[dac_index] || RELOCKhold[dac_index]),
            .signal_in(LOOPFILTER2[dac_index]),
            .signal_out(LOOPFILTER3[dac_index])
        );

        always @(posedge clk_dsp) begin
            case ({dsp_iir2_on[dac_index], dsp_iir3_on[dac_index]})
                2'b11:   LOOPFILTERout[dac_index] <= LOOPFILTER3[dac_index];
                2'b10:   LOOPFILTERout[dac_index] <= LOOPFILTER2[dac_index];
                default: LOOPFILTERout[dac_index] <= LOOPFILTER1[dac_index];
            endcase
        end
    end else begin : gen_iir23
        // ch2: no IIR2/IIR3, tie off unused wires
        assign LOOPFILTER2[dac_index] = {(SIGNAL_SIZE+2){1'b0}};
        assign LOOPFILTER3[dac_index] = {(SIGNAL_SIZE+2){1'b0}};

        always @(posedge clk_dsp) begin
            LOOPFILTERout[dac_index] <= LOOPFILTER1[dac_index];
        end
    end
`endif

    // Relock input mux
    always @(posedge clk_dsp) begin
        case (dsp_relock_sel[dac_index])
            4'h0:    RELOCKin[dac_index] <= ADCout[0][SIGNAL_SIZE-1:SIGNAL_SIZE-16];
            4'h1:    RELOCKin[dac_index] <= ADCout[1][SIGNAL_SIZE-1:SIGNAL_SIZE-16];
            4'h2:    RELOCKin[dac_index] <= ADCdiff[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
            4'h3:    RELOCKin[dac_index] <= LOCKINout[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
            4'h4:    RELOCKin[dac_index] <= PHASEDETout[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
            4'h5:    RELOCKin[dac_index] <= DACin[0][SIGNAL_SIZE-1:SIGNAL_SIZE-16];
            4'h6:    RELOCKin[dac_index] <= DACin[1][SIGNAL_SIZE-1:SIGNAL_SIZE-16];
            4'h7:    RELOCKin[dac_index] <= DACin[2][SIGNAL_SIZE-1:SIGNAL_SIZE-16];
            4'h8:    RELOCKin[dac_index] <= {1'b0, DIN_f_relock[dac_index][0], 14'b0};
            4'h9:    RELOCKin[dac_index] <= {1'b0, DIN_f_relock[dac_index][1], 14'b0};
            4'hA:    RELOCKin[dac_index] <= {1'b0, DIN_f_relock[dac_index][2], 14'b0};
            default: RELOCKin[dac_index] <= 16'b0;
        endcase
    end

    Relock #(
        .SIGNAL_OUT_SIZE(SIGNAL_SIZE)
    ) RELOCK0 (
        .clk_in(clk_dsp),
        .on_in(dsp_servo_on[dac_index] && dsp_relock_on[dac_index]),
        .minval_in(dsp_relock_min[dac_index]),
        .maxval_in(dsp_relock_max[dac_index]),
        .stepsize_in(dsp_relock_step[dac_index]),
        .signal_in(RELOCKin[dac_index]),
        .railed_in(LIMITrailed[dac_index]),
        .hold_in(LOOPFILTERhold[dac_index]),
        .hold_out(RELOCKhold[dac_index]),
        .clear_out(RELOCKclear[dac_index]),
        .signal_out(RELOCKout[dac_index])
    );

    // DOUT default reflects relock hold status (reversed: ch0->DOUT[2], ch2->DOUT[0]).
    // The DOUT source mux (below, outside this loop) drives DOUT_f from this or sweep sync.
    always @(posedge clk1) relock_hold_status[2 - dac_index] <= RELOCKhold[dac_index];

    // Modulation sum: sweep + transfer function + lock-in LO
    always @(posedge clk_dsp) begin
        MODsum[dac_index] <= SWEEPout[dac_index] + TRANSFERmod[dac_index]
                             + (LOCKINlo >>> dsp_lo_shift[dac_index]);
    end
    assign LIMITin[dac_index] = LOOPFILTERout[dac_index] + RELOCKout[dac_index]
                                + MODsum[dac_index];

    Limit #(
        .SIGNAL_IN_SIZE(SIGNAL_SIZE),
        .SIGNAL_OUT_SIZE(SIGNAL_SIZE)
    ) LIMIT0 (
        .clk_in(clk_dsp),
        .minval_in(dsp_limit_min[dac_index]),
        .maxval_in(dsp_limit_max[dac_index]),
        .center_when_railed_in(dsp_limit_center[dac_index]),
        .signal_in(LIMITin[dac_index]),
        .railed_out(LIMITrailed[dac_index]),
        .clear_out(LIMITclear[dac_index]),
        .signal_out(DACin[dac_index])
    );

    // LED: green=locked, red=relocking/railed, off=servo off
    // Index reversed: ch0->LED[2], ch2->LED[0] (matches physical board layout)
    always @(posedge clk1) begin
        LED_G_f[2 - dac_index] <= dsp_servo_on_clk1[dac_index]
            ? ((RELOCKhold[dac_index] || LIMITrailed[dac_index][0] || LIMITrailed[dac_index][1]) ? LED2red[0] : LED2green[0])
            : LED2off[0];
        LED_R_f[2 - dac_index] <= dsp_servo_on_clk1[dac_index]
            ? ((RELOCKhold[dac_index] || LIMITrailed[dac_index][0] || LIMITrailed[dac_index][1]) ? LED2red[1] : LED2green[1])
            : LED2off[1];
    end

end
endgenerate

///////////////////////////////////////////////////////////////////////////////
// DOUT source mux
//
// Each DOUT pin selects, via dout_src (reg 0x022), either the default relock-hold
// status or the sweep sync (rising-half high) from a chosen channel. The sweep
// sync is generated in clk_dsp (= clk1/4, synchronous) and the dout_src config is
// quasi-static, so both are sampled into clk1 on a single FF (dout_src is TIG'd in
// the UCF). The DOUT[1] recovery-loopback override (above) still takes priority.
///////////////////////////////////////////////////////////////////////////////
reg [5:0] dout_src_clk1;
reg [2:0] sweep_rising_clk1;
always @(posedge clk1) begin
    dout_src_clk1     <= dout_src;
    sweep_rising_clk1 <= sweep_rising_dsp;
end

integer dout_pin;
always @(posedge clk1) begin
    for (dout_pin = 0; dout_pin < 3; dout_pin = dout_pin + 1) begin
        case (dout_src_clk1[2*dout_pin +: 2])
            2'd0:    DOUT_f[dout_pin] <= relock_hold_status[dout_pin];
            2'd1:    DOUT_f[dout_pin] <= sweep_rising_clk1[0];
            2'd2:    DOUT_f[dout_pin] <= sweep_rising_clk1[1];
            default: DOUT_f[dout_pin] <= sweep_rising_clk1[2];
        endcase
    end
end

///////////////////////////////////////////////////////////////////////////////
// DAC hardware
///////////////////////////////////////////////////////////////////////////////

// Hardware ramp generator (clk1 domain, ~6 Hz sawtooth)
reg [23:0] ramp_counter = 24'd0;
reg        ramp_enable_clk1 = 1'b0;

always @(posedge clk1) begin
    ramp_enable_clk1 <= ramp_enable;
    if (ramp_enable_clk1)
        ramp_counter <= ramp_counter + 1'd1;
end

// DAC value selection (clk1 domain):
//   servo_on=1: use DACin from servo chain (clk_dsp, safe quasi-static CDC)
//   servo_on=0: use direct register value or ramp
reg [23:0] dac0_clk1 = 24'd0;
reg [23:0] dac1_clk1 = 24'd0;
reg [23:0] dac2_clk1 = 24'd0;
reg [1:0]  gain0_clk1 = 2'd0;
reg [1:0]  gain1_clk1 = 2'd0;

always @(posedge clk1) begin
    if (dsp_servo_on_clk1[0])
        dac0_clk1 <= DACin[0];
    else if (ramp_enable_clk1)
        dac0_clk1 <= ramp_counter;
    else
        dac0_clk1 <= dac0_value;

    if (dsp_servo_on_clk1[1])
        dac1_clk1 <= DACin[1];
    else if (ramp_enable_clk1)
        dac1_clk1 <= ramp_counter;
    else
        dac1_clk1 <= dac1_value;

    if (dsp_servo_on_clk1[2])
        dac2_clk1 <= DACin[2];
    else if (ramp_enable_clk1)
        dac2_clk1 <= ramp_counter;
    else
        dac2_clk1 <= dac2_value;

    gain0_clk1 <= dac_gain[1:0];
    gain1_clk1 <= dac_gain[3:2];
end

// FractionalDAC: delta-sigma interpolation from 25 MHz to 100 MHz
wire signed [15:0] DAC0_fractional, DAC1_fractional;

FractionalDAC FractionalDAC0 (
    .clk_in(clk1), .rst_in(rst), .ce(ce),
    .dac_in($signed(dac0_clk1[23:6])),
    .dac_out(DAC0_fractional)
);

FractionalDAC FractionalDAC1 (
    .clk_in(clk1), .rst_in(rst), .ce(ce),
    .dac_in($signed(dac1_clk1[23:6])),
    .dac_out(DAC1_fractional)
);

// AD9783 Fast DAC (2x 16-bit @ 100 MSPS, 800 MHz OSERDES2)
wire [15:0] ad9783_spi_out;
wire        ad9783_pll_locked;

AD9783 #(
    .SMP_DLY(8'hD)
) AD9783_inst (
    .clk_in(clk1),
    .rst_in(rst),
    .cmd_trig_in(cmd_trig),
    .cmd_addr_in(spi_cmd_addr),
    .cmd_data_in(spi_cmd_data),
    .cmd_data_out(ad9783_spi_out),
    .rst_out(AD9783_RST),
    .spi_scs_out(AD9783_SCS),
    .spi_sck_out(AD9783_SCK),
    .spi_sdo_out(AD9783_SDI),
    .spi_sdi_in(AD9783_SDO),
    .DAC0_in(DAC0_fractional),
    .DAC1_in(DAC1_fractional),
    .CLK_out_p(AD9783_CLK_P),
    .CLK_out_n(AD9783_CLK_N),
    .DCI_out_p(AD9783_DCI_P),
    .DCI_out_n(AD9783_DCI_N),
    .D_out_p(AD9783_D_P),
    .D_out_n(AD9783_D_N),
    .pll_locked_out(ad9783_pll_locked)
);

// Capture SPI readback in lbus domain
reg [15:0] spi_readback = 16'd0;
reg [15:0] spi_readback_sync = 16'd0;
always @(posedge clk_12p5mhz) begin
    spi_readback_sync <= ad9783_spi_out;
    spi_readback <= spi_readback_sync;
end

// AD8251 Output PGA
AD8251x2 AD8251x2_out (
    .clk_in(clk1), .rst_in(rst),
    .gain0_in(gain0_clk1), .gain1_in(gain1_clk1),
    .A0_out(AD8251_OUT_A0), .A1_out(AD8251_OUT_A1),
    .WR0_out(AD8251_OUT_WR0), .WR1_out(AD8251_OUT_WR1)
);

// AD5791 Precision DAC (20-bit SPI)
AD5791 AD5791_inst (
    .clk_in(clk1), .rst_in(rst),
    .DAC_in($signed(dac2_clk1[23:4])),
    .ldac_out(AD5791_LDAC), .clr_out(AD5791_CLR), .rst_out(AD5791_RST),
    .spi_scs_out(AD5791_SCS), .spi_sck_out(AD5791_SCK),
    .spi_sdo_out(AD5791_SDI), .spi_sdi_in(AD5791_SDO)
);

///////////////////////////////////////////////////////////////////////////////
// Diagnostics: SPI transaction counters (clk1 domain)
///////////////////////////////////////////////////////////////////////////////

reg ad5791_scs_d = 1'b1;
reg [15:0] ad5791_spi_count = 16'd0;
always @(posedge clk1) begin
    ad5791_scs_d <= AD5791_SCS;
    if (ad5791_scs_d && !AD5791_SCS)
        ad5791_spi_count <= ad5791_spi_count + 1'd1;
end

reg ad9783_scs_d = 1'b1;
reg [15:0] ad9783_spi_count = 16'd0;
always @(posedge clk1) begin
    ad9783_scs_d <= AD9783_SCS;
    if (ad9783_scs_d && !AD9783_SCS)
        ad9783_spi_count <= ad9783_spi_count + 1'd1;
end

///////////////////////////////////////////////////////////////////////////////
// LEDs
///////////////////////////////////////////////////////////////////////////////

assign led = ~{led_reg[7:3], tx_phase_reg};

///////////////////////////////////////////////////////////////////////////////
// Slow data logger - streams via UDP
///////////////////////////////////////////////////////////////////////////////

reg [239:0] LoggerData;
reg [31:0] dummy_counter;
always @(posedge clk1) dummy_counter <= dummy_counter + 1'b1;

always @(posedge clk1) LoggerData <= {
    ADCraw[1], ADCraw[0],
    TRANSFERcos, TRANSFERsin,
    DACin[2][SIGNAL_SIZE-1:SIGNAL_SIZE-16], DACin[1][SIGNAL_SIZE-1:SIGNAL_SIZE-16], DACin[0][SIGNAL_SIZE-1:SIGNAL_SIZE-16],
    PHASEDETraw, LOCKINout[SIGNAL_SIZE-1:SIGNAL_SIZE-16],
    ADCout[1][SIGNAL_SIZE-1:SIGNAL_SIZE-16], ADCout[0][SIGNAL_SIZE-1:SIGNAL_SIZE-16],
    {10'b0, DOUT_f, DIN_f}, dummy_counter
};

// Pack Logger samples for stream_tx (4 samples per UDP packet)
reg [1:0] sample_count = 2'd0;
reg [255:0] sample_buffer [0:3];
reg samples_valid = 1'b0;
wire samples_read;

// Generate samples at ~500 Hz (divide 100 MHz by 200,000)
reg [17:0] sample_divider = 18'd0;
wire sample_tick = (sample_divider == 18'd199999);

always @(posedge clk1) begin
    if (sample_tick)
        sample_divider <= 18'd0;
    else
        sample_divider <= sample_divider + 1'd1;
end

// Sample collection state machine
always @(posedge clk1) begin
    if (sample_tick && !samples_valid) begin
        sample_buffer[sample_count] <= {16'h2323, LoggerData};

        if (sample_count == 2'd3) begin
            sample_count <= 2'd0;
            samples_valid <= 1'b1;
        end else begin
            sample_count <= sample_count + 1'd1;
        end
    end

    if (samples_read) begin
        samples_valid <= 1'b0;
    end
end

// Stream TX instance
stream_tx #(
    .SRC_MAC(48'hAA0055000123),
    .SRC_IP({8'd192, 8'd168, 8'd7, 8'd140}),
    .SRC_PORT(16'd5001)
) stream_tx_inst (
    .clk(clk_12p5mhz),
    .dest_mac(stream_dest_mac),
    .dest_ip(stream_dest_ip),
    .dest_port(stream_dest_port),
    .ip_checksum(stream_ip_cksum),
    .sample_0(sample_buffer[0]),
    .sample_1(sample_buffer[1]),
    .sample_2(sample_buffer[2]),
    .sample_3(sample_buffer[3]),
    .samples_valid(samples_valid),
    .samples_read(samples_read),
    .scanner_busy(scanner_busy),
    .response_pending(response_pending),
    .txd(stream_txd),
    .tx_strobe_s(stream_tx_strobe_s),
    .tx_strobe_l(stream_tx_strobe_l),
    .dbg_clear_to_send(),
    .dbg_request_to_send(),
    .dbg_payload_ready(),
    .dbg_state(),
    .dbg_paused()
);

///////////////////////////////////////////////////////////////////////////////
// Fast data logger - DDR2 RAM (capture side, readout TBD)
///////////////////////////////////////////////////////////////////////////////

wire        PipeOutA1Reset;
wire        PipeOutA1WriteClock;
wire        PipeOutA1Write;
wire [63:0] PipeOutA1DataIn;

DDR2Logger Logger2 (
    .clk_in(clk1),
    .rst_in(rst),
    .cmd_trig_in(cmd_trig),
    .cmd_addr_in(spi_cmd_addr),
    .cmd_data_in(spi_cmd_data),
    .data_in(LoggerData),
    .PipeReset_out(PipeOutA1Reset),
    .PipeWriteClock_out(PipeOutA1WriteClock),
    .PipeWrite_out(PipeOutA1Write),
    .PipeData_out(PipeOutA1DataIn),
    .PipeCount_in(9'd0),
    .mcb3_dram_dq(mcb3_dram_dq),
    .mcb3_dram_a(mcb3_dram_a),
    .mcb3_dram_ba(mcb3_dram_ba),
    .mcb3_dram_ras_n(mcb3_dram_ras_n),
    .mcb3_dram_cas_n(mcb3_dram_cas_n),
    .mcb3_dram_we_n(mcb3_dram_we_n),
    .mcb3_dram_odt(mcb3_dram_odt),
    .mcb3_dram_cke(mcb3_dram_cke),
    .mcb3_dram_dm(mcb3_dram_dm),
    .mcb3_dram_udqs(mcb3_dram_udqs),
    .mcb3_dram_udqs_n(mcb3_dram_udqs_n),
    .mcb3_rzq(mcb3_rzq),
    .mcb3_zio(mcb3_zio),
    .mcb3_dram_udm(mcb3_dram_udm),
    .mcb3_dram_dqs(mcb3_dram_dqs),
    .mcb3_dram_dqs_n(mcb3_dram_dqs_n),
    .mcb3_dram_ck(mcb3_dram_ck),
    .mcb3_dram_ck_n(mcb3_dram_ck_n),
    .mcb3_dram_cs_n(mcb3_dram_cs_n),
    .c3_sys_rst_n(c3_sys_rst_n)
);

endmodule
