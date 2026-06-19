///////////////////////////////////////////////////////////////////////////////
// FractionalDAC.v
//
// First-order delta-sigma modulator for fractional DAC output.
// Latches new 18-bit input when ce is high, outputs 16-bit at full clock rate.
// Over 4 output cycles, average equals the fractional input value.
//
///////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module FractionalDAC (
    input  wire                 clk_in,
    input  wire                 rst_in,
    input  wire                 ce,             // Clock enable (high every 4th cycle)
    input  wire signed [17:0]   dac_in,         // [17:2]=integer, [1:0]=fractional
    output reg  signed [15:0]   dac_out
);

    // Extract integer and fractional parts
    wire signed [15:0] integer_part = dac_in[17:2];
    wire        [1:0]  frac_part    = dac_in[1:0];

    // Delta-sigma accumulator
    reg [2:0] sigma_acc;

    // Registered values held between ce pulses
    reg signed [15:0] base_value;
    reg        [1:0]  frac_value;

    // Saturation-protected increment
    wire signed [15:0] base_plus_one;
    assign base_plus_one = (base_value == 16'h7FFF) ? 16'h7FFF : (base_value + 16'sd1);

    always @(posedge clk_in) begin
        if (rst_in) begin
            sigma_acc  <= 3'd0;
            base_value <= 16'sd0;
            frac_value <= 2'd0;
            dac_out    <= 16'sd0;
        end
        else begin
            // Latch new input on clock enable
            if (ce) begin
                base_value <= integer_part;
                frac_value <= frac_part;
            end

            // Delta-sigma runs every cycle
            if (sigma_acc + {1'b0, frac_value} >= 3'd4) begin
                dac_out   <= base_plus_one;
                sigma_acc <= sigma_acc + {1'b0, frac_value} - 3'd4;
            end
            else begin
                dac_out   <= base_value;
                sigma_acc <= sigma_acc + {1'b0, frac_value};
            end
        end
    end

endmodule
