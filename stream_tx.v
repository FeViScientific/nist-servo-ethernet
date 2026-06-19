// Autonomous streaming transmitter for Logger/DDR2 data
// Streams UDP packets continuously, pausing only for gateway traffic.
//
// Operating modes:
//   - Free-running: Back-to-back packets with IFG spacing (~60 kHz max)
//   - Paused: After gateway RX, wait for precog to confirm safe to resume
//
// Throughput (100 Mbit RMII, 12.5 MHz GMII clock):
//   - Wire time per packet: 182 cycles (8 preamble + 170 frame + 4 CRC)
//   - Free-running period: 182 + 24 (IFG) = 206 cycles = 60.7 kHz
//   - With 128-byte payload: 60.7k * 128 = 7.8 MB/s = 62 Mbps
//   - During gateway bursts: Falls back to precog-limited ~8.4 kHz
//
// Integration: Connect to TX mux in rtefi_center after mac_subset
// Priority: Below mac_subset (response packets), above raw passthrough
//
// Note: Preamble and CRC are handled by ethernet_crc_add downstream.
// This module only outputs the Ethernet frame (header + payload).
//
module stream_tx #(
    parameter [47:0] SRC_MAC   = 48'h125555000123,
    parameter [31:0] SRC_IP    = {8'd192, 8'd168, 8'd7, 8'd4},
    parameter [15:0] SRC_PORT  = 16'd5001
) (
    input clk,  // TX clock (125 MHz for GMII, 12.5 MHz for 100 Mbit)

    // Runtime-configurable destination (from lbus registers)
    input [47:0] dest_mac,
    input [31:0] dest_ip,
    input [15:0] dest_port,
    input [15:0] ip_checksum,

    // Sample input interface (directly from Logger or via FIFO)
    input [255:0] sample_0,
    input [255:0] sample_1,
    input [255:0] sample_2,
    input [255:0] sample_3,
    input samples_valid,       // 4 samples ready to transmit
    output reg samples_read,   // Acknowledge: samples consumed

    // Timing signals from rtefi_center
    input scanner_busy,        // HIGH during RX packet reception
    input response_pending,    // HIGH when gateway responses are in flight

    // Output to TX mux (directly into rtefi_center's path)
    output reg [7:0] txd,
    output tx_strobe_s,    // Data valid (active during frame data only)
    output tx_strobe_l,    // Packet active (includes slots for preamble/CRC)

    // Debug outputs for ILA
    output dbg_clear_to_send,
    output dbg_request_to_send,
    output dbg_payload_ready,
    output [2:0] dbg_state,
    output dbg_paused
);

// Internal strobe signals - gated by clear_to_send before output (like mac_subset.v)
reg tx_strobe_s_int = 0;
reg tx_strobe_l_int = 0;

// Packet geometry (bytes/cycles at 1 byte per clock)
localparam HEADER_LEN  = 42;   // Eth(14) + IP(20) + UDP(8)
localparam PAYLOAD_LEN = 128;  // 4 samples x 32 bytes
localparam FRAME_LEN   = 170;  // Header + Payload (without preamble/CRC)
localparam PREAMBLE_CYCLES = 8;  // 7 preamble + 1 SFD (handled by ethernet_crc_add)
localparam CRC_CYCLES = 4;       // CRC (handled by ethernet_crc_add)

// Total wire time
localparam WIRE_TIME = PREAMBLE_CYCLES + FRAME_LEN + CRC_CYCLES;  // 182 cycles

// State machine (simplified - no precog wait state needed)
localparam [2:0]
    S_IDLE     = 3'd0,
    S_PREAMBLE = 3'd1,   // Output strobe_l only (preamble slots)
    S_HEADER   = 3'd2,   // Output header bytes
    S_PAYLOAD  = 3'd3,   // Output payload bytes
    S_CRC      = 3'd4;   // Output strobe_l only (CRC slots)

reg [2:0] state = S_IDLE;
reg [7:0] byte_cnt = 0;

// Payload buffer (4 samples x 256 bits = 1024 bits)
reg [1023:0] payload = 0;
reg payload_ready = 0;

// ============================================================================
// Precog-based Gap Detection
// ============================================================================
// Gateway response latency from scanner to TX output:
//   gateway_latency = (1<<paw) - p_offset + 4 + n_lat
//                   = 2048 - 480 + 4 + 8 = 1580 cycles
//
// stream_tx uses a SHORTER latency (1280 cycles) to claim gaps first.
// This gives stream_tx a 300-cycle head start. Since stream_tx packets
// are 182 cycles (WIRE_TIME), they complete well before the gateway
// response would begin (1580 - 1280 = 300 > 182), preventing collision.
// ============================================================================

localparam PAW = 11;
localparam IFG = 24;  // Inter-frame gap (like mac_subset.v)
localparam GATEWAY_LATENCY = (1 << PAW) - 480 + 4 + 8;  // 1580 cycles
localparam STREAM_HEAD_START = 300;  // Cycles before gateway response
localparam PRECOG_LATENCY = GATEWAY_LATENCY - STREAM_HEAD_START + IFG;  // 1304 cycles

// Request-to-send and clear-to-send signals for precog
reg request_to_send = 0;
wire clear_to_send;

// Packet width includes IFG on both sides (like mac_subset: len_req + 2*ifg)
wire [PAW-1:0] precog_width = WIRE_TIME + 2*IFG;

