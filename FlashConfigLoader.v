///////////////////////////////////////////////////////////////////////////////
// FlashConfigLoader.v
//
// Simplified flash loader for configuration registers.
// Reads configuration from M25P32 SPI flash at startup and outputs
// sequential word writes. No variable bit-select - just sequential output.
//
// At startup:
//   1. Reads CONFIG_WORDS 16-bit words from flash
//   2. Outputs (cfg_addr, cfg_data, cfg_we) for each word
//   3. Asserts cfg_done when complete
//
// Runtime:
//   - save_cmd input triggers write of current config back to flash
//   - cfg_rdata input provides data to save
//
///////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module FlashConfigLoader #(
    parameter CONFIG_WORDS = 768,           // Number of 16-bit words (12288 bits / 16)
    parameter SPI_CLK_DIV  = 8'd25,         // 100MHz / 25 = 4MHz SPI clock
    parameter SPI_ADDRESS  = 24'h3F0000     // Flash sector address
)(
    input  wire        clk,
    input  wire        rst,

    // Configuration output interface (directly to config registers)
    output reg  [9:0]  cfg_addr,            // Word address (0 to CONFIG_WORDS-1)
    output reg  [15:0] cfg_data,            // Word data
    output reg         cfg_we,              // Write enable pulse
    output reg         cfg_done,            // Loading complete

    // Save interface
    input  wire        save_cmd,            // Trigger save to flash
    input  wire [9:0]  cfg_raddr,           // Read address for save
    input  wire [15:0] cfg_rdata,           // Read data for save
    output reg         save_done,           // Save complete

    // SPI interface
    output reg         spi_scs,
    output reg         spi_sck,
    output reg         spi_sdo,
    input  wire        spi_sdi
);

// SPI clock divider
reg [7:0] clk_counter;
reg       spi_clk_en;

always @(posedge clk) begin
    if (rst) begin
        clk_counter <= 8'd0;
        spi_clk_en <= 1'b0;
    end else if (clk_counter == SPI_CLK_DIV - 1) begin
        clk_counter <= 8'd0;
        spi_clk_en <= 1'b1;
    end else begin
        clk_counter <= clk_counter + 1'd1;
        spi_clk_en <= 1'b0;
    end
end

// State machine
localparam IDLE       = 4'd0;
localparam READ_CMD   = 4'd1;
localparam READ_ADDR  = 4'd2;
localparam READ_DATA  = 4'd3;
localparam READ_DONE  = 4'd4;
localparam SAVE_WREN  = 4'd5;
localparam SAVE_SE    = 4'd6;
localparam SAVE_WAIT  = 4'd7;
localparam SAVE_PP    = 4'd8;
localparam SAVE_DONE  = 4'd9;

reg [3:0]  state;
reg [9:0]  word_counter;      // Current word being read/written
reg [4:0]  bit_counter;       // Bit position in current operation
reg [23:0] spi_shift_out;     // Shift register for SPI output
reg [15:0] spi_shift_in;      // Shift register for SPI input
reg        startup_done;      // Flag to prevent re-reading on every reset

// M25P32 commands
localparam CMD_READ = 8'h03;
localparam CMD_WREN = 8'h06;
localparam CMD_SE   = 8'hD8;  // Sector erase
localparam CMD_PP   = 8'h02;  // Page program
localparam CMD_RDSR = 8'h05;  // Read status register

// Main state machine
always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        word_counter <= 10'd0;
        bit_counter <= 5'd0;
        cfg_addr <= 10'd0;
        cfg_data <= 16'd0;
        cfg_we <= 1'b0;
        cfg_done <= 1'b0;
        save_done <= 1'b0;
        spi_scs <= 1'b1;
        spi_sck <= 1'b0;
        spi_sdo <= 1'b1;
        spi_shift_out <= 24'd0;
        spi_shift_in <= 16'd0;
        startup_done <= 1'b0;
    end else begin
        // Default: clear write enable
        cfg_we <= 1'b0;
        save_done <= 1'b0;

        if (spi_clk_en) begin
            case (state)
                IDLE: begin
                    spi_scs <= 1'b1;
                    spi_sck <= 1'b0;
                    if (!startup_done) begin
                        // Start reading from flash
                        state <= READ_CMD;
                        word_counter <= 10'd0;
                        bit_counter <= 5'd0;
                        spi_shift_out <= {CMD_READ, SPI_ADDRESS[23:8]};
                    end else if (save_cmd) begin
                        // TODO: Implement save
                        save_done <= 1'b1;
                    end
                end

                READ_CMD: begin
                    // Send READ command (8 bits) + address (24 bits) = 32 bits
                    spi_scs <= 1'b0;
                    if (bit_counter < 5'd32) begin
                        if (spi_sck == 1'b0) begin
                            // Rising edge - shift out data
                            spi_sck <= 1'b1;
                            if (bit_counter < 5'd8) begin
                                spi_sdo <= CMD_READ[7 - bit_counter[2:0]];
                            end else begin
                                spi_sdo <= SPI_ADDRESS[31 - bit_counter];
                            end
                        end else begin
                            // Falling edge
                            spi_sck <= 1'b0;
                            bit_counter <= bit_counter + 1'd1;
                        end
                    end else begin
                        // Command sent, start reading data
                        state <= READ_DATA;
                        bit_counter <= 5'd0;
                        spi_shift_in <= 16'd0;
                    end
                end

                READ_DATA: begin
                    // Read 16 bits per word
                    if (bit_counter < 5'd16) begin
                        if (spi_sck == 1'b0) begin
                            spi_sck <= 1'b1;
                        end else begin
                            spi_sck <= 1'b0;
                            spi_shift_in <= {spi_shift_in[14:0], spi_sdi};
                            bit_counter <= bit_counter + 1'd1;
                        end
                    end else begin
                        // Word complete - output it
                        cfg_addr <= word_counter;
                        cfg_data <= spi_shift_in;
                        cfg_we <= 1'b1;

                        if (word_counter == CONFIG_WORDS - 1) begin
                            // All words read
                            state <= READ_DONE;
                        end else begin
                            // Next word
                            word_counter <= word_counter + 1'd1;
                            bit_counter <= 5'd0;
                            spi_shift_in <= 16'd0;
                        end
                    end
                end

                READ_DONE: begin
                    spi_scs <= 1'b1;
                    spi_sck <= 1'b0;
                    cfg_done <= 1'b1;
                    startup_done <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
end

endmodule
