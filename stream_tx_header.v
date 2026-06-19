// Header ROM for stream_tx - generates constant Ethernet/IP/UDP header bytes
// Total header: 42 bytes (Ethernet 14 + IP 20 + UDP 8)
//
// Packet format:
//   Ethernet: Dest MAC [6] + Src MAC [6] + EtherType [2] = 14 bytes
//   IP:       Version/IHL/ToS [2] + Length [2] + ID [2] + Flags/Frag [2]
//             + TTL/Proto [2] + Checksum [2] + Src IP [4] + Dest IP [4] = 20 bytes
//   UDP:      Src Port [2] + Dest Port [2] + Length [2] + Checksum [2] = 8 bytes
//
module stream_tx_header #(
    parameter [47:0] SRC_MAC     = 48'h125555000123,
    parameter [31:0] SRC_IP      = {8'd192, 8'd168, 8'd7, 8'd4},
    parameter [15:0] SRC_PORT    = 16'd5001
) (
    input [5:0] index,
    input [47:0] dest_mac,
    input [31:0] dest_ip,
    input [15:0] dest_port,
    input [15:0] ip_checksum,
    output reg [7:0] data
);

// Fixed header values for 128-byte payload
localparam [15:0] IP_LENGTH  = 16'd156;  // 20 (IP header) + 8 (UDP header) + 128 (payload)
localparam [15:0] UDP_LENGTH = 16'd136;  // 8 (UDP header) + 128 (payload)

always @(*) begin
    case (index)
        // ============================================================
        // Ethernet Header (14 bytes, indices 0-13)
        // ============================================================
        6'd0:  data = dest_mac[47:40];
        6'd1:  data = dest_mac[39:32];
        6'd2:  data = dest_mac[31:24];
        6'd3:  data = dest_mac[23:16];
        6'd4:  data = dest_mac[15:8];
        6'd5:  data = dest_mac[7:0];
        6'd6:  data = SRC_MAC[47:40];
        6'd7:  data = SRC_MAC[39:32];
        6'd8:  data = SRC_MAC[31:24];
        6'd9:  data = SRC_MAC[23:16];
        6'd10: data = SRC_MAC[15:8];
        6'd11: data = SRC_MAC[7:0];
        6'd12: data = 8'h08;           // EtherType: IPv4 (0x0800)
        6'd13: data = 8'h00;

        // ============================================================
        // IP Header (20 bytes, indices 14-33)
        // ============================================================
        6'd14: data = 8'h45;           // Version 4, IHL 5 (20 bytes)
        6'd15: data = 8'h00;           // ToS / DSCP
        6'd16: data = IP_LENGTH[15:8]; // Total length MSB
        6'd17: data = IP_LENGTH[7:0];  // Total length LSB
        6'd18: data = 8'h00;           // Identification MSB
        6'd19: data = 8'h00;           // Identification LSB
        6'd20: data = 8'h40;           // Flags: Don't fragment (0x40)
        6'd21: data = 8'h00;           // Fragment offset
        6'd22: data = 8'h40;           // TTL = 64
        6'd23: data = 8'h11;           // Protocol = UDP (17)
        6'd24: data = ip_checksum[15:8]; // Header checksum MSB
        6'd25: data = ip_checksum[7:0];  // Header checksum LSB
        6'd26: data = SRC_IP[31:24];   // Source IP
        6'd27: data = SRC_IP[23:16];
        6'd28: data = SRC_IP[15:8];
        6'd29: data = SRC_IP[7:0];
        6'd30: data = dest_ip[31:24];  // Destination IP
        6'd31: data = dest_ip[23:16];
        6'd32: data = dest_ip[15:8];
        6'd33: data = dest_ip[7:0];

        // ============================================================
        // UDP Header (8 bytes, indices 34-41)
        // ============================================================
        6'd34: data = SRC_PORT[15:8];  // Source port MSB
        6'd35: data = SRC_PORT[7:0];   // Source port LSB
        6'd36: data = dest_port[15:8]; // Destination port MSB
        6'd37: data = dest_port[7:0];  // Destination port LSB
        6'd38: data = UDP_LENGTH[15:8]; // UDP length MSB
        6'd39: data = UDP_LENGTH[7:0];  // UDP length LSB
        6'd40: data = 8'h00;           // UDP checksum MSB (0 = disabled)
        6'd41: data = 8'h00;           // UDP checksum LSB

        default: data = 8'h00;
    endcase
end

endmodule
