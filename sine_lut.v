///////////////////////////////////////////////////////////////////////////////
// sine_lut.v
// Behavioral sine lookup table for mock DDS modules
// 256-entry quarter-wave table with symmetry expansion
///////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module sine_lut #(
    parameter OUTPUT_WIDTH = 16
) (
    input wire clk,
    input wire [9:0] phase,  // 10-bit phase (0-1023 = 0-360 degrees)
    output reg signed [OUTPUT_WIDTH-1:0] sine_out,
    output reg signed [OUTPUT_WIDTH-1:0] cosine_out
);

// Quarter-wave sine table (256 entries, 0 to 90 degrees)
// Values scaled to 16-bit signed: sin(angle) * 32767
reg signed [15:0] quarter_wave [0:255];

initial begin
    quarter_wave[  0] = 16'd0;
    quarter_wave[  1] = 16'd201;
    quarter_wave[  2] = 16'd402;
    quarter_wave[  3] = 16'd603;
    quarter_wave[  4] = 16'd804;
    quarter_wave[  5] = 16'd1005;
    quarter_wave[  6] = 16'd1206;
    quarter_wave[  7] = 16'd1407;
    quarter_wave[  8] = 16'd1608;
    quarter_wave[  9] = 16'd1809;
    quarter_wave[ 10] = 16'd2009;
    quarter_wave[ 11] = 16'd2210;
    quarter_wave[ 12] = 16'd2410;
    quarter_wave[ 13] = 16'd2611;
    quarter_wave[ 14] = 16'd2811;
    quarter_wave[ 15] = 16'd3012;
    quarter_wave[ 16] = 16'd3212;
    quarter_wave[ 17] = 16'd3412;
    quarter_wave[ 18] = 16'd3612;
    quarter_wave[ 19] = 16'd3811;
    quarter_wave[ 20] = 16'd4011;
    quarter_wave[ 21] = 16'd4210;
    quarter_wave[ 22] = 16'd4410;
    quarter_wave[ 23] = 16'd4609;
    quarter_wave[ 24] = 16'd4808;
    quarter_wave[ 25] = 16'd5007;
    quarter_wave[ 26] = 16'd5205;
    quarter_wave[ 27] = 16'd5404;
    quarter_wave[ 28] = 16'd5602;
    quarter_wave[ 29] = 16'd5800;
    quarter_wave[ 30] = 16'd5998;
    quarter_wave[ 31] = 16'd6195;
    quarter_wave[ 32] = 16'd6393;
    quarter_wave[ 33] = 16'd6590;
    quarter_wave[ 34] = 16'd6786;
    quarter_wave[ 35] = 16'd6983;
    quarter_wave[ 36] = 16'd7179;
    quarter_wave[ 37] = 16'd7375;
    quarter_wave[ 38] = 16'd7571;
    quarter_wave[ 39] = 16'd7767;
    quarter_wave[ 40] = 16'd7962;
    quarter_wave[ 41] = 16'd8157;
    quarter_wave[ 42] = 16'd8351;
    quarter_wave[ 43] = 16'd8545;
    quarter_wave[ 44] = 16'd8739;
    quarter_wave[ 45] = 16'd8933;
    quarter_wave[ 46] = 16'd9126;
    quarter_wave[ 47] = 16'd9319;
    quarter_wave[ 48] = 16'd9512;
    quarter_wave[ 49] = 16'd9704;
    quarter_wave[ 50] = 16'd9896;
    quarter_wave[ 51] = 16'd10087;
    quarter_wave[ 52] = 16'd10278;
    quarter_wave[ 53] = 16'd10469;
    quarter_wave[ 54] = 16'd10659;
    quarter_wave[ 55] = 16'd10849;
    quarter_wave[ 56] = 16'd11039;
    quarter_wave[ 57] = 16'd11228;
    quarter_wave[ 58] = 16'd11417;
    quarter_wave[ 59] = 16'd11605;
    quarter_wave[ 60] = 16'd11793;
    quarter_wave[ 61] = 16'd11980;
    quarter_wave[ 62] = 16'd12167;
    quarter_wave[ 63] = 16'd12353;
    quarter_wave[ 64] = 16'd12539;
    quarter_wave[ 65] = 16'd12725;
    quarter_wave[ 66] = 16'd12910;
    quarter_wave[ 67] = 16'd13094;
    quarter_wave[ 68] = 16'd13279;
    quarter_wave[ 69] = 16'd13462;
    quarter_wave[ 70] = 16'd13645;
    quarter_wave[ 71] = 16'd13828;
    quarter_wave[ 72] = 16'd14010;
    quarter_wave[ 73] = 16'd14191;
    quarter_wave[ 74] = 16'd14372;
    quarter_wave[ 75] = 16'd14553;
    quarter_wave[ 76] = 16'd14732;
    quarter_wave[ 77] = 16'd14912;
    quarter_wave[ 78] = 16'd15090;
    quarter_wave[ 79] = 16'd15269;
    quarter_wave[ 80] = 16'd15446;
    quarter_wave[ 81] = 16'd15623;
    quarter_wave[ 82] = 16'd15800;
    quarter_wave[ 83] = 16'd15976;
    quarter_wave[ 84] = 16'd16151;
    quarter_wave[ 85] = 16'd16325;
    quarter_wave[ 86] = 16'd16499;
    quarter_wave[ 87] = 16'd16673;
    quarter_wave[ 88] = 16'd16846;
    quarter_wave[ 89] = 16'd17018;
    quarter_wave[ 90] = 16'd17189;
    quarter_wave[ 91] = 16'd17360;
    quarter_wave[ 92] = 16'd17530;
    quarter_wave[ 93] = 16'd17700;
    quarter_wave[ 94] = 16'd17869;
    quarter_wave[ 95] = 16'd18037;
    quarter_wave[ 96] = 16'd18204;
    quarter_wave[ 97] = 16'd18371;
    quarter_wave[ 98] = 16'd18537;
    quarter_wave[ 99] = 16'd18703;
    quarter_wave[100] = 16'd18868;
    quarter_wave[101] = 16'd19032;
    quarter_wave[102] = 16'd19195;
    quarter_wave[103] = 16'd19357;
    quarter_wave[104] = 16'd19519;
    quarter_wave[105] = 16'd19680;
    quarter_wave[106] = 16'd19841;
    quarter_wave[107] = 16'd20000;
    quarter_wave[108] = 16'd20159;
    quarter_wave[109] = 16'd20317;
    quarter_wave[110] = 16'd20475;
    quarter_wave[111] = 16'd20631;
    quarter_wave[112] = 16'd20787;
    quarter_wave[113] = 16'd20942;
    quarter_wave[114] = 16'd21096;
    quarter_wave[115] = 16'd21250;
    quarter_wave[116] = 16'd21403;
    quarter_wave[117] = 16'd21554;
    quarter_wave[118] = 16'd21705;
    quarter_wave[119] = 16'd21856;
    quarter_wave[120] = 16'd22005;
    quarter_wave[121] = 16'd22154;
    quarter_wave[122] = 16'd22301;
    quarter_wave[123] = 16'd22448;
    quarter_wave[124] = 16'd22594;
    quarter_wave[125] = 16'd22739;
    quarter_wave[126] = 16'd22884;
    quarter_wave[127] = 16'd23027;
    quarter_wave[128] = 16'd23170;
    quarter_wave[129] = 16'd23311;
    quarter_wave[130] = 16'd23452;
    quarter_wave[131] = 16'd23592;
    quarter_wave[132] = 16'd23731;
    quarter_wave[133] = 16'd23870;
    quarter_wave[134] = 16'd24007;
    quarter_wave[135] = 16'd24143;
    quarter_wave[136] = 16'd24279;
    quarter_wave[137] = 16'd24413;
    quarter_wave[138] = 16'd24547;
    quarter_wave[139] = 16'd24680;
    quarter_wave[140] = 16'd24811;
    quarter_wave[141] = 16'd24942;
    quarter_wave[142] = 16'd25072;
    quarter_wave[143] = 16'd25201;
    quarter_wave[144] = 16'd25329;
    quarter_wave[145] = 16'd25456;
    quarter_wave[146] = 16'd25582;
    quarter_wave[147] = 16'd25708;
    quarter_wave[148] = 16'd25832;
    quarter_wave[149] = 16'd25955;
    quarter_wave[150] = 16'd26077;
    quarter_wave[151] = 16'd26198;
    quarter_wave[152] = 16'd26319;
    quarter_wave[153] = 16'd26438;
    quarter_wave[154] = 16'd26556;
    quarter_wave[155] = 16'd26674;
    quarter_wave[156] = 16'd26790;
    quarter_wave[157] = 16'd26905;
    quarter_wave[158] = 16'd27019;
    quarter_wave[159] = 16'd27133;
    quarter_wave[160] = 16'd27245;
    quarter_wave[161] = 16'd27356;
    quarter_wave[162] = 16'd27466;
    quarter_wave[163] = 16'd27575;
    quarter_wave[164] = 16'd27683;
    quarter_wave[165] = 16'd27790;
    quarter_wave[166] = 16'd27896;
    quarter_wave[167] = 16'd28001;
    quarter_wave[168] = 16'd28105;
    quarter_wave[169] = 16'd28208;
    quarter_wave[170] = 16'd28310;
    quarter_wave[171] = 16'd28411;
    quarter_wave[172] = 16'd28510;
    quarter_wave[173] = 16'd28609;
    quarter_wave[174] = 16'd28706;
    quarter_wave[175] = 16'd28803;
    quarter_wave[176] = 16'd28898;
    quarter_wave[177] = 16'd28992;
    quarter_wave[178] = 16'd29085;
    quarter_wave[179] = 16'd29177;
    quarter_wave[180] = 16'd29268;
    quarter_wave[181] = 16'd29358;
    quarter_wave[182] = 16'd29447;
    quarter_wave[183] = 16'd29534;
    quarter_wave[184] = 16'd29621;
    quarter_wave[185] = 16'd29706;
    quarter_wave[186] = 16'd29791;
    quarter_wave[187] = 16'd29874;
    quarter_wave[188] = 16'd29956;
    quarter_wave[189] = 16'd30037;
    quarter_wave[190] = 16'd30117;
    quarter_wave[191] = 16'd30195;
    quarter_wave[192] = 16'd30273;
    quarter_wave[193] = 16'd30349;
    quarter_wave[194] = 16'd30424;
    quarter_wave[195] = 16'd30498;
    quarter_wave[196] = 16'd30571;
    quarter_wave[197] = 16'd30643;
    quarter_wave[198] = 16'd30714;
    quarter_wave[199] = 16'd30783;
    quarter_wave[200] = 16'd30852;
    quarter_wave[201] = 16'd30919;
    quarter_wave[202] = 16'd30985;
    quarter_wave[203] = 16'd31050;
    quarter_wave[204] = 16'd31113;
    quarter_wave[205] = 16'd31176;
    quarter_wave[206] = 16'd31237;
    quarter_wave[207] = 16'd31297;
    quarter_wave[208] = 16'd31356;
    quarter_wave[209] = 16'd31414;
    quarter_wave[210] = 16'd31470;
    quarter_wave[211] = 16'd31526;
    quarter_wave[212] = 16'd31580;
    quarter_wave[213] = 16'd31633;
    quarter_wave[214] = 16'd31685;
    quarter_wave[215] = 16'd31736;
    quarter_wave[216] = 16'd31785;
    quarter_wave[217] = 16'd31833;
    quarter_wave[218] = 16'd31880;
    quarter_wave[219] = 16'd31926;
    quarter_wave[220] = 16'd31971;
    quarter_wave[221] = 16'd32014;
    quarter_wave[222] = 16'd32057;
    quarter_wave[223] = 16'd32098;
    quarter_wave[224] = 16'd32137;
    quarter_wave[225] = 16'd32176;
    quarter_wave[226] = 16'd32213;
    quarter_wave[227] = 16'd32250;
    quarter_wave[228] = 16'd32285;
    quarter_wave[229] = 16'd32318;
    quarter_wave[230] = 16'd32351;
    quarter_wave[231] = 16'd32382;
    quarter_wave[232] = 16'd32412;
    quarter_wave[233] = 16'd32441;
    quarter_wave[234] = 16'd32469;
    quarter_wave[235] = 16'd32495;
    quarter_wave[236] = 16'd32521;
    quarter_wave[237] = 16'd32545;
    quarter_wave[238] = 16'd32567;
    quarter_wave[239] = 16'd32589;
    quarter_wave[240] = 16'd32609;
    quarter_wave[241] = 16'd32628;
    quarter_wave[242] = 16'd32646;
    quarter_wave[243] = 16'd32663;
    quarter_wave[244] = 16'd32678;
    quarter_wave[245] = 16'd32692;
    quarter_wave[246] = 16'd32705;
    quarter_wave[247] = 16'd32717;
    quarter_wave[248] = 16'd32728;
    quarter_wave[249] = 16'd32737;
    quarter_wave[250] = 16'd32745;
    quarter_wave[251] = 16'd32752;
    quarter_wave[252] = 16'd32757;
    quarter_wave[253] = 16'd32761;
    quarter_wave[254] = 16'd32765;
    quarter_wave[255] = 16'd32767;
