/* Machine-generated using Migen */
module rmii_gmii(
	input [1:0] rmii_rxd,
	input rmii_crs_dv,
	output reg [1:0] rmii_txd,
	output rmii_tx_en,
	output [7:0] gmii_rxd,
	output reg gmii_rx_dv,
	output gmii_rx_er,
	input [7:0] gmii_txd,
	input gmii_tx_en,
	output reg in_packet,
	input sys_clk,
	input sys_rst
);

reg [1:0] nibble0 = 2'd0;
reg [1:0] nibble1 = 2'd0;
reg [1:0] nibble2 = 2'd0;
reg [7:0] rx_buffer = 8'd0;
reg [1:0] cycle_count = 2'd0;
reg [7:0] tx_buffer = 8'd0;
reg tx_en_buffer = 1'd0;
reg [1:0] tx_cycle = 2'd0;
reg gmii_tx_en_d = 1'd0;
wire first_preamble;

// synthesis translate_off
reg dummy_s;
initial dummy_s <= 1'd0;
// synthesis translate_on

assign first_preamble = ((rmii_crs_dv & (~in_packet)) & (rmii_rxd == 1'd1));
assign gmii_rxd = rx_buffer;
assign gmii_rx_er = 1'd0;

// synthesis translate_off
reg dummy_d;
// synthesis translate_on
always @(*) begin
	rmii_txd <= 2'd0;
	case (tx_cycle)
		1'd0: begin
			rmii_txd <= tx_buffer[1:0];
		end
		1'd1: begin
			rmii_txd <= tx_buffer[3:2];
		end
		2'd2: begin
			rmii_txd <= tx_buffer[5:4];
		end
		2'd3: begin
			rmii_txd <= tx_buffer[7:6];
		end
	endcase
// synthesis translate_off
	dummy_d <= dummy_s;
// synthesis translate_on
end
assign rmii_tx_en = tx_en_buffer;

always @(posedge sys_clk) begin
	if (in_packet) begin
		case (cycle_count)
			1'd0: begin
				nibble0 <= rmii_rxd;
			end
			1'd1: begin
				nibble1 <= rmii_rxd;
			end
			2'd2: begin
				nibble2 <= rmii_rxd;
			end
		endcase
	end else begin
		nibble0 <= rmii_rxd;
	end
	cycle_count <= (cycle_count + 1'd1);
	if ((~rmii_crs_dv)) begin
		in_packet <= 1'd0;
		if ((cycle_count == 2'd3)) begin
			gmii_rx_dv <= 1'd0;
		end
	end else begin
		if (first_preamble) begin
			in_packet <= 1'd1;
			cycle_count <= 1'd1;
		end else begin
			if (in_packet) begin
				cycle_count <= (cycle_count + 1'd1);
				if (((cycle_count == 2'd3) & rmii_crs_dv)) begin
					rx_buffer <= {rmii_rxd, nibble2, nibble1, nibble0};
					gmii_rx_dv <= 1'd1;
				end
			end
		end
	end
	gmii_tx_en_d <= gmii_tx_en;
	tx_cycle <= (tx_cycle + 1'd1);
	if ((gmii_tx_en & (~gmii_tx_en_d))) begin
		tx_buffer <= gmii_txd;
		tx_en_buffer <= 1'd1;
		tx_cycle <= 1'd0;
	end else begin
		if ((tx_cycle == 2'd3)) begin
			if (gmii_tx_en) begin
				tx_buffer <= gmii_txd;
				tx_en_buffer <= 1'd1;
			end else begin
				tx_en_buffer <= 1'd0;
			end
		end
	end
	if (sys_rst) begin
		gmii_rx_dv <= 1'd0;
		in_packet <= 1'd0;
		nibble0 <= 2'd0;
		nibble1 <= 2'd0;
		nibble2 <= 2'd0;
		rx_buffer <= 8'd0;
		cycle_count <= 2'd0;
		tx_buffer <= 8'd0;
		tx_en_buffer <= 1'd0;
		tx_cycle <= 2'd0;
		gmii_tx_en_d <= 1'd0;
	end
end

endmodule