// Precog sees "busy" if either:
// - Scanner is actively receiving a packet, OR
// - A response is in flight through the ring buffer
wire effective_busy = scanner_busy || response_pending;

// ============================================================================
// Free-running / Paused mode control
// ============================================================================
// Stream continuously until gateway traffic arrives, then pause and wait
// for precog to confirm it's safe to resume.
// Start paused to let precog initialize before first transmission.
reg paused = 1;

always @(posedge clk) begin
    if (effective_busy)
        paused <= 1;  // Gateway traffic detected - enter paused mode
    else if (clear_to_send && paused)
        paused <= 0;  // Precog confirms safe - return to free-running
end

// Can transmit if:
// - Not paused (free-running mode), OR
// - Paused but precog grants clear_to_send (safe to resume after gateway)
wire can_transmit = !paused || clear_to_send;

precog #(
    .PAW(PAW),
    .LATENCY(PRECOG_LATENCY)
) gap_detector (
    .clk(clk),
    .scanner_busy(effective_busy),  // Use effective_busy instead of scanner_busy
    .tx_packet_width(precog_width),
    .request_to_send(request_to_send),
    .clear_to_send(clear_to_send)
);

// Gate strobes with can_transmit
// In free-running mode (!paused), strobes go out immediately
// In paused mode, wait for precog to confirm safe (clear_to_send)
assign tx_strobe_s = tx_strobe_s_int & can_transmit;
assign tx_strobe_l = tx_strobe_l_int & can_transmit;

// Header ROM output
wire [7:0] header_byte;
stream_tx_header #(
    .SRC_MAC(SRC_MAC),
    .SRC_IP(SRC_IP),
    .SRC_PORT(SRC_PORT)
) header_rom (
    .index(byte_cnt[5:0]),
    .dest_mac(dest_mac),
    .dest_ip(dest_ip),
    .dest_port(dest_port),
    .ip_checksum(ip_checksum),
    .data(header_byte)
);

always @(posedge clk) begin
    samples_read <= 0;
    tx_strobe_s_int <= 0;
    tx_strobe_l_int <= 0;

    // Latch samples when available and we're idle
    // Pack in reverse order so sample_0 is transmitted first (MSB of payload)
    if (samples_valid && !payload_ready && state == S_IDLE) begin
        payload <= {sample_0, sample_1, sample_2, sample_3};
        samples_read <= 1;
        payload_ready <= 1;
    end

    case (state)
        S_IDLE: begin
            byte_cnt <= 0;
            // Request transmission when we have data ready (for precog tracking)
            if (payload_ready && !request_to_send) begin
                request_to_send <= 1;
            end
            // Start transmitting when allowed AND we have data
            // can_transmit = !paused (free-running) OR clear_to_send (after gateway)
            if (can_transmit && payload_ready) begin
                request_to_send <= 0;
                state <= S_PREAMBLE;
            end
            // Cancel request if we somehow lost payload_ready
            if (request_to_send && !payload_ready) begin
                request_to_send <= 0;
            end
        end

        S_PREAMBLE: begin
            // Preamble slots - strobe_l only, ethernet_crc_add generates 0x55/0xD5
            // Strobes gated by clear_to_send at output
            tx_strobe_l_int <= 1;
            tx_strobe_s_int <= 0;
            txd <= 8'h00;  // Ignored, ethernet_crc_add substitutes preamble
            byte_cnt <= byte_cnt + 1;
            if (byte_cnt == PREAMBLE_CYCLES - 1) begin
                state <= S_HEADER;
                byte_cnt <= 0;
            end
        end

        S_HEADER: begin
            // Header bytes - both strobes active
            txd <= header_byte;
            tx_strobe_s_int <= 1;
            tx_strobe_l_int <= 1;
            byte_cnt <= byte_cnt + 1;
            if (byte_cnt == HEADER_LEN - 1) begin
                state <= S_PAYLOAD;
                byte_cnt <= 0;
            end
        end

        S_PAYLOAD: begin
            // Payload bytes - both strobes active
            // payload = {sample_0, sample_1, sample_2, sample_3}
            // payload[1023:768] = sample_0, payload[767:512] = sample_1
            // payload[511:256] = sample_2, payload[255:0] = sample_3
            // Byte-swap within each 16-bit word for Logger.v compatibility
            txd <= payload[1023 - (byte_cnt ^ 7'd1)*8 -: 8];
            tx_strobe_s_int <= 1;
            tx_strobe_l_int <= 1;
            byte_cnt <= byte_cnt + 1;
            if (byte_cnt == PAYLOAD_LEN - 1) begin
                state <= S_CRC;
                byte_cnt <= 0;
            end
        end

        S_CRC: begin
            // CRC slots - strobe_l only, ethernet_crc_add generates CRC
            tx_strobe_l_int <= 1;
            tx_strobe_s_int <= 0;
            byte_cnt <= byte_cnt + 1;
            if (byte_cnt == CRC_CYCLES - 1) begin
                state <= S_IDLE;
                payload_ready <= 0;  // Ready for next batch
            end
        end

        default: state <= S_IDLE;
    endcase
end

// Debug outputs
assign dbg_clear_to_send = clear_to_send;
assign dbg_request_to_send = request_to_send;
assign dbg_payload_ready = payload_ready;
assign dbg_state = state;
assign dbg_paused = paused;

endmodule