end

// Compute sine and cosine using quarter-wave symmetry
reg signed [15:0] sine_full, cosine_full;
wire [7:0] lut_index;
wire [9:0] cos_phase = phase + 10'd256;  // Cosine is sine shifted by 90 degrees

// Sine lookup
always @(posedge clk) begin
    case (phase[9:8])
        2'b00: sine_full <=  quarter_wave[phase[7:0]];           // 0-90: direct
        2'b01: sine_full <=  quarter_wave[8'd255 - phase[7:0]];  // 90-180: mirror
        2'b10: sine_full <= -quarter_wave[phase[7:0]];           // 180-270: negate
        2'b11: sine_full <= -quarter_wave[8'd255 - phase[7:0]];  // 270-360: mirror+negate
    endcase

    case (cos_phase[9:8])
        2'b00: cosine_full <=  quarter_wave[cos_phase[7:0]];
        2'b01: cosine_full <=  quarter_wave[8'd255 - cos_phase[7:0]];
        2'b10: cosine_full <= -quarter_wave[cos_phase[7:0]];
        2'b11: cosine_full <= -quarter_wave[8'd255 - cos_phase[7:0]];
    endcase
end

// Scale output to desired width
generate
    if (OUTPUT_WIDTH == 16) begin
        always @(posedge clk) begin
            sine_out <= sine_full;
            cosine_out <= cosine_full;
        end
    end else if (OUTPUT_WIDTH == 24) begin
        always @(posedge clk) begin
            sine_out <= {sine_full, 8'd0};
            cosine_out <= {cosine_full, 8'd0};
        end
    end else begin
        always @(posedge clk) begin
            sine_out <= sine_full[15:16-OUTPUT_WIDTH];
            cosine_out <= cosine_full[15:16-OUTPUT_WIDTH];
        end
    end
endgenerate

endmodule
