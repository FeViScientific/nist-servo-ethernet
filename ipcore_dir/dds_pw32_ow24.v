////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.20131013
//  \   \         Application: netgen
//  /   /         Filename: dds_pw32_ow24.v
// /___/   /\     Timestamp: Wed Oct 22 14:07:23 2025
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog C:/Users/fevi/Desktop/digital-servo-master/firmware/ipcore_dir/tmp/_cg/dds_pw32_ow24.ngc C:/Users/fevi/Desktop/digital-servo-master/firmware/ipcore_dir/tmp/_cg/dds_pw32_ow24.v 
// Device	: 6slx150fgg484-2
// Input file	: C:/Users/fevi/Desktop/digital-servo-master/firmware/ipcore_dir/tmp/_cg/dds_pw32_ow24.ngc
// Output file	: C:/Users/fevi/Desktop/digital-servo-master/firmware/ipcore_dir/tmp/_cg/dds_pw32_ow24.v
// # of Modules	: 1
// Design Name	: dds_pw32_ow24
// Xilinx        : C:\Xilinx\14.7\ISE_DS\ISE\
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module dds_pw32_ow24 (
  clk, pinc_in, cosine, sine
)/* synthesis syn_black_box syn_noprune=1 */;
  input clk;
  input [31 : 0] pinc_in;
  output [23 : 0] cosine;
  output [23 : 0] sine;
  
  // synthesis translate_off
  
  wire sig00000001;
  wire sig00000002;
  wire sig00000003;
  wire sig00000004;
  wire sig00000005;
  wire sig00000006;
  wire sig00000007;
  wire sig00000008;
  wire sig00000009;
  wire sig0000000a;
  wire sig0000000b;
  wire sig0000000c;
  wire sig0000000d;
  wire sig0000000e;
  wire sig0000000f;
  wire sig00000010;
  wire sig00000011;
  wire sig00000012;
  wire sig00000013;
  wire sig00000014;
  wire sig00000015;
  wire sig00000016;
  wire sig00000017;
  wire sig00000018;
  wire sig00000019;
  wire sig0000001a;
  wire sig0000001b;
  wire sig0000001c;
  wire sig0000001d;
  wire sig0000001e;
  wire sig0000001f;
  wire sig00000020;
  wire sig00000021;
  wire sig00000022;
  wire sig00000023;
  wire sig00000024;
  wire sig00000025;
  wire sig00000026;
  wire sig00000027;
  wire sig00000028;
  wire sig00000029;
  wire sig0000002a;
  wire sig0000002b;
  wire sig0000002c;
  wire sig0000002d;
  wire sig0000002e;
  wire sig0000002f;
  wire sig00000030;
  wire sig00000031;
  wire sig00000032;
  wire sig00000033;
  wire sig00000034;
  wire sig00000035;
  wire sig00000036;
  wire sig00000037;
  wire sig00000038;
  wire sig00000039;
  wire sig0000003a;
  wire sig0000003b;
  wire sig0000003c;
  wire sig0000003d;
  wire sig0000003e;
  wire sig0000003f;
  wire sig00000040;
  wire sig00000041;
  wire sig00000042;
  wire sig00000043;
  wire sig00000044;
  wire sig00000045;
  wire sig00000046;
  wire sig00000047;
  wire sig00000048;
  wire sig00000049;
  wire sig0000004a;
  wire sig0000004b;
  wire sig0000004c;
  wire sig0000004d;
  wire sig0000004e;
  wire sig0000004f;
  wire sig00000050;
  wire sig00000051;
  wire sig00000052;
  wire sig00000053;
  wire sig00000054;
  wire sig00000055;
  wire sig00000056;
  wire sig00000057;
  wire sig00000058;
  wire sig00000059;
  wire sig0000005a;
  wire sig0000005b;
  wire sig0000005c;
  wire sig0000005d;
  wire sig0000005e;
  wire sig0000005f;
  wire sig00000060;
  wire sig00000061;
  wire sig00000062;
  wire sig00000063;
  wire sig00000064;
  wire sig00000065;
  wire sig00000066;
  wire sig00000067;
  wire sig00000068;
  wire sig00000069;
  wire sig0000006a;
  wire sig0000006b;
  wire sig0000006c;
  wire sig0000006d;
  wire sig0000006e;
  wire sig0000006f;
  wire sig00000070;
  wire sig00000071;
  wire sig00000072;
  wire sig00000073;
  wire sig00000074;
  wire sig00000075;
  wire sig00000076;
  wire sig00000077;
  wire sig00000078;
  wire sig00000079;
  wire sig0000007a;
  wire sig0000007b;
  wire sig0000007c;
  wire sig0000007d;
  wire sig0000007e;
  wire sig0000007f;
  wire sig00000080;
  wire sig00000081;
  wire sig00000082;
  wire sig00000083;
  wire sig00000084;
  wire sig00000085;
  wire sig00000086;
  wire sig00000087;
  wire sig00000088;
  wire sig00000089;
  wire sig0000008a;
  wire sig0000008b;
  wire sig0000008c;
  wire sig0000008d;
  wire sig0000008e;
  wire sig0000008f;
  wire sig00000090;
  wire sig00000091;
  wire sig00000092;
  wire sig00000093;
  wire sig00000094;
  wire sig00000095;
  wire sig00000096;
  wire sig00000097;
  wire sig00000098;
  wire sig00000099;
  wire sig0000009a;
  wire sig0000009b;
  wire sig0000009c;
  wire sig0000009d;
  wire sig0000009e;
  wire sig0000009f;
  wire sig000000a0;
  wire sig000000a1;
  wire sig000000a2;
  wire sig000000a3;
  wire sig000000a4;
  wire sig000000a5;
  wire sig000000a6;
  wire sig000000a7;
  wire sig000000a8;
  wire sig000000a9;
  wire sig000000aa;
  wire sig000000ab;
  wire sig000000ac;
  wire sig000000ad;
  wire sig000000ae;
  wire sig000000af;
  wire sig000000b0;
  wire sig000000b1;
  wire sig000000b2;
  wire sig000000b3;
  wire sig000000b4;
  wire sig000000b5;
  wire sig000000b6;
  wire sig000000b7;
  wire sig000000b8;
  wire sig000000b9;
  wire sig000000ba;
  wire sig000000bb;
  wire sig000000bc;
  wire sig000000bd;
  wire sig000000be;
  wire sig000000bf;
  wire sig000000c0;
  wire sig000000c1;
  wire sig000000c2;
  wire sig000000c3;
  wire sig000000c4;
  wire sig000000c5;
  wire sig000000c6;
  wire sig000000c7;
  wire sig000000c8;
  wire sig000000c9;
  wire sig000000ca;
  wire sig000000cb;
  wire sig000000cc;
  wire sig000000cd;
  wire sig000000ce;
  wire sig000000cf;
  wire sig000000d0;
  wire sig000000d1;
  wire sig000000d2;
  wire sig000000d3;
  wire sig000000d4;
  wire sig000000d5;
  wire sig000000d6;
  wire sig000000d7;
  wire sig000000d8;
  wire sig000000d9;
  wire sig000000da;
  wire sig000000db;
  wire sig000000dc;
  wire sig000000dd;
  wire sig000000de;
  wire sig000000df;
  wire sig000000e0;
  wire sig000000e1;
  wire sig000000e2;
  wire sig000000e3;
  wire sig000000e4;
  wire sig000000e5;
  wire sig000000e6;
  wire sig000000e7;
  wire sig000000e8;
  wire sig000000e9;
  wire sig000000ea;
  wire sig000000eb;
  wire sig000000ec;
  wire sig000000ed;
  wire sig000000ee;
  wire sig000000ef;
  wire sig000000f0;
  wire sig000000f1;
  wire sig000000f2;
  wire sig000000f3;
  wire sig000000f4;
  wire sig000000f5;
  wire sig000000f6;
  wire sig000000f7;
  wire sig000000f8;
  wire sig000000f9;
  wire sig000000fa;
  wire sig000000fb;
  wire sig000000fc;
  wire sig000000fd;
  wire sig000000fe;
  wire sig000000ff;
  wire sig00000100;
  wire sig00000101;
  wire sig00000102;
  wire sig00000103;
  wire sig00000104;
  wire sig00000105;
  wire sig00000106;
  wire sig00000107;
  wire sig00000108;
  wire sig00000109;
  wire sig0000010a;
  wire sig0000010b;
  wire sig0000010c;
  wire sig0000010d;
  wire sig0000010e;
  wire sig0000010f;
  wire sig00000110;
  wire sig00000111;
  wire sig00000112;
  wire sig00000113;
  wire sig00000114;
  wire sig00000115;
  wire sig00000116;
  wire sig00000117;
  wire sig00000118;
  wire sig00000119;
  wire sig0000011a;
  wire sig0000011b;
  wire sig0000011c;
  wire sig0000011d;
  wire sig0000011e;
  wire sig0000011f;
  wire sig00000120;
  wire sig00000121;
  wire sig00000122;
  wire sig00000123;
  wire sig00000124;
  wire sig00000125;
  wire sig00000126;
  wire sig00000127;
  wire sig00000128;
  wire sig00000129;
  wire sig0000012a;
  wire sig0000012b;
  wire sig0000012c;
  wire sig0000012d;
  wire sig0000012e;
  wire sig0000012f;
  wire sig00000130;
  wire sig00000131;
  wire sig00000132;
  wire sig00000133;
  wire sig00000134;
  wire sig00000135;
  wire sig00000136;
  wire sig00000137;
  wire sig00000138;
  wire sig00000139;
  wire sig0000013a;
  wire sig0000013b;
  wire sig0000013c;
  wire sig0000013d;
  wire sig0000013e;
  wire sig0000013f;
  wire sig00000140;
  wire sig00000141;
  wire sig00000142;
  wire sig00000143;
  wire sig00000144;
  wire sig00000145;
  wire sig00000146;
  wire sig00000147;
  wire sig00000148;
  wire sig00000149;
  wire sig0000014a;
  wire sig0000014b;
  wire sig0000014c;
  wire sig0000014d;
  wire sig0000014e;
  wire sig0000014f;
  wire sig00000150;
  wire sig00000151;
  wire sig00000152;
  wire sig00000153;
  wire sig00000154;
  wire sig00000155;
  wire sig00000156;
  wire sig00000157;
  wire sig00000158;
  wire sig00000159;
  wire sig0000015a;
  wire sig0000015b;
  wire sig0000015c;
  wire sig0000015d;
  wire sig0000015e;
  wire sig0000015f;
  wire sig00000160;
  wire sig00000161;
  wire sig00000162;
  wire sig00000163;
  wire sig00000164;
  wire sig00000165;
  wire sig00000166;
  wire sig00000167;
  wire sig00000168;
  wire sig00000169;
  wire sig0000016a;
  wire sig0000016b;
  wire sig0000016c;
  wire sig0000016d;
  wire sig0000016e;
  wire sig0000016f;
  wire sig00000170;
  wire sig00000171;
  wire sig00000172;
  wire sig00000173;
  wire sig00000174;
  wire sig00000175;
  wire sig00000176;
  wire sig00000177;
  wire sig00000178;
  wire sig00000179;
  wire sig0000017a;
  wire sig0000017b;
  wire sig0000017c;
  wire sig0000017d;
  wire sig0000017e;
  wire sig0000017f;
  wire sig00000180;
  wire sig00000181;
  wire sig00000182;
  wire sig00000183;
  wire sig00000184;
  wire sig00000185;
  wire sig00000186;
  wire sig00000187;
  wire sig00000188;
  wire sig00000189;
  wire sig0000018a;
  wire sig0000018b;
  wire sig0000018c;
  wire sig0000018d;
  wire sig0000018e;
  wire sig0000018f;
  wire sig00000190;
  wire sig00000191;
  wire sig00000192;
  wire sig00000193;
  wire sig00000194;
  wire sig00000195;
  wire sig00000196;
  wire sig00000197;
  wire sig00000198;
  wire sig00000199;
  wire sig0000019a;
  wire sig0000019b;
  wire sig0000019c;
  wire sig0000019d;
  wire sig0000019e;
  wire sig0000019f;
  wire sig000001a0;
  wire sig000001a1;
  wire sig000001a2;
  wire sig000001a3;
  wire sig000001a4;
  wire sig000001a5;
  wire sig000001a6;
  wire sig000001a7;
  wire sig000001a8;
  wire sig000001a9;
  wire sig000001aa;
  wire sig000001ab;
  wire sig000001ac;
  wire sig000001ad;
  wire sig000001ae;
  wire sig000001af;
  wire sig000001b0;
  wire sig000001b1;
  wire sig000001b2;
  wire sig000001b3;
  wire sig000001b4;
  wire sig000001b5;
  wire sig000001b6;
  wire sig000001b7;
  wire sig000001b8;
  wire sig000001b9;
  wire sig000001ba;
  wire sig000001bb;
  wire sig000001bc;
  wire sig000001bd;
  wire sig000001be;
  wire sig000001bf;
  wire sig000001c0;
  wire sig000001c1;
  wire sig000001c2;
  wire sig000001c3;
  wire sig000001c4;
  wire sig000001c5;
  wire sig000001c6;
  wire sig000001c7;
  wire sig000001c8;
  wire sig000001c9;
  wire sig000001ca;
  wire sig000001cb;
  wire sig000001cc;
  wire sig000001cd;
  wire sig000001ce;
  wire sig000001cf;
  wire sig000001d0;
  wire sig000001d1;
  wire sig000001d2;
  wire sig000001d3;
  wire sig000001d4;
  wire sig000001d5;
  wire sig000001d6;
  wire sig000001d7;
  wire sig000001d8;
  wire sig000001d9;
  wire sig000001da;
  wire sig000001db;
  wire sig000001dc;
  wire sig000001dd;
  wire sig000001de;
  wire sig000001df;
  wire sig000001e0;
  wire sig000001e1;
  wire sig000001e2;
  wire sig000001e3;
  wire sig000001e4;
  wire sig000001e5;
  wire sig000001e6;
  wire sig000001e7;
  wire sig000001e8;
  wire sig000001e9;
  wire sig000001ea;
  wire sig000001eb;
  wire sig000001ec;
  wire sig000001ed;
  wire sig000001ee;
  wire sig000001ef;
  wire sig000001f0;
  wire sig000001f1;
  wire sig000001f2;
  wire sig000001f3;
  wire sig000001f4;
  wire sig000001f5;
  wire sig000001f6;
  wire sig000001f7;
  wire sig000001f8;
  wire sig000001f9;
  wire sig000001fa;
  wire sig000001fb;
  wire sig000001fc;
  wire sig000001fd;
  wire sig000001fe;
  wire sig000001ff;
  wire sig00000200;
  wire sig00000201;
  wire sig00000202;
  wire sig00000203;
  wire sig00000204;
  wire sig00000205;
  wire sig00000206;
  wire sig00000207;
  wire sig00000208;
  wire sig00000209;
  wire sig0000020a;
  wire sig0000020b;
  wire sig0000020c;
  wire sig0000020d;
  wire sig0000020e;
  wire sig0000020f;
  wire sig00000210;
  wire sig00000211;
  wire sig00000212;
  wire sig00000213;
  wire sig00000214;
  wire sig00000215;
  wire sig00000216;
  wire sig00000217;
  wire sig00000218;
  wire sig00000219;
  wire sig0000021a;
  wire sig0000021b;
  wire sig0000021c;
  wire sig0000021d;
  wire sig0000021e;
  wire sig0000021f;
  wire sig00000220;
  wire sig00000221;
  wire sig00000222;
  wire sig00000223;
  wire sig00000224;
  wire sig00000225;
  wire sig00000226;
  wire sig00000227;
  wire sig00000228;
  wire sig00000229;
  wire sig0000022a;
  wire sig0000022b;
  wire sig0000022c;
  wire sig0000022d;
  wire sig0000022e;
  wire sig0000022f;
  wire sig00000230;
  wire sig00000231;
  wire sig00000232;
  wire sig00000233;
  wire sig00000234;
  wire sig00000235;
  wire sig00000236;
  wire sig00000237;
  wire \blk00000024/sig000002d7 ;
  wire \blk00000024/sig000002d6 ;
  wire \blk00000024/sig000002d5 ;
  wire \blk00000024/sig000002d4 ;
  wire \blk00000024/sig000002d3 ;
  wire \blk00000024/sig000002d2 ;
  wire \blk00000024/sig000002d1 ;
  wire \blk00000024/sig000002d0 ;
  wire \blk00000024/sig000002cf ;
  wire \blk00000024/sig000002ce ;
  wire \blk00000024/sig000002cd ;
  wire \blk00000024/sig000002cc ;
  wire \blk00000024/sig000002cb ;
  wire \blk00000024/sig000002ca ;
  wire \blk00000024/sig000002c9 ;
  wire \blk00000024/sig000002c8 ;
  wire \blk00000024/sig000002c7 ;
  wire \blk00000024/sig000002c6 ;
  wire \blk00000024/sig000002c5 ;
  wire \blk00000024/sig000002c4 ;
  wire \blk00000024/sig000002c3 ;
  wire \blk00000024/sig000002c2 ;
  wire \blk00000024/sig000002c1 ;
  wire \blk00000024/sig000002c0 ;
  wire \blk00000024/sig000002bf ;
  wire \blk00000024/sig000002be ;
  wire \blk00000024/sig000002bd ;
  wire \blk00000024/sig000002bc ;
  wire \blk00000024/sig000002bb ;
  wire \blk00000024/sig000002ba ;
  wire \blk00000024/sig000002b9 ;
  wire \blk00000024/sig000002b8 ;
  wire \blk00000024/sig000002b7 ;
  wire \blk00000024/sig000002b6 ;
  wire \blk00000024/sig000002b5 ;
  wire \blk00000024/sig000002b4 ;
  wire \blk00000024/sig000002b3 ;
  wire \blk00000024/sig000002b2 ;
  wire \blk00000024/sig000002b1 ;
  wire \blk00000024/sig000002b0 ;
  wire \blk00000024/sig000002af ;
  wire \blk00000024/sig000002ae ;
  wire \blk00000024/sig000002ad ;
  wire \blk00000024/sig000002ac ;
  wire \blk00000024/sig000002ab ;
  wire \blk00000024/sig000002aa ;
  wire \blk00000024/sig000002a9 ;
  wire \blk00000024/sig000002a8 ;
  wire \blk00000024/sig000002a7 ;
  wire \blk00000024/sig000002a6 ;
  wire \blk00000024/sig000002a5 ;
  wire \blk00000024/sig000002a4 ;
  wire \blk00000024/sig000002a3 ;
  wire \blk00000024/sig000002a2 ;
  wire \blk00000024/sig000002a1 ;
  wire \blk00000024/sig000002a0 ;
  wire \blk00000024/sig0000029f ;
  wire \blk00000024/sig0000029e ;
  wire \blk00000024/sig0000029d ;
  wire \blk00000024/sig0000029c ;
  wire \blk00000024/sig0000029b ;
  wire \blk00000024/sig0000029a ;
  wire \blk00000024/sig00000299 ;
  wire \blk00000024/sig00000298 ;
  wire NLW_blk0000009a_CARRYOUTF_UNCONNECTED;
  wire NLW_blk0000009a_CARRYOUT_UNCONNECTED;
  wire \NLW_blk0000009a_BCOUT<17>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<16>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<15>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<14>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<13>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<12>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<11>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<10>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<9>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<8>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<7>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<6>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<5>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<4>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<3>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<2>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<1>_UNCONNECTED ;
  wire \NLW_blk0000009a_BCOUT<0>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<23>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<22>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<21>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<20>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<19>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<18>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<17>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<16>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<15>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<14>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<13>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<12>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<11>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<10>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<9>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<8>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<7>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<6>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<5>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<4>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<3>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<2>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<1>_UNCONNECTED ;
  wire \NLW_blk0000009a_P<0>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<47>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<46>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<45>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<44>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<43>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<42>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<41>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<40>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<39>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<38>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<37>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<36>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<35>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<34>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<33>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<32>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<31>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<30>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<29>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<28>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<27>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<26>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<25>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<24>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<23>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<22>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<21>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<20>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<19>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<18>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<17>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<16>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<15>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<14>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<13>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<12>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<11>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<10>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<9>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<8>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<7>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<6>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<5>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<4>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<3>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<2>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<1>_UNCONNECTED ;
  wire \NLW_blk0000009a_PCOUT<0>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<35>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<34>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<33>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<32>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<31>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<30>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<29>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<28>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<27>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<26>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<25>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<24>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<23>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<22>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<21>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<20>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<19>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<18>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<17>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<16>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<15>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<14>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<13>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<12>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<11>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<10>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<9>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<8>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<7>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<6>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<5>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<4>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<3>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<2>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<1>_UNCONNECTED ;
  wire \NLW_blk0000009a_M<0>_UNCONNECTED ;
  wire NLW_blk0000009b_CARRYOUTF_UNCONNECTED;
  wire NLW_blk0000009b_CARRYOUT_UNCONNECTED;
  wire \NLW_blk0000009b_BCOUT<17>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<16>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<15>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<14>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<13>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<12>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<11>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<10>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<9>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<8>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<7>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<6>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<5>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<4>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<3>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<2>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<1>_UNCONNECTED ;
  wire \NLW_blk0000009b_BCOUT<0>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<23>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<22>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<21>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<20>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<19>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<18>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<17>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<16>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<15>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<14>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<13>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<12>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<11>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<10>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<9>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<8>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<7>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<6>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<5>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<4>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<3>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<2>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<1>_UNCONNECTED ;
  wire \NLW_blk0000009b_P<0>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<47>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<46>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<45>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<44>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<43>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<42>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<41>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<40>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<39>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<38>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<37>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<36>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<35>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<34>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<33>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<32>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<31>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<30>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<29>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<28>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<27>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<26>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<25>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<24>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<23>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<22>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<21>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<20>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<19>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<18>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<17>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<16>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<15>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<14>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<13>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<12>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<11>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<10>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<9>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<8>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<7>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<6>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<5>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<4>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<3>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<2>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<1>_UNCONNECTED ;
  wire \NLW_blk0000009b_PCOUT<0>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<35>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<34>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<33>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<32>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<31>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<30>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<29>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<28>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<27>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<26>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<25>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<24>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<23>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<22>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<21>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<20>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<19>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<18>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<17>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<16>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<15>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<14>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<13>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<12>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<11>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<10>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<9>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<8>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<7>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<6>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<5>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<4>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<3>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<2>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<1>_UNCONNECTED ;
  wire \NLW_blk0000009b_M<0>_UNCONNECTED ;
  wire NLW_blk0000009c_CARRYOUTF_UNCONNECTED;
  wire NLW_blk0000009c_CARRYOUT_UNCONNECTED;
  wire \NLW_blk0000009c_BCOUT<17>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<16>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<15>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<14>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<13>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<12>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<11>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<10>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<9>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<8>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<7>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<6>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<5>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<4>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<3>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<2>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<1>_UNCONNECTED ;
  wire \NLW_blk0000009c_BCOUT<0>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<47>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<46>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<45>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<44>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<43>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<42>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<5>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<4>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<3>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<2>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<1>_UNCONNECTED ;
  wire \NLW_blk0000009c_P<0>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<47>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<46>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<45>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<44>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<43>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<42>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<41>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<40>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<39>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<38>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<37>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<36>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<35>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<34>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<33>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<32>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<31>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<30>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<29>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<28>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<27>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<26>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<25>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<24>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<23>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<22>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<21>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<20>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<19>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<18>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<17>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<16>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<15>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<14>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<13>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<12>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<11>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<10>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<9>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<8>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<7>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<6>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<5>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<4>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<3>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<2>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<1>_UNCONNECTED ;
  wire \NLW_blk0000009c_PCOUT<0>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<35>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<34>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<33>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<32>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<31>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<30>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<29>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<28>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<27>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<26>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<25>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<24>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<23>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<22>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<21>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<20>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<19>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<18>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<17>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<16>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<15>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<14>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<13>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<12>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<11>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<10>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<9>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<8>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<7>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<6>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<5>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<4>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<3>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<2>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<1>_UNCONNECTED ;
  wire \NLW_blk0000009c_M<0>_UNCONNECTED ;
  wire NLW_blk0000009d_CARRYOUTF_UNCONNECTED;
  wire NLW_blk0000009d_CARRYOUT_UNCONNECTED;
  wire \NLW_blk0000009d_BCOUT<17>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<16>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<15>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<14>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<13>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<12>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<11>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<10>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<9>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<8>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<7>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<6>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<5>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<4>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<3>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<2>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<1>_UNCONNECTED ;
  wire \NLW_blk0000009d_BCOUT<0>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<47>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<46>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<45>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<44>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<43>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<42>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<5>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<4>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<3>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<2>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<1>_UNCONNECTED ;
  wire \NLW_blk0000009d_P<0>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<47>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<46>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<45>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<44>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<43>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<42>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<41>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<40>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<39>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<38>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<37>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<36>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<35>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<34>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<33>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<32>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<31>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<30>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<29>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<28>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<27>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<26>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<25>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<24>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<23>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<22>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<21>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<20>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<19>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<18>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<17>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<16>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<15>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<14>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<13>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<12>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<11>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<10>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<9>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<8>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<7>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<6>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<5>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<4>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<3>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<2>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<1>_UNCONNECTED ;
  wire \NLW_blk0000009d_PCOUT<0>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<35>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<34>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<33>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<32>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<31>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<30>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<29>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<28>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<27>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<26>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<25>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<24>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<23>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<22>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<21>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<20>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<19>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<18>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<17>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<16>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<15>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<14>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<13>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<12>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<11>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<10>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<9>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<8>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<7>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<6>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<5>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<4>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<3>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<2>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<1>_UNCONNECTED ;
  wire \NLW_blk0000009d_M<0>_UNCONNECTED ;
  wire NLW_blk0000009e_CARRYOUTF_UNCONNECTED;
  wire NLW_blk0000009e_CARRYOUT_UNCONNECTED;
  wire \NLW_blk0000009e_BCOUT<17>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<16>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<15>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<14>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<13>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<12>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<11>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<10>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<9>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<8>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<7>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<6>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<5>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<4>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<3>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<2>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<1>_UNCONNECTED ;
  wire \NLW_blk0000009e_BCOUT<0>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<47>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<46>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<45>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<44>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<43>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<42>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<41>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<40>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<39>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<38>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<37>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<36>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<17>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<16>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<15>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<14>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<13>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<12>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<11>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<10>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<9>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<8>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<7>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<6>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<5>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<4>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<3>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<2>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<1>_UNCONNECTED ;
  wire \NLW_blk0000009e_P<0>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<47>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<46>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<45>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<44>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<43>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<42>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<41>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<40>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<39>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<38>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<37>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<36>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<35>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<34>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<33>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<32>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<31>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<30>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<29>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<28>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<27>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<26>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<25>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<24>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<23>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<22>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<21>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<20>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<19>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<18>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<17>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<16>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<15>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<14>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<13>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<12>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<11>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<10>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<9>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<8>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<7>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<6>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<5>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<4>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<3>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<2>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<1>_UNCONNECTED ;
  wire \NLW_blk0000009e_PCOUT<0>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<35>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<34>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<33>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<32>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<31>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<30>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<29>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<28>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<27>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<26>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<25>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<24>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<23>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<22>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<21>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<20>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<19>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<18>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<17>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<16>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<15>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<14>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<13>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<12>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<11>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<10>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<9>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<8>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<7>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<6>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<5>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<4>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<3>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<2>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<1>_UNCONNECTED ;
  wire \NLW_blk0000009e_M<0>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIPA<3>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIPA<2>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<31>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<30>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<29>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<28>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<27>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<26>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<25>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<24>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<23>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<22>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<21>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<20>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<19>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<18>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<17>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOA<16>_UNCONNECTED ;
  wire \NLW_blk0000017a_ADDRA<3>_UNCONNECTED ;
  wire \NLW_blk0000017a_ADDRA<2>_UNCONNECTED ;
  wire \NLW_blk0000017a_ADDRA<1>_UNCONNECTED ;
  wire \NLW_blk0000017a_ADDRA<0>_UNCONNECTED ;
  wire \NLW_blk0000017a_ADDRB<3>_UNCONNECTED ;
  wire \NLW_blk0000017a_ADDRB<2>_UNCONNECTED ;
  wire \NLW_blk0000017a_ADDRB<1>_UNCONNECTED ;
  wire \NLW_blk0000017a_ADDRB<0>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<31>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<30>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<29>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<28>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<27>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<26>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<25>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<24>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<23>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<22>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<21>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<20>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<19>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<18>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<17>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<16>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<15>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<14>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<13>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<12>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<11>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<10>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<9>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<8>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<7>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<6>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<5>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<4>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<3>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<2>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<1>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIB<0>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOPA<3>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOPA<2>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIPB<3>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIPB<2>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIPB<1>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIPB<0>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOPB<3>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOPB<2>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<31>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<30>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<29>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<28>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<27>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<26>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<25>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<24>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<23>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<22>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<21>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<20>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<19>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<18>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<17>_UNCONNECTED ;
  wire \NLW_blk0000017a_DOB<16>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<31>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<30>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<29>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<28>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<27>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<26>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<25>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<24>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<23>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<22>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<21>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<20>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<19>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<18>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<17>_UNCONNECTED ;
  wire \NLW_blk0000017a_DIA<16>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOADO<15>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOADO<14>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOADO<13>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOADO<12>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOADO<11>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOADO<10>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOADO<9>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOADO<8>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOADO<7>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOADO<6>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOPADOP<1>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOPADOP<0>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOPBDOP<1>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOPBDOP<0>_UNCONNECTED ;
  wire \NLW_blk0000017b_ADDRAWRADDR<2>_UNCONNECTED ;
  wire \NLW_blk0000017b_ADDRAWRADDR<1>_UNCONNECTED ;
  wire \NLW_blk0000017b_ADDRAWRADDR<0>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIPBDIP<1>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIPBDIP<0>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<15>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<14>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<13>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<12>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<11>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<10>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<9>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<8>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<7>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<6>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<5>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<4>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<3>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<2>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<1>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIBDI<0>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIADI<15>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIADI<14>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIADI<13>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIADI<12>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIADI<11>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIADI<10>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIADI<9>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIADI<8>_UNCONNECTED ;
  wire \NLW_blk0000017b_ADDRBRDADDR<2>_UNCONNECTED ;
  wire \NLW_blk0000017b_ADDRBRDADDR<1>_UNCONNECTED ;
  wire \NLW_blk0000017b_ADDRBRDADDR<0>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOBDO<15>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOBDO<14>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOBDO<13>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOBDO<12>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOBDO<11>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOBDO<10>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOBDO<9>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOBDO<8>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOBDO<7>_UNCONNECTED ;
  wire \NLW_blk0000017b_DOBDO<6>_UNCONNECTED ;
  wire \NLW_blk0000017b_DIPADIP<1>_UNCONNECTED ;
  wire NLW_blk0000017c_ENB_UNCONNECTED;
  wire NLW_blk0000017c_RSTB_UNCONNECTED;
  wire NLW_blk0000017c_CLKB_UNCONNECTED;
  wire NLW_blk0000017c_REGCEB_UNCONNECTED;
  wire \NLW_blk0000017c_DIPA<3>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIPA<2>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<31>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<30>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<29>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<28>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<27>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<26>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<25>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<24>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<23>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<22>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<21>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<20>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<19>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<18>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<17>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOA<16>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRA<3>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRA<2>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRA<1>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRA<0>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<13>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<12>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<11>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<10>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<9>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<8>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<7>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<6>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<5>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<4>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<3>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<2>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<1>_UNCONNECTED ;
  wire \NLW_blk0000017c_ADDRB<0>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<31>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<30>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<29>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<28>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<27>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<26>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<25>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<24>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<23>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<22>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<21>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<20>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<19>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<18>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<17>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<16>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<15>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<14>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<13>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<12>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<11>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<10>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<9>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<8>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<7>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<6>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<5>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<4>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<3>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<2>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<1>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIB<0>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOPA<3>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOPA<2>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIPB<3>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIPB<2>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIPB<1>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIPB<0>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOPB<3>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOPB<2>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOPB<1>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOPB<0>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<31>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<30>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<29>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<28>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<27>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<26>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<25>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<24>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<23>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<22>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<21>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<20>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<19>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<18>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<17>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<16>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<15>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<14>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<13>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<12>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<11>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<10>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<9>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<8>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<7>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<6>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<5>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<4>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<3>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<2>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<1>_UNCONNECTED ;
  wire \NLW_blk0000017c_DOB<0>_UNCONNECTED ;
  wire \NLW_blk0000017c_WEB<3>_UNCONNECTED ;
  wire \NLW_blk0000017c_WEB<2>_UNCONNECTED ;
  wire \NLW_blk0000017c_WEB<1>_UNCONNECTED ;
  wire \NLW_blk0000017c_WEB<0>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<31>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<30>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<29>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<28>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<27>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<26>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<25>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<24>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<23>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<22>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<21>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<20>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<19>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<18>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<17>_UNCONNECTED ;
  wire \NLW_blk0000017c_DIA<16>_UNCONNECTED ;
  wire NLW_blk0000017d_Q15_UNCONNECTED;
  wire NLW_blk0000017f_Q15_UNCONNECTED;
  wire NLW_blk00000181_Q15_UNCONNECTED;
  wire NLW_blk00000183_Q15_UNCONNECTED;
  wire NLW_blk00000185_Q15_UNCONNECTED;
  wire NLW_blk00000187_Q15_UNCONNECTED;
  wire NLW_blk00000189_Q15_UNCONNECTED;
  wire NLW_blk0000018b_Q15_UNCONNECTED;
  wire NLW_blk0000018d_Q15_UNCONNECTED;
  wire NLW_blk0000018f_Q15_UNCONNECTED;
  wire NLW_blk00000191_Q15_UNCONNECTED;
  wire NLW_blk00000193_Q15_UNCONNECTED;
  wire NLW_blk00000195_Q15_UNCONNECTED;
  wire NLW_blk00000197_Q15_UNCONNECTED;
  wire NLW_blk00000199_Q15_UNCONNECTED;
  wire NLW_blk0000019b_Q15_UNCONNECTED;
  wire NLW_blk0000019d_Q15_UNCONNECTED;
  wire NLW_blk0000019f_Q15_UNCONNECTED;
  wire NLW_blk000001a1_Q15_UNCONNECTED;
  wire NLW_blk000001a2_Q15_UNCONNECTED;
  wire NLW_blk000001a3_Q15_UNCONNECTED;
  wire NLW_blk000001a4_Q15_UNCONNECTED;
  wire NLW_blk000001a5_Q15_UNCONNECTED;
  wire NLW_blk000001a6_Q15_UNCONNECTED;
  wire NLW_blk000001a7_Q15_UNCONNECTED;
  wire NLW_blk000001a9_Q15_UNCONNECTED;
  wire NLW_blk000001ab_Q15_UNCONNECTED;
  wire NLW_blk000001ad_Q15_UNCONNECTED;
  wire NLW_blk000001af_Q15_UNCONNECTED;
  wire NLW_blk000001b1_Q15_UNCONNECTED;
  wire NLW_blk000001b3_Q15_UNCONNECTED;
  wire NLW_blk000001b5_Q15_UNCONNECTED;
  wire NLW_blk000001b7_Q15_UNCONNECTED;
  wire NLW_blk000001b9_Q15_UNCONNECTED;
  wire NLW_blk000001bb_Q15_UNCONNECTED;
  wire NLW_blk000001bd_Q15_UNCONNECTED;
  wire NLW_blk000001bf_Q15_UNCONNECTED;
  wire NLW_blk000001c1_Q15_UNCONNECTED;
  wire NLW_blk000001c3_Q15_UNCONNECTED;
  wire NLW_blk000001c5_Q15_UNCONNECTED;
  wire NLW_blk000001c7_Q15_UNCONNECTED;
  wire NLW_blk000001c9_Q15_UNCONNECTED;
  wire NLW_blk000001ca_Q15_UNCONNECTED;
  wire NLW_blk000001cc_Q15_UNCONNECTED;
  wire NLW_blk000001cd_Q15_UNCONNECTED;
  wire NLW_blk000001ce_Q15_UNCONNECTED;
  wire NLW_blk000001cf_Q15_UNCONNECTED;
  wire NLW_blk000001d0_Q15_UNCONNECTED;
  wire NLW_blk000001d1_Q15_UNCONNECTED;
  wire NLW_blk000001d3_Q15_UNCONNECTED;
  wire NLW_blk000001d5_Q15_UNCONNECTED;
  wire NLW_blk000001d7_Q15_UNCONNECTED;
  wire NLW_blk000001d9_Q15_UNCONNECTED;
  wire NLW_blk000001db_Q15_UNCONNECTED;
  wire NLW_blk000001dd_Q15_UNCONNECTED;
  wire NLW_blk000001df_Q15_UNCONNECTED;
  wire NLW_blk000001e1_Q15_UNCONNECTED;
  wire NLW_blk000001e3_Q15_UNCONNECTED;
  VCC   blk00000001 (
    .P(sig00000001)
  );
  GND   blk00000002 (
    .G(sig00000189)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000003 (
    .C(clk),
    .D(sig00000002),
    .Q(sig00000073)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000004 (
    .C(clk),
    .D(sig00000003),
    .Q(sig00000072)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000005 (
    .C(clk),
    .D(sig00000004),
    .Q(sig00000071)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000006 (
    .C(clk),
    .D(sig00000005),
    .Q(sig00000070)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000007 (
    .C(clk),
    .D(sig00000006),
    .Q(sig0000006f)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000008 (
    .C(clk),
    .D(sig00000007),
    .Q(sig0000006e)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000009 (
    .C(clk),
    .D(sig00000008),
    .Q(sig0000006d)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000a (
    .C(clk),
    .D(sig00000009),
    .Q(sig0000006c)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000b (
    .C(clk),
    .D(sig0000000a),
    .Q(sig0000006b)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000c (
    .C(clk),
    .D(sig0000000b),
    .Q(sig0000006a)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000d (
    .C(clk),
    .D(sig0000000c),
    .Q(sig00000069)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000e (
    .C(clk),
    .D(sig0000000d),
    .Q(sig00000068)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000f (
    .C(clk),
    .D(sig0000000e),
    .Q(sig00000067)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000010 (
    .C(clk),
    .D(sig0000000f),
    .Q(sig00000066)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000011 (
    .C(clk),
    .D(sig00000010),
    .Q(sig00000065)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000012 (
    .C(clk),
    .D(sig00000011),
    .Q(sig00000064)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000013 (
    .C(clk),
    .D(sig00000012),
    .Q(sig00000063)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000014 (
    .C(clk),
    .D(sig00000013),
    .Q(sig00000062)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000015 (
    .C(clk),
    .D(sig00000014),
    .Q(sig00000061)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000016 (
    .C(clk),
    .D(sig00000015),
    .Q(sig00000060)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000017 (
    .C(clk),
    .D(sig00000016),
    .Q(sig0000005f)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000018 (
    .C(clk),
    .D(sig00000017),
    .Q(sig0000005e)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000019 (
    .C(clk),
    .D(sig00000018),
    .Q(sig0000005d)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001a (
    .C(clk),
    .D(sig00000019),
    .Q(sig0000005c)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001b (
    .C(clk),
    .D(sig0000001a),
    .Q(sig0000005b)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001c (
    .C(clk),
    .D(sig0000001b),
    .Q(sig0000005a)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001d (
    .C(clk),
    .D(sig0000001c),
    .Q(sig00000059)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001e (
    .C(clk),
    .D(sig0000001d),
    .Q(sig00000058)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001f (
    .C(clk),
    .D(sig0000001e),
    .Q(sig00000057)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000020 (
    .C(clk),
    .D(sig0000001f),
    .Q(sig00000056)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000021 (
    .C(clk),
    .D(sig00000020),
    .Q(sig00000055)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000022 (
    .C(clk),
    .D(sig00000021),
    .Q(sig00000054)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000023 (
    .C(clk),
    .D(sig00000022),
    .Q(sig00000053)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000086 (
    .C(clk),
    .D(sig00000074),
    .Q(sig000000c0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000087 (
    .C(clk),
    .D(sig00000086),
    .Q(sig000000bf)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000088 (
    .C(clk),
    .D(sig00000085),
    .Q(sig000000be)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000089 (
    .C(clk),
    .D(sig00000084),
    .Q(sig000000bd)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008a (
    .C(clk),
    .D(sig00000083),
    .Q(sig000000bc)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008b (
    .C(clk),
    .D(sig00000082),
    .Q(sig000000bb)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008c (
    .C(clk),
    .D(sig00000081),
    .Q(sig000000ba)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008d (
    .C(clk),
    .D(sig00000080),
    .Q(sig000000b9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008e (
    .C(clk),
    .D(sig0000007f),
    .Q(sig000000b8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008f (
    .C(clk),
    .D(sig0000007e),
    .Q(sig000000b7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000090 (
    .C(clk),
    .D(sig00000072),
    .Q(sig000000ca)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000091 (
    .C(clk),
    .D(sig0000007d),
    .Q(sig000000c9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000092 (
    .C(clk),
    .D(sig0000007c),
    .Q(sig000000c8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000093 (
    .C(clk),
    .D(sig0000007b),
    .Q(sig000000c7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000094 (
    .C(clk),
    .D(sig0000007a),
    .Q(sig000000c6)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000095 (
    .C(clk),
    .D(sig00000079),
    .Q(sig000000c5)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000096 (
    .C(clk),
    .D(sig00000078),
    .Q(sig000000c4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000097 (
    .C(clk),
    .D(sig00000077),
    .Q(sig000000c3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000098 (
    .C(clk),
    .D(sig00000076),
    .Q(sig000000c2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000099 (
    .C(clk),
    .D(sig00000075),
    .Q(sig000000c1)
  );
  DSP48A1 #(
    .A0REG ( 0 ),
    .A1REG ( 1 ),
    .B0REG ( 0 ),
    .B1REG ( 1 ),
    .CARRYINREG ( 0 ),
    .CARRYINSEL ( "OPMODE5" ),
    .CREG ( 1 ),
    .DREG ( 1 ),
    .MREG ( 1 ),
    .OPMODEREG ( 1 ),
    .PREG ( 1 ),
    .RSTTYPE ( "SYNC" ),
    .CARRYOUTREG ( 0 ))
  blk0000009a (
    .CECARRYIN(sig00000189),
    .RSTC(sig00000189),
    .RSTCARRYIN(sig00000189),
    .CED(sig00000001),
    .RSTD(sig00000189),
    .CEOPMODE(sig00000001),
    .CEC(sig00000001),
    .CARRYOUTF(NLW_blk0000009a_CARRYOUTF_UNCONNECTED),
    .RSTOPMODE(sig00000189),
    .RSTM(sig00000189),
    .CLK(clk),
    .RSTB(sig00000189),
    .CEM(sig00000001),
    .CEB(sig00000001),
    .CARRYIN(sig00000189),
    .CEP(sig00000001),
    .CEA(sig00000001),
    .CARRYOUT(NLW_blk0000009a_CARRYOUT_UNCONNECTED),
    .RSTA(sig00000189),
    .RSTP(sig00000189),
    .B({sig000000cb, sig000000cc, sig000000cd, sig000000ce, sig000000cf, sig000000d0, sig000000d1, sig000000d2, sig000000d3, sig000000d4, sig000000d5
, sig000000d6, sig000000d7, sig000000d8, sig000000d9, sig000000da, sig000000db, sig000000dc}),
    .BCOUT({\NLW_blk0000009a_BCOUT<17>_UNCONNECTED , \NLW_blk0000009a_BCOUT<16>_UNCONNECTED , \NLW_blk0000009a_BCOUT<15>_UNCONNECTED , 
\NLW_blk0000009a_BCOUT<14>_UNCONNECTED , \NLW_blk0000009a_BCOUT<13>_UNCONNECTED , \NLW_blk0000009a_BCOUT<12>_UNCONNECTED , 
\NLW_blk0000009a_BCOUT<11>_UNCONNECTED , \NLW_blk0000009a_BCOUT<10>_UNCONNECTED , \NLW_blk0000009a_BCOUT<9>_UNCONNECTED , 
\NLW_blk0000009a_BCOUT<8>_UNCONNECTED , \NLW_blk0000009a_BCOUT<7>_UNCONNECTED , \NLW_blk0000009a_BCOUT<6>_UNCONNECTED , 
\NLW_blk0000009a_BCOUT<5>_UNCONNECTED , \NLW_blk0000009a_BCOUT<4>_UNCONNECTED , \NLW_blk0000009a_BCOUT<3>_UNCONNECTED , 
\NLW_blk0000009a_BCOUT<2>_UNCONNECTED , \NLW_blk0000009a_BCOUT<1>_UNCONNECTED , \NLW_blk0000009a_BCOUT<0>_UNCONNECTED }),
    .PCIN({sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189}),
    .C({sig00000152, sig00000151, sig00000150, sig0000014f, sig0000014e, sig0000014d, sig0000014c, sig0000014b, sig0000014a, sig00000149, sig00000148
, sig00000147, sig00000146, sig00000145, sig00000144, sig00000143, sig00000142, sig00000141, sig00000140, sig0000013f, sig0000013e, sig0000013d, 
sig0000013c, sig0000013b, sig0000013a, sig00000139, sig00000138, sig00000137, sig00000136, sig00000135, sig00000134, sig00000133, sig00000132, 
sig00000131, sig00000130, sig0000012f, sig00000001, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189}),
    .P({cosine[23], cosine[22], cosine[21], cosine[20], cosine[19], cosine[18], cosine[17], cosine[16], cosine[15], cosine[14], cosine[13], cosine[12]
, cosine[11], cosine[10], cosine[9], cosine[8], cosine[7], cosine[6], cosine[5], cosine[4], cosine[3], cosine[2], cosine[1], cosine[0], 
\NLW_blk0000009a_P<23>_UNCONNECTED , \NLW_blk0000009a_P<22>_UNCONNECTED , \NLW_blk0000009a_P<21>_UNCONNECTED , \NLW_blk0000009a_P<20>_UNCONNECTED , 
\NLW_blk0000009a_P<19>_UNCONNECTED , \NLW_blk0000009a_P<18>_UNCONNECTED , \NLW_blk0000009a_P<17>_UNCONNECTED , \NLW_blk0000009a_P<16>_UNCONNECTED , 
\NLW_blk0000009a_P<15>_UNCONNECTED , \NLW_blk0000009a_P<14>_UNCONNECTED , \NLW_blk0000009a_P<13>_UNCONNECTED , \NLW_blk0000009a_P<12>_UNCONNECTED , 
\NLW_blk0000009a_P<11>_UNCONNECTED , \NLW_blk0000009a_P<10>_UNCONNECTED , \NLW_blk0000009a_P<9>_UNCONNECTED , \NLW_blk0000009a_P<8>_UNCONNECTED , 
\NLW_blk0000009a_P<7>_UNCONNECTED , \NLW_blk0000009a_P<6>_UNCONNECTED , \NLW_blk0000009a_P<5>_UNCONNECTED , \NLW_blk0000009a_P<4>_UNCONNECTED , 
\NLW_blk0000009a_P<3>_UNCONNECTED , \NLW_blk0000009a_P<2>_UNCONNECTED , \NLW_blk0000009a_P<1>_UNCONNECTED , \NLW_blk0000009a_P<0>_UNCONNECTED }),
    .OPMODE({sig00000001, sig00000189, sig00000189, sig00000189, sig00000001, sig00000001, sig00000189, sig00000001}),
    .D({sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189
, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189}),
    .PCOUT({\NLW_blk0000009a_PCOUT<47>_UNCONNECTED , \NLW_blk0000009a_PCOUT<46>_UNCONNECTED , \NLW_blk0000009a_PCOUT<45>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<44>_UNCONNECTED , \NLW_blk0000009a_PCOUT<43>_UNCONNECTED , \NLW_blk0000009a_PCOUT<42>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<41>_UNCONNECTED , \NLW_blk0000009a_PCOUT<40>_UNCONNECTED , \NLW_blk0000009a_PCOUT<39>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<38>_UNCONNECTED , \NLW_blk0000009a_PCOUT<37>_UNCONNECTED , \NLW_blk0000009a_PCOUT<36>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<35>_UNCONNECTED , \NLW_blk0000009a_PCOUT<34>_UNCONNECTED , \NLW_blk0000009a_PCOUT<33>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<32>_UNCONNECTED , \NLW_blk0000009a_PCOUT<31>_UNCONNECTED , \NLW_blk0000009a_PCOUT<30>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<29>_UNCONNECTED , \NLW_blk0000009a_PCOUT<28>_UNCONNECTED , \NLW_blk0000009a_PCOUT<27>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<26>_UNCONNECTED , \NLW_blk0000009a_PCOUT<25>_UNCONNECTED , \NLW_blk0000009a_PCOUT<24>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<23>_UNCONNECTED , \NLW_blk0000009a_PCOUT<22>_UNCONNECTED , \NLW_blk0000009a_PCOUT<21>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<20>_UNCONNECTED , \NLW_blk0000009a_PCOUT<19>_UNCONNECTED , \NLW_blk0000009a_PCOUT<18>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<17>_UNCONNECTED , \NLW_blk0000009a_PCOUT<16>_UNCONNECTED , \NLW_blk0000009a_PCOUT<15>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<14>_UNCONNECTED , \NLW_blk0000009a_PCOUT<13>_UNCONNECTED , \NLW_blk0000009a_PCOUT<12>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<11>_UNCONNECTED , \NLW_blk0000009a_PCOUT<10>_UNCONNECTED , \NLW_blk0000009a_PCOUT<9>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<8>_UNCONNECTED , \NLW_blk0000009a_PCOUT<7>_UNCONNECTED , \NLW_blk0000009a_PCOUT<6>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<5>_UNCONNECTED , \NLW_blk0000009a_PCOUT<4>_UNCONNECTED , \NLW_blk0000009a_PCOUT<3>_UNCONNECTED , 
\NLW_blk0000009a_PCOUT<2>_UNCONNECTED , \NLW_blk0000009a_PCOUT<1>_UNCONNECTED , \NLW_blk0000009a_PCOUT<0>_UNCONNECTED }),
    .A({sig00000112, sig00000111, sig00000110, sig0000010f, sig0000010e, sig0000010d, sig0000010c, sig0000010b, sig0000010a, sig00000109, sig00000108
, sig00000107, sig00000106, sig00000105, sig00000104, sig00000103, sig00000102, sig00000101}),
    .M({\NLW_blk0000009a_M<35>_UNCONNECTED , \NLW_blk0000009a_M<34>_UNCONNECTED , \NLW_blk0000009a_M<33>_UNCONNECTED , 
\NLW_blk0000009a_M<32>_UNCONNECTED , \NLW_blk0000009a_M<31>_UNCONNECTED , \NLW_blk0000009a_M<30>_UNCONNECTED , \NLW_blk0000009a_M<29>_UNCONNECTED , 
\NLW_blk0000009a_M<28>_UNCONNECTED , \NLW_blk0000009a_M<27>_UNCONNECTED , \NLW_blk0000009a_M<26>_UNCONNECTED , \NLW_blk0000009a_M<25>_UNCONNECTED , 
\NLW_blk0000009a_M<24>_UNCONNECTED , \NLW_blk0000009a_M<23>_UNCONNECTED , \NLW_blk0000009a_M<22>_UNCONNECTED , \NLW_blk0000009a_M<21>_UNCONNECTED , 
\NLW_blk0000009a_M<20>_UNCONNECTED , \NLW_blk0000009a_M<19>_UNCONNECTED , \NLW_blk0000009a_M<18>_UNCONNECTED , \NLW_blk0000009a_M<17>_UNCONNECTED , 
\NLW_blk0000009a_M<16>_UNCONNECTED , \NLW_blk0000009a_M<15>_UNCONNECTED , \NLW_blk0000009a_M<14>_UNCONNECTED , \NLW_blk0000009a_M<13>_UNCONNECTED , 
\NLW_blk0000009a_M<12>_UNCONNECTED , \NLW_blk0000009a_M<11>_UNCONNECTED , \NLW_blk0000009a_M<10>_UNCONNECTED , \NLW_blk0000009a_M<9>_UNCONNECTED , 
\NLW_blk0000009a_M<8>_UNCONNECTED , \NLW_blk0000009a_M<7>_UNCONNECTED , \NLW_blk0000009a_M<6>_UNCONNECTED , \NLW_blk0000009a_M<5>_UNCONNECTED , 
\NLW_blk0000009a_M<4>_UNCONNECTED , \NLW_blk0000009a_M<3>_UNCONNECTED , \NLW_blk0000009a_M<2>_UNCONNECTED , \NLW_blk0000009a_M<1>_UNCONNECTED , 
\NLW_blk0000009a_M<0>_UNCONNECTED })
  );
  DSP48A1 #(
    .A0REG ( 0 ),
    .A1REG ( 1 ),
    .B0REG ( 0 ),
    .B1REG ( 1 ),
    .CARRYINREG ( 0 ),
    .CARRYINSEL ( "OPMODE5" ),
    .CREG ( 1 ),
    .DREG ( 1 ),
    .MREG ( 1 ),
    .OPMODEREG ( 1 ),
    .PREG ( 1 ),
    .RSTTYPE ( "SYNC" ),
    .CARRYOUTREG ( 0 ))
  blk0000009b (
    .CECARRYIN(sig00000189),
    .RSTC(sig00000189),
    .RSTCARRYIN(sig00000189),
    .CED(sig00000001),
    .RSTD(sig00000189),
    .CEOPMODE(sig00000001),
    .CEC(sig00000001),
    .CARRYOUTF(NLW_blk0000009b_CARRYOUTF_UNCONNECTED),
    .RSTOPMODE(sig00000189),
    .RSTM(sig00000189),
    .CLK(clk),
    .RSTB(sig00000189),
    .CEM(sig00000001),
    .CEB(sig00000001),
    .CARRYIN(sig00000189),
    .CEP(sig00000001),
    .CEA(sig00000001),
    .CARRYOUT(NLW_blk0000009b_CARRYOUT_UNCONNECTED),
    .RSTA(sig00000189),
    .RSTP(sig00000189),
    .B({sig000000cb, sig000000cc, sig000000cd, sig000000ce, sig000000cf, sig000000d0, sig000000d1, sig000000d2, sig000000d3, sig000000d4, sig000000d5
, sig000000d6, sig000000d7, sig000000d8, sig000000d9, sig000000da, sig000000db, sig000000dc}),
    .BCOUT({\NLW_blk0000009b_BCOUT<17>_UNCONNECTED , \NLW_blk0000009b_BCOUT<16>_UNCONNECTED , \NLW_blk0000009b_BCOUT<15>_UNCONNECTED , 
\NLW_blk0000009b_BCOUT<14>_UNCONNECTED , \NLW_blk0000009b_BCOUT<13>_UNCONNECTED , \NLW_blk0000009b_BCOUT<12>_UNCONNECTED , 
\NLW_blk0000009b_BCOUT<11>_UNCONNECTED , \NLW_blk0000009b_BCOUT<10>_UNCONNECTED , \NLW_blk0000009b_BCOUT<9>_UNCONNECTED , 
\NLW_blk0000009b_BCOUT<8>_UNCONNECTED , \NLW_blk0000009b_BCOUT<7>_UNCONNECTED , \NLW_blk0000009b_BCOUT<6>_UNCONNECTED , 
\NLW_blk0000009b_BCOUT<5>_UNCONNECTED , \NLW_blk0000009b_BCOUT<4>_UNCONNECTED , \NLW_blk0000009b_BCOUT<3>_UNCONNECTED , 
\NLW_blk0000009b_BCOUT<2>_UNCONNECTED , \NLW_blk0000009b_BCOUT<1>_UNCONNECTED , \NLW_blk0000009b_BCOUT<0>_UNCONNECTED }),
    .PCIN({sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189}),
    .C({sig00000176, sig00000175, sig00000174, sig00000173, sig00000172, sig00000171, sig00000170, sig0000016f, sig0000016e, sig0000016d, sig0000016c
, sig0000016b, sig0000016a, sig00000169, sig00000168, sig00000167, sig00000166, sig00000165, sig00000164, sig00000163, sig00000162, sig00000161, 
sig00000160, sig0000015f, sig0000015e, sig0000015d, sig0000015c, sig0000015b, sig0000015a, sig00000159, sig00000158, sig00000157, sig00000156, 
sig00000155, sig00000154, sig00000153, sig00000001, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189}),
    .P({sine[23], sine[22], sine[21], sine[20], sine[19], sine[18], sine[17], sine[16], sine[15], sine[14], sine[13], sine[12], sine[11], sine[10], 
sine[9], sine[8], sine[7], sine[6], sine[5], sine[4], sine[3], sine[2], sine[1], sine[0], \NLW_blk0000009b_P<23>_UNCONNECTED , 
\NLW_blk0000009b_P<22>_UNCONNECTED , \NLW_blk0000009b_P<21>_UNCONNECTED , \NLW_blk0000009b_P<20>_UNCONNECTED , \NLW_blk0000009b_P<19>_UNCONNECTED , 
\NLW_blk0000009b_P<18>_UNCONNECTED , \NLW_blk0000009b_P<17>_UNCONNECTED , \NLW_blk0000009b_P<16>_UNCONNECTED , \NLW_blk0000009b_P<15>_UNCONNECTED , 
\NLW_blk0000009b_P<14>_UNCONNECTED , \NLW_blk0000009b_P<13>_UNCONNECTED , \NLW_blk0000009b_P<12>_UNCONNECTED , \NLW_blk0000009b_P<11>_UNCONNECTED , 
\NLW_blk0000009b_P<10>_UNCONNECTED , \NLW_blk0000009b_P<9>_UNCONNECTED , \NLW_blk0000009b_P<8>_UNCONNECTED , \NLW_blk0000009b_P<7>_UNCONNECTED , 
\NLW_blk0000009b_P<6>_UNCONNECTED , \NLW_blk0000009b_P<5>_UNCONNECTED , \NLW_blk0000009b_P<4>_UNCONNECTED , \NLW_blk0000009b_P<3>_UNCONNECTED , 
\NLW_blk0000009b_P<2>_UNCONNECTED , \NLW_blk0000009b_P<1>_UNCONNECTED , \NLW_blk0000009b_P<0>_UNCONNECTED }),
    .OPMODE({sig00000001, sig00000189, sig00000189, sig00000189, sig00000001, sig00000001, sig00000189, sig00000001}),
    .D({sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189
, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189}),
    .PCOUT({\NLW_blk0000009b_PCOUT<47>_UNCONNECTED , \NLW_blk0000009b_PCOUT<46>_UNCONNECTED , \NLW_blk0000009b_PCOUT<45>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<44>_UNCONNECTED , \NLW_blk0000009b_PCOUT<43>_UNCONNECTED , \NLW_blk0000009b_PCOUT<42>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<41>_UNCONNECTED , \NLW_blk0000009b_PCOUT<40>_UNCONNECTED , \NLW_blk0000009b_PCOUT<39>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<38>_UNCONNECTED , \NLW_blk0000009b_PCOUT<37>_UNCONNECTED , \NLW_blk0000009b_PCOUT<36>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<35>_UNCONNECTED , \NLW_blk0000009b_PCOUT<34>_UNCONNECTED , \NLW_blk0000009b_PCOUT<33>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<32>_UNCONNECTED , \NLW_blk0000009b_PCOUT<31>_UNCONNECTED , \NLW_blk0000009b_PCOUT<30>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<29>_UNCONNECTED , \NLW_blk0000009b_PCOUT<28>_UNCONNECTED , \NLW_blk0000009b_PCOUT<27>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<26>_UNCONNECTED , \NLW_blk0000009b_PCOUT<25>_UNCONNECTED , \NLW_blk0000009b_PCOUT<24>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<23>_UNCONNECTED , \NLW_blk0000009b_PCOUT<22>_UNCONNECTED , \NLW_blk0000009b_PCOUT<21>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<20>_UNCONNECTED , \NLW_blk0000009b_PCOUT<19>_UNCONNECTED , \NLW_blk0000009b_PCOUT<18>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<17>_UNCONNECTED , \NLW_blk0000009b_PCOUT<16>_UNCONNECTED , \NLW_blk0000009b_PCOUT<15>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<14>_UNCONNECTED , \NLW_blk0000009b_PCOUT<13>_UNCONNECTED , \NLW_blk0000009b_PCOUT<12>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<11>_UNCONNECTED , \NLW_blk0000009b_PCOUT<10>_UNCONNECTED , \NLW_blk0000009b_PCOUT<9>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<8>_UNCONNECTED , \NLW_blk0000009b_PCOUT<7>_UNCONNECTED , \NLW_blk0000009b_PCOUT<6>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<5>_UNCONNECTED , \NLW_blk0000009b_PCOUT<4>_UNCONNECTED , \NLW_blk0000009b_PCOUT<3>_UNCONNECTED , 
\NLW_blk0000009b_PCOUT<2>_UNCONNECTED , \NLW_blk0000009b_PCOUT<1>_UNCONNECTED , \NLW_blk0000009b_PCOUT<0>_UNCONNECTED }),
    .A({sig00000124, sig00000123, sig00000122, sig00000121, sig00000120, sig0000011f, sig0000011e, sig0000011d, sig0000011c, sig0000011b, sig0000011a
, sig00000119, sig00000118, sig00000117, sig00000116, sig00000115, sig00000114, sig00000113}),
    .M({\NLW_blk0000009b_M<35>_UNCONNECTED , \NLW_blk0000009b_M<34>_UNCONNECTED , \NLW_blk0000009b_M<33>_UNCONNECTED , 
\NLW_blk0000009b_M<32>_UNCONNECTED , \NLW_blk0000009b_M<31>_UNCONNECTED , \NLW_blk0000009b_M<30>_UNCONNECTED , \NLW_blk0000009b_M<29>_UNCONNECTED , 
\NLW_blk0000009b_M<28>_UNCONNECTED , \NLW_blk0000009b_M<27>_UNCONNECTED , \NLW_blk0000009b_M<26>_UNCONNECTED , \NLW_blk0000009b_M<25>_UNCONNECTED , 
\NLW_blk0000009b_M<24>_UNCONNECTED , \NLW_blk0000009b_M<23>_UNCONNECTED , \NLW_blk0000009b_M<22>_UNCONNECTED , \NLW_blk0000009b_M<21>_UNCONNECTED , 
\NLW_blk0000009b_M<20>_UNCONNECTED , \NLW_blk0000009b_M<19>_UNCONNECTED , \NLW_blk0000009b_M<18>_UNCONNECTED , \NLW_blk0000009b_M<17>_UNCONNECTED , 
\NLW_blk0000009b_M<16>_UNCONNECTED , \NLW_blk0000009b_M<15>_UNCONNECTED , \NLW_blk0000009b_M<14>_UNCONNECTED , \NLW_blk0000009b_M<13>_UNCONNECTED , 
\NLW_blk0000009b_M<12>_UNCONNECTED , \NLW_blk0000009b_M<11>_UNCONNECTED , \NLW_blk0000009b_M<10>_UNCONNECTED , \NLW_blk0000009b_M<9>_UNCONNECTED , 
\NLW_blk0000009b_M<8>_UNCONNECTED , \NLW_blk0000009b_M<7>_UNCONNECTED , \NLW_blk0000009b_M<6>_UNCONNECTED , \NLW_blk0000009b_M<5>_UNCONNECTED , 
\NLW_blk0000009b_M<4>_UNCONNECTED , \NLW_blk0000009b_M<3>_UNCONNECTED , \NLW_blk0000009b_M<2>_UNCONNECTED , \NLW_blk0000009b_M<1>_UNCONNECTED , 
\NLW_blk0000009b_M<0>_UNCONNECTED })
  );
  DSP48A1 #(
    .A0REG ( 0 ),
    .A1REG ( 1 ),
    .B0REG ( 0 ),
    .B1REG ( 1 ),
    .CARRYINREG ( 0 ),
    .CARRYINSEL ( "OPMODE5" ),
    .CREG ( 1 ),
    .DREG ( 1 ),
    .MREG ( 1 ),
    .OPMODEREG ( 1 ),
    .PREG ( 1 ),
    .RSTTYPE ( "SYNC" ),
    .CARRYOUTREG ( 0 ))
  blk0000009c (
    .CECARRYIN(sig00000189),
    .RSTC(sig00000189),
    .RSTCARRYIN(sig00000189),
    .CED(sig00000001),
    .RSTD(sig00000189),
    .CEOPMODE(sig00000001),
    .CEC(sig00000001),
    .CARRYOUTF(NLW_blk0000009c_CARRYOUTF_UNCONNECTED),
    .RSTOPMODE(sig00000189),
    .RSTM(sig00000189),
    .CLK(clk),
    .RSTB(sig00000189),
    .CEM(sig00000001),
    .CEB(sig00000001),
    .CARRYIN(sig00000189),
    .CEP(sig00000001),
    .CEA(sig00000001),
    .CARRYOUT(NLW_blk0000009c_CARRYOUT_UNCONNECTED),
    .RSTA(sig00000189),
    .RSTP(sig00000189),
    .B({sig00000188, sig00000187, sig00000186, sig00000185, sig00000184, sig00000183, sig00000182, sig00000181, sig00000180, sig0000017f, sig0000017e
, sig0000017d, sig0000017c, sig0000017b, sig0000017a, sig00000179, sig00000178, sig00000177}),
    .BCOUT({\NLW_blk0000009c_BCOUT<17>_UNCONNECTED , \NLW_blk0000009c_BCOUT<16>_UNCONNECTED , \NLW_blk0000009c_BCOUT<15>_UNCONNECTED , 
\NLW_blk0000009c_BCOUT<14>_UNCONNECTED , \NLW_blk0000009c_BCOUT<13>_UNCONNECTED , \NLW_blk0000009c_BCOUT<12>_UNCONNECTED , 
\NLW_blk0000009c_BCOUT<11>_UNCONNECTED , \NLW_blk0000009c_BCOUT<10>_UNCONNECTED , \NLW_blk0000009c_BCOUT<9>_UNCONNECTED , 
\NLW_blk0000009c_BCOUT<8>_UNCONNECTED , \NLW_blk0000009c_BCOUT<7>_UNCONNECTED , \NLW_blk0000009c_BCOUT<6>_UNCONNECTED , 
\NLW_blk0000009c_BCOUT<5>_UNCONNECTED , \NLW_blk0000009c_BCOUT<4>_UNCONNECTED , \NLW_blk0000009c_BCOUT<3>_UNCONNECTED , 
\NLW_blk0000009c_BCOUT<2>_UNCONNECTED , \NLW_blk0000009c_BCOUT<1>_UNCONNECTED , \NLW_blk0000009c_BCOUT<0>_UNCONNECTED }),
    .PCIN({sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189}),
    .C({sig000001a2, sig000001a2, sig000001a2, sig000001a2, sig000001a2, sig000001a2, sig000001a2, sig000001a1, sig000001a0, sig0000019f, sig0000019e
, sig0000019d, sig0000019c, sig0000019b, sig0000019a, sig00000199, sig00000198, sig00000197, sig00000196, sig00000195, sig00000194, sig00000193, 
sig00000192, sig00000191, sig00000190, sig0000018f, sig0000018e, sig0000018d, sig0000018c, sig0000018b, sig0000018a, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000001, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189}),
    .P({\NLW_blk0000009c_P<47>_UNCONNECTED , \NLW_blk0000009c_P<46>_UNCONNECTED , \NLW_blk0000009c_P<45>_UNCONNECTED , 
\NLW_blk0000009c_P<44>_UNCONNECTED , \NLW_blk0000009c_P<43>_UNCONNECTED , \NLW_blk0000009c_P<42>_UNCONNECTED , sig00000152, sig00000151, sig00000150, 
sig0000014f, sig0000014e, sig0000014d, sig0000014c, sig0000014b, sig0000014a, sig00000149, sig00000148, sig00000147, sig00000146, sig00000145, 
sig00000144, sig00000143, sig00000142, sig00000141, sig00000140, sig0000013f, sig0000013e, sig0000013d, sig0000013c, sig0000013b, sig0000013a, 
sig00000139, sig00000138, sig00000137, sig00000136, sig00000135, sig00000134, sig00000133, sig00000132, sig00000131, sig00000130, sig0000012f, 
\NLW_blk0000009c_P<5>_UNCONNECTED , \NLW_blk0000009c_P<4>_UNCONNECTED , \NLW_blk0000009c_P<3>_UNCONNECTED , \NLW_blk0000009c_P<2>_UNCONNECTED , 
\NLW_blk0000009c_P<1>_UNCONNECTED , \NLW_blk0000009c_P<0>_UNCONNECTED }),
    .OPMODE({sig00000001, sig00000189, sig00000189, sig00000189, sig00000001, sig00000001, sig00000189, sig00000001}),
    .D({sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189
, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189}),
    .PCOUT({\NLW_blk0000009c_PCOUT<47>_UNCONNECTED , \NLW_blk0000009c_PCOUT<46>_UNCONNECTED , \NLW_blk0000009c_PCOUT<45>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<44>_UNCONNECTED , \NLW_blk0000009c_PCOUT<43>_UNCONNECTED , \NLW_blk0000009c_PCOUT<42>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<41>_UNCONNECTED , \NLW_blk0000009c_PCOUT<40>_UNCONNECTED , \NLW_blk0000009c_PCOUT<39>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<38>_UNCONNECTED , \NLW_blk0000009c_PCOUT<37>_UNCONNECTED , \NLW_blk0000009c_PCOUT<36>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<35>_UNCONNECTED , \NLW_blk0000009c_PCOUT<34>_UNCONNECTED , \NLW_blk0000009c_PCOUT<33>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<32>_UNCONNECTED , \NLW_blk0000009c_PCOUT<31>_UNCONNECTED , \NLW_blk0000009c_PCOUT<30>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<29>_UNCONNECTED , \NLW_blk0000009c_PCOUT<28>_UNCONNECTED , \NLW_blk0000009c_PCOUT<27>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<26>_UNCONNECTED , \NLW_blk0000009c_PCOUT<25>_UNCONNECTED , \NLW_blk0000009c_PCOUT<24>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<23>_UNCONNECTED , \NLW_blk0000009c_PCOUT<22>_UNCONNECTED , \NLW_blk0000009c_PCOUT<21>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<20>_UNCONNECTED , \NLW_blk0000009c_PCOUT<19>_UNCONNECTED , \NLW_blk0000009c_PCOUT<18>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<17>_UNCONNECTED , \NLW_blk0000009c_PCOUT<16>_UNCONNECTED , \NLW_blk0000009c_PCOUT<15>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<14>_UNCONNECTED , \NLW_blk0000009c_PCOUT<13>_UNCONNECTED , \NLW_blk0000009c_PCOUT<12>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<11>_UNCONNECTED , \NLW_blk0000009c_PCOUT<10>_UNCONNECTED , \NLW_blk0000009c_PCOUT<9>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<8>_UNCONNECTED , \NLW_blk0000009c_PCOUT<7>_UNCONNECTED , \NLW_blk0000009c_PCOUT<6>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<5>_UNCONNECTED , \NLW_blk0000009c_PCOUT<4>_UNCONNECTED , \NLW_blk0000009c_PCOUT<3>_UNCONNECTED , 
\NLW_blk0000009c_PCOUT<2>_UNCONNECTED , \NLW_blk0000009c_PCOUT<1>_UNCONNECTED , \NLW_blk0000009c_PCOUT<0>_UNCONNECTED }),
    .A({sig00000052, sig00000051, sig00000050, sig0000004f, sig0000004e, sig0000004d, sig0000004c, sig0000004b, sig0000004a, sig00000049, sig00000048
, sig00000047, sig00000046, sig00000045, sig00000044, sig00000043, sig00000042, sig00000041}),
    .M({\NLW_blk0000009c_M<35>_UNCONNECTED , \NLW_blk0000009c_M<34>_UNCONNECTED , \NLW_blk0000009c_M<33>_UNCONNECTED , 
\NLW_blk0000009c_M<32>_UNCONNECTED , \NLW_blk0000009c_M<31>_UNCONNECTED , \NLW_blk0000009c_M<30>_UNCONNECTED , \NLW_blk0000009c_M<29>_UNCONNECTED , 
\NLW_blk0000009c_M<28>_UNCONNECTED , \NLW_blk0000009c_M<27>_UNCONNECTED , \NLW_blk0000009c_M<26>_UNCONNECTED , \NLW_blk0000009c_M<25>_UNCONNECTED , 
\NLW_blk0000009c_M<24>_UNCONNECTED , \NLW_blk0000009c_M<23>_UNCONNECTED , \NLW_blk0000009c_M<22>_UNCONNECTED , \NLW_blk0000009c_M<21>_UNCONNECTED , 
\NLW_blk0000009c_M<20>_UNCONNECTED , \NLW_blk0000009c_M<19>_UNCONNECTED , \NLW_blk0000009c_M<18>_UNCONNECTED , \NLW_blk0000009c_M<17>_UNCONNECTED , 
\NLW_blk0000009c_M<16>_UNCONNECTED , \NLW_blk0000009c_M<15>_UNCONNECTED , \NLW_blk0000009c_M<14>_UNCONNECTED , \NLW_blk0000009c_M<13>_UNCONNECTED , 
\NLW_blk0000009c_M<12>_UNCONNECTED , \NLW_blk0000009c_M<11>_UNCONNECTED , \NLW_blk0000009c_M<10>_UNCONNECTED , \NLW_blk0000009c_M<9>_UNCONNECTED , 
\NLW_blk0000009c_M<8>_UNCONNECTED , \NLW_blk0000009c_M<7>_UNCONNECTED , \NLW_blk0000009c_M<6>_UNCONNECTED , \NLW_blk0000009c_M<5>_UNCONNECTED , 
\NLW_blk0000009c_M<4>_UNCONNECTED , \NLW_blk0000009c_M<3>_UNCONNECTED , \NLW_blk0000009c_M<2>_UNCONNECTED , \NLW_blk0000009c_M<1>_UNCONNECTED , 
\NLW_blk0000009c_M<0>_UNCONNECTED })
  );
  DSP48A1 #(
    .A0REG ( 0 ),
    .A1REG ( 1 ),
    .B0REG ( 0 ),
    .B1REG ( 1 ),
    .CARRYINREG ( 0 ),
    .CARRYINSEL ( "OPMODE5" ),
    .CREG ( 1 ),
    .DREG ( 1 ),
    .MREG ( 1 ),
    .OPMODEREG ( 1 ),
    .PREG ( 1 ),
    .RSTTYPE ( "SYNC" ),
    .CARRYOUTREG ( 0 ))
  blk0000009d (
    .CECARRYIN(sig00000189),
    .RSTC(sig00000189),
    .RSTCARRYIN(sig00000189),
    .CED(sig00000001),
    .RSTD(sig00000189),
    .CEOPMODE(sig00000001),
    .CEC(sig00000001),
    .CARRYOUTF(NLW_blk0000009d_CARRYOUTF_UNCONNECTED),
    .RSTOPMODE(sig00000189),
    .RSTM(sig00000189),
    .CLK(clk),
    .RSTB(sig00000189),
    .CEM(sig00000001),
    .CEB(sig00000001),
    .CARRYIN(sig00000189),
    .CEP(sig00000001),
    .CEA(sig00000001),
    .CARRYOUT(NLW_blk0000009d_CARRYOUT_UNCONNECTED),
    .RSTA(sig00000189),
    .RSTP(sig00000189),
    .B({sig00000188, sig00000187, sig00000186, sig00000185, sig00000184, sig00000183, sig00000182, sig00000181, sig00000180, sig0000017f, sig0000017e
, sig0000017d, sig0000017c, sig0000017b, sig0000017a, sig00000179, sig00000178, sig00000177}),
    .BCOUT({\NLW_blk0000009d_BCOUT<17>_UNCONNECTED , \NLW_blk0000009d_BCOUT<16>_UNCONNECTED , \NLW_blk0000009d_BCOUT<15>_UNCONNECTED , 
\NLW_blk0000009d_BCOUT<14>_UNCONNECTED , \NLW_blk0000009d_BCOUT<13>_UNCONNECTED , \NLW_blk0000009d_BCOUT<12>_UNCONNECTED , 
\NLW_blk0000009d_BCOUT<11>_UNCONNECTED , \NLW_blk0000009d_BCOUT<10>_UNCONNECTED , \NLW_blk0000009d_BCOUT<9>_UNCONNECTED , 
\NLW_blk0000009d_BCOUT<8>_UNCONNECTED , \NLW_blk0000009d_BCOUT<7>_UNCONNECTED , \NLW_blk0000009d_BCOUT<6>_UNCONNECTED , 
\NLW_blk0000009d_BCOUT<5>_UNCONNECTED , \NLW_blk0000009d_BCOUT<4>_UNCONNECTED , \NLW_blk0000009d_BCOUT<3>_UNCONNECTED , 
\NLW_blk0000009d_BCOUT<2>_UNCONNECTED , \NLW_blk0000009d_BCOUT<1>_UNCONNECTED , \NLW_blk0000009d_BCOUT<0>_UNCONNECTED }),
    .PCIN({sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189}),
    .C({sig000001bb, sig000001bb, sig000001bb, sig000001bb, sig000001bb, sig000001bb, sig000001bb, sig000001ba, sig000001b9, sig000001b8, sig000001b7
, sig000001b6, sig000001b5, sig000001b4, sig000001b3, sig000001b2, sig000001b1, sig000001b0, sig000001af, sig000001ae, sig000001ad, sig000001ac, 
sig000001ab, sig000001aa, sig000001a9, sig000001a8, sig000001a7, sig000001a6, sig000001a5, sig000001a4, sig000001a3, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000001, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189}),
    .P({\NLW_blk0000009d_P<47>_UNCONNECTED , \NLW_blk0000009d_P<46>_UNCONNECTED , \NLW_blk0000009d_P<45>_UNCONNECTED , 
\NLW_blk0000009d_P<44>_UNCONNECTED , \NLW_blk0000009d_P<43>_UNCONNECTED , \NLW_blk0000009d_P<42>_UNCONNECTED , sig00000176, sig00000175, sig00000174, 
sig00000173, sig00000172, sig00000171, sig00000170, sig0000016f, sig0000016e, sig0000016d, sig0000016c, sig0000016b, sig0000016a, sig00000169, 
sig00000168, sig00000167, sig00000166, sig00000165, sig00000164, sig00000163, sig00000162, sig00000161, sig00000160, sig0000015f, sig0000015e, 
sig0000015d, sig0000015c, sig0000015b, sig0000015a, sig00000159, sig00000158, sig00000157, sig00000156, sig00000155, sig00000154, sig00000153, 
\NLW_blk0000009d_P<5>_UNCONNECTED , \NLW_blk0000009d_P<4>_UNCONNECTED , \NLW_blk0000009d_P<3>_UNCONNECTED , \NLW_blk0000009d_P<2>_UNCONNECTED , 
\NLW_blk0000009d_P<1>_UNCONNECTED , \NLW_blk0000009d_P<0>_UNCONNECTED }),
    .OPMODE({sig00000189, sig00000189, sig00000189, sig00000189, sig00000001, sig00000001, sig00000189, sig00000001}),
    .D({sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189
, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189}),
    .PCOUT({\NLW_blk0000009d_PCOUT<47>_UNCONNECTED , \NLW_blk0000009d_PCOUT<46>_UNCONNECTED , \NLW_blk0000009d_PCOUT<45>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<44>_UNCONNECTED , \NLW_blk0000009d_PCOUT<43>_UNCONNECTED , \NLW_blk0000009d_PCOUT<42>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<41>_UNCONNECTED , \NLW_blk0000009d_PCOUT<40>_UNCONNECTED , \NLW_blk0000009d_PCOUT<39>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<38>_UNCONNECTED , \NLW_blk0000009d_PCOUT<37>_UNCONNECTED , \NLW_blk0000009d_PCOUT<36>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<35>_UNCONNECTED , \NLW_blk0000009d_PCOUT<34>_UNCONNECTED , \NLW_blk0000009d_PCOUT<33>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<32>_UNCONNECTED , \NLW_blk0000009d_PCOUT<31>_UNCONNECTED , \NLW_blk0000009d_PCOUT<30>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<29>_UNCONNECTED , \NLW_blk0000009d_PCOUT<28>_UNCONNECTED , \NLW_blk0000009d_PCOUT<27>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<26>_UNCONNECTED , \NLW_blk0000009d_PCOUT<25>_UNCONNECTED , \NLW_blk0000009d_PCOUT<24>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<23>_UNCONNECTED , \NLW_blk0000009d_PCOUT<22>_UNCONNECTED , \NLW_blk0000009d_PCOUT<21>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<20>_UNCONNECTED , \NLW_blk0000009d_PCOUT<19>_UNCONNECTED , \NLW_blk0000009d_PCOUT<18>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<17>_UNCONNECTED , \NLW_blk0000009d_PCOUT<16>_UNCONNECTED , \NLW_blk0000009d_PCOUT<15>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<14>_UNCONNECTED , \NLW_blk0000009d_PCOUT<13>_UNCONNECTED , \NLW_blk0000009d_PCOUT<12>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<11>_UNCONNECTED , \NLW_blk0000009d_PCOUT<10>_UNCONNECTED , \NLW_blk0000009d_PCOUT<9>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<8>_UNCONNECTED , \NLW_blk0000009d_PCOUT<7>_UNCONNECTED , \NLW_blk0000009d_PCOUT<6>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<5>_UNCONNECTED , \NLW_blk0000009d_PCOUT<4>_UNCONNECTED , \NLW_blk0000009d_PCOUT<3>_UNCONNECTED , 
\NLW_blk0000009d_PCOUT<2>_UNCONNECTED , \NLW_blk0000009d_PCOUT<1>_UNCONNECTED , \NLW_blk0000009d_PCOUT<0>_UNCONNECTED }),
    .A({sig0000003a, sig00000039, sig00000038, sig00000037, sig00000036, sig00000035, sig00000034, sig00000033, sig00000032, sig00000031, sig00000030
, sig0000002f, sig0000002e, sig0000002d, sig0000002c, sig0000002b, sig0000002a, sig00000029}),
    .M({\NLW_blk0000009d_M<35>_UNCONNECTED , \NLW_blk0000009d_M<34>_UNCONNECTED , \NLW_blk0000009d_M<33>_UNCONNECTED , 
\NLW_blk0000009d_M<32>_UNCONNECTED , \NLW_blk0000009d_M<31>_UNCONNECTED , \NLW_blk0000009d_M<30>_UNCONNECTED , \NLW_blk0000009d_M<29>_UNCONNECTED , 
\NLW_blk0000009d_M<28>_UNCONNECTED , \NLW_blk0000009d_M<27>_UNCONNECTED , \NLW_blk0000009d_M<26>_UNCONNECTED , \NLW_blk0000009d_M<25>_UNCONNECTED , 
\NLW_blk0000009d_M<24>_UNCONNECTED , \NLW_blk0000009d_M<23>_UNCONNECTED , \NLW_blk0000009d_M<22>_UNCONNECTED , \NLW_blk0000009d_M<21>_UNCONNECTED , 
\NLW_blk0000009d_M<20>_UNCONNECTED , \NLW_blk0000009d_M<19>_UNCONNECTED , \NLW_blk0000009d_M<18>_UNCONNECTED , \NLW_blk0000009d_M<17>_UNCONNECTED , 
\NLW_blk0000009d_M<16>_UNCONNECTED , \NLW_blk0000009d_M<15>_UNCONNECTED , \NLW_blk0000009d_M<14>_UNCONNECTED , \NLW_blk0000009d_M<13>_UNCONNECTED , 
\NLW_blk0000009d_M<12>_UNCONNECTED , \NLW_blk0000009d_M<11>_UNCONNECTED , \NLW_blk0000009d_M<10>_UNCONNECTED , \NLW_blk0000009d_M<9>_UNCONNECTED , 
\NLW_blk0000009d_M<8>_UNCONNECTED , \NLW_blk0000009d_M<7>_UNCONNECTED , \NLW_blk0000009d_M<6>_UNCONNECTED , \NLW_blk0000009d_M<5>_UNCONNECTED , 
\NLW_blk0000009d_M<4>_UNCONNECTED , \NLW_blk0000009d_M<3>_UNCONNECTED , \NLW_blk0000009d_M<2>_UNCONNECTED , \NLW_blk0000009d_M<1>_UNCONNECTED , 
\NLW_blk0000009d_M<0>_UNCONNECTED })
  );
  DSP48A1 #(
    .A0REG ( 0 ),
    .A1REG ( 1 ),
    .B0REG ( 0 ),
    .B1REG ( 1 ),
    .CARRYINREG ( 0 ),
    .CARRYINSEL ( "OPMODE5" ),
    .CREG ( 1 ),
    .DREG ( 1 ),
    .MREG ( 1 ),
    .OPMODEREG ( 1 ),
    .PREG ( 1 ),
    .RSTTYPE ( "SYNC" ),
    .CARRYOUTREG ( 0 ))
  blk0000009e (
    .CECARRYIN(sig00000189),
    .RSTC(sig00000189),
    .RSTCARRYIN(sig00000189),
    .CED(sig00000001),
    .RSTD(sig00000189),
    .CEOPMODE(sig00000001),
    .CEC(sig00000001),
    .CARRYOUTF(NLW_blk0000009e_CARRYOUTF_UNCONNECTED),
    .RSTOPMODE(sig00000189),
    .RSTM(sig00000189),
    .CLK(clk),
    .RSTB(sig00000189),
    .CEM(sig00000001),
    .CEB(sig00000001),
    .CARRYIN(sig00000189),
    .CEP(sig00000001),
    .CEA(sig00000001),
    .CARRYOUT(NLW_blk0000009e_CARRYOUT_UNCONNECTED),
    .RSTA(sig00000189),
    .RSTP(sig00000189),
    .B({sig00000189, sig00000001, sig00000001, sig00000189, sig00000189, sig00000001, sig00000189, sig00000189, sig00000001, sig00000189, sig00000189
, sig00000189, sig00000189, sig00000001, sig00000001, sig00000001, sig00000001, sig00000001}),
    .BCOUT({\NLW_blk0000009e_BCOUT<17>_UNCONNECTED , \NLW_blk0000009e_BCOUT<16>_UNCONNECTED , \NLW_blk0000009e_BCOUT<15>_UNCONNECTED , 
\NLW_blk0000009e_BCOUT<14>_UNCONNECTED , \NLW_blk0000009e_BCOUT<13>_UNCONNECTED , \NLW_blk0000009e_BCOUT<12>_UNCONNECTED , 
\NLW_blk0000009e_BCOUT<11>_UNCONNECTED , \NLW_blk0000009e_BCOUT<10>_UNCONNECTED , \NLW_blk0000009e_BCOUT<9>_UNCONNECTED , 
\NLW_blk0000009e_BCOUT<8>_UNCONNECTED , \NLW_blk0000009e_BCOUT<7>_UNCONNECTED , \NLW_blk0000009e_BCOUT<6>_UNCONNECTED , 
\NLW_blk0000009e_BCOUT<5>_UNCONNECTED , \NLW_blk0000009e_BCOUT<4>_UNCONNECTED , \NLW_blk0000009e_BCOUT<3>_UNCONNECTED , 
\NLW_blk0000009e_BCOUT<2>_UNCONNECTED , \NLW_blk0000009e_BCOUT<1>_UNCONNECTED , \NLW_blk0000009e_BCOUT<0>_UNCONNECTED }),
    .PCIN({sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189}),
    .C({sig00000001, sig00000001, sig00000001, sig00000001, sig00000001, sig00000001, sig00000001, sig00000001, sig00000001, sig00000001, sig00000001
, sig00000001, sig00000001, sig00000001, sig00000001, sig00000189, sig00000189, sig00000001, sig00000001, sig00000189, sig00000001, sig00000001, 
sig00000189, sig00000001, sig00000001, sig00000001, sig00000001, sig00000189, sig00000189, sig00000189, sig00000189, sig00000001, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189}),
    .P({\NLW_blk0000009e_P<47>_UNCONNECTED , \NLW_blk0000009e_P<46>_UNCONNECTED , \NLW_blk0000009e_P<45>_UNCONNECTED , 
\NLW_blk0000009e_P<44>_UNCONNECTED , \NLW_blk0000009e_P<43>_UNCONNECTED , \NLW_blk0000009e_P<42>_UNCONNECTED , \NLW_blk0000009e_P<41>_UNCONNECTED , 
\NLW_blk0000009e_P<40>_UNCONNECTED , \NLW_blk0000009e_P<39>_UNCONNECTED , \NLW_blk0000009e_P<38>_UNCONNECTED , \NLW_blk0000009e_P<37>_UNCONNECTED , 
\NLW_blk0000009e_P<36>_UNCONNECTED , sig000001cd, sig000001cc, sig000001cb, sig000001ca, sig000001c9, sig000001c8, sig000001c7, sig000001c6, 
sig000001c5, sig000001c4, sig000001c3, sig000001c2, sig000001c1, sig000001c0, sig000001bf, sig000001be, sig000001bd, sig000001bc, 
\NLW_blk0000009e_P<17>_UNCONNECTED , \NLW_blk0000009e_P<16>_UNCONNECTED , \NLW_blk0000009e_P<15>_UNCONNECTED , \NLW_blk0000009e_P<14>_UNCONNECTED , 
\NLW_blk0000009e_P<13>_UNCONNECTED , \NLW_blk0000009e_P<12>_UNCONNECTED , \NLW_blk0000009e_P<11>_UNCONNECTED , \NLW_blk0000009e_P<10>_UNCONNECTED , 
\NLW_blk0000009e_P<9>_UNCONNECTED , \NLW_blk0000009e_P<8>_UNCONNECTED , \NLW_blk0000009e_P<7>_UNCONNECTED , \NLW_blk0000009e_P<6>_UNCONNECTED , 
\NLW_blk0000009e_P<5>_UNCONNECTED , \NLW_blk0000009e_P<4>_UNCONNECTED , \NLW_blk0000009e_P<3>_UNCONNECTED , \NLW_blk0000009e_P<2>_UNCONNECTED , 
\NLW_blk0000009e_P<1>_UNCONNECTED , \NLW_blk0000009e_P<0>_UNCONNECTED }),
    .OPMODE({sig00000189, sig00000189, sig00000189, sig00000189, sig00000001, sig00000001, sig00000189, sig00000001}),
    .D({sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189
, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189}),
    .PCOUT({\NLW_blk0000009e_PCOUT<47>_UNCONNECTED , \NLW_blk0000009e_PCOUT<46>_UNCONNECTED , \NLW_blk0000009e_PCOUT<45>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<44>_UNCONNECTED , \NLW_blk0000009e_PCOUT<43>_UNCONNECTED , \NLW_blk0000009e_PCOUT<42>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<41>_UNCONNECTED , \NLW_blk0000009e_PCOUT<40>_UNCONNECTED , \NLW_blk0000009e_PCOUT<39>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<38>_UNCONNECTED , \NLW_blk0000009e_PCOUT<37>_UNCONNECTED , \NLW_blk0000009e_PCOUT<36>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<35>_UNCONNECTED , \NLW_blk0000009e_PCOUT<34>_UNCONNECTED , \NLW_blk0000009e_PCOUT<33>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<32>_UNCONNECTED , \NLW_blk0000009e_PCOUT<31>_UNCONNECTED , \NLW_blk0000009e_PCOUT<30>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<29>_UNCONNECTED , \NLW_blk0000009e_PCOUT<28>_UNCONNECTED , \NLW_blk0000009e_PCOUT<27>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<26>_UNCONNECTED , \NLW_blk0000009e_PCOUT<25>_UNCONNECTED , \NLW_blk0000009e_PCOUT<24>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<23>_UNCONNECTED , \NLW_blk0000009e_PCOUT<22>_UNCONNECTED , \NLW_blk0000009e_PCOUT<21>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<20>_UNCONNECTED , \NLW_blk0000009e_PCOUT<19>_UNCONNECTED , \NLW_blk0000009e_PCOUT<18>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<17>_UNCONNECTED , \NLW_blk0000009e_PCOUT<16>_UNCONNECTED , \NLW_blk0000009e_PCOUT<15>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<14>_UNCONNECTED , \NLW_blk0000009e_PCOUT<13>_UNCONNECTED , \NLW_blk0000009e_PCOUT<12>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<11>_UNCONNECTED , \NLW_blk0000009e_PCOUT<10>_UNCONNECTED , \NLW_blk0000009e_PCOUT<9>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<8>_UNCONNECTED , \NLW_blk0000009e_PCOUT<7>_UNCONNECTED , \NLW_blk0000009e_PCOUT<6>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<5>_UNCONNECTED , \NLW_blk0000009e_PCOUT<4>_UNCONNECTED , \NLW_blk0000009e_PCOUT<3>_UNCONNECTED , 
\NLW_blk0000009e_PCOUT<2>_UNCONNECTED , \NLW_blk0000009e_PCOUT<1>_UNCONNECTED , \NLW_blk0000009e_PCOUT<0>_UNCONNECTED }),
    .A({sig00000189, sig00000067, sig00000066, sig00000065, sig00000064, sig00000063, sig00000062, sig00000061, sig00000060, sig0000005f, sig0000005e
, sig0000005d, sig0000005c, sig0000005b, sig0000005a, sig00000059, sig00000058, sig00000057}),
    .M({\NLW_blk0000009e_M<35>_UNCONNECTED , \NLW_blk0000009e_M<34>_UNCONNECTED , \NLW_blk0000009e_M<33>_UNCONNECTED , 
\NLW_blk0000009e_M<32>_UNCONNECTED , \NLW_blk0000009e_M<31>_UNCONNECTED , \NLW_blk0000009e_M<30>_UNCONNECTED , \NLW_blk0000009e_M<29>_UNCONNECTED , 
\NLW_blk0000009e_M<28>_UNCONNECTED , \NLW_blk0000009e_M<27>_UNCONNECTED , \NLW_blk0000009e_M<26>_UNCONNECTED , \NLW_blk0000009e_M<25>_UNCONNECTED , 
\NLW_blk0000009e_M<24>_UNCONNECTED , \NLW_blk0000009e_M<23>_UNCONNECTED , \NLW_blk0000009e_M<22>_UNCONNECTED , \NLW_blk0000009e_M<21>_UNCONNECTED , 
\NLW_blk0000009e_M<20>_UNCONNECTED , \NLW_blk0000009e_M<19>_UNCONNECTED , \NLW_blk0000009e_M<18>_UNCONNECTED , \NLW_blk0000009e_M<17>_UNCONNECTED , 
\NLW_blk0000009e_M<16>_UNCONNECTED , \NLW_blk0000009e_M<15>_UNCONNECTED , \NLW_blk0000009e_M<14>_UNCONNECTED , \NLW_blk0000009e_M<13>_UNCONNECTED , 
\NLW_blk0000009e_M<12>_UNCONNECTED , \NLW_blk0000009e_M<11>_UNCONNECTED , \NLW_blk0000009e_M<10>_UNCONNECTED , \NLW_blk0000009e_M<9>_UNCONNECTED , 
\NLW_blk0000009e_M<8>_UNCONNECTED , \NLW_blk0000009e_M<7>_UNCONNECTED , \NLW_blk0000009e_M<6>_UNCONNECTED , \NLW_blk0000009e_M<5>_UNCONNECTED , 
\NLW_blk0000009e_M<4>_UNCONNECTED , \NLW_blk0000009e_M<3>_UNCONNECTED , \NLW_blk0000009e_M<2>_UNCONNECTED , \NLW_blk0000009e_M<1>_UNCONNECTED , 
\NLW_blk0000009e_M<0>_UNCONNECTED })
  );
  FD   blk0000009f (
    .C(clk),
    .D(sig000000dd),
    .Q(sig000000cb)
  );
  FD   blk000000a0 (
    .C(clk),
    .D(sig000000de),
    .Q(sig000000cc)
  );
  FD   blk000000a1 (
    .C(clk),
    .D(sig000000df),
    .Q(sig000000cd)
  );
  FD   blk000000a2 (
    .C(clk),
    .D(sig000000e0),
    .Q(sig000000ce)
  );
  FD   blk000000a3 (
    .C(clk),
    .D(sig000000e1),
    .Q(sig000000cf)
  );
  FD   blk000000a4 (
    .C(clk),
    .D(sig000000e2),
    .Q(sig000000d0)
  );
  FD   blk000000a5 (
    .C(clk),
    .D(sig000000e3),
    .Q(sig000000d1)
  );
  FD   blk000000a6 (
    .C(clk),
    .D(sig000000e4),
    .Q(sig000000d2)
  );
  FD   blk000000a7 (
    .C(clk),
    .D(sig000000e5),
    .Q(sig000000d3)
  );
  FD   blk000000a8 (
    .C(clk),
    .D(sig000000e6),
    .Q(sig000000d4)
  );
  FD   blk000000a9 (
    .C(clk),
    .D(sig000000e7),
    .Q(sig000000d5)
  );
  FD   blk000000aa (
    .C(clk),
    .D(sig000000e8),
    .Q(sig000000d6)
  );
  FD   blk000000ab (
    .C(clk),
    .D(sig000000e9),
    .Q(sig000000d7)
  );
  FD   blk000000ac (
    .C(clk),
    .D(sig000000ea),
    .Q(sig000000d8)
  );
  FD   blk000000ad (
    .C(clk),
    .D(sig000000eb),
    .Q(sig000000d9)
  );
  FD   blk000000ae (
    .C(clk),
    .D(sig000000ec),
    .Q(sig000000da)
  );
  FD   blk000000af (
    .C(clk),
    .D(sig000000ed),
    .Q(sig000000db)
  );
  FD   blk000000b0 (
    .C(clk),
    .D(sig000000ee),
    .Q(sig000000dc)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000b1 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000000ef)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000b2 (
    .C(clk),
    .D(sig00000067),
    .Q(sig000000f0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000b3 (
    .C(clk),
    .D(sig00000066),
    .Q(sig000000f1)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000b4 (
    .C(clk),
    .D(sig00000065),
    .Q(sig000000f2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000b5 (
    .C(clk),
    .D(sig00000064),
    .Q(sig000000f3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000b6 (
    .C(clk),
    .D(sig00000063),
    .Q(sig000000f4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000b7 (
    .C(clk),
    .D(sig00000062),
    .Q(sig000000f5)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000b8 (
    .C(clk),
    .D(sig00000061),
    .Q(sig000000f6)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000b9 (
    .C(clk),
    .D(sig00000060),
    .Q(sig000000f7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000ba (
    .C(clk),
    .D(sig0000005f),
    .Q(sig000000f8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000bb (
    .C(clk),
    .D(sig0000005e),
    .Q(sig000000f9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000bc (
    .C(clk),
    .D(sig0000005d),
    .Q(sig000000fa)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000bd (
    .C(clk),
    .D(sig0000005c),
    .Q(sig000000fb)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000be (
    .C(clk),
    .D(sig0000005b),
    .Q(sig000000fc)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000bf (
    .C(clk),
    .D(sig0000005a),
    .Q(sig000000fd)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000c0 (
    .C(clk),
    .D(sig00000059),
    .Q(sig000000fe)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000c1 (
    .C(clk),
    .D(sig00000058),
    .Q(sig000000ff)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000c2 (
    .C(clk),
    .D(sig00000057),
    .Q(sig00000100)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000c3 (
    .C(clk),
    .D(sig000001a2),
    .Q(sig00000112)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000c4 (
    .C(clk),
    .D(sig000001a1),
    .Q(sig00000111)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000c5 (
    .C(clk),
    .D(sig000001a0),
    .Q(sig00000110)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000c6 (
    .C(clk),
    .D(sig0000019f),
    .Q(sig0000010f)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000c7 (
    .C(clk),
    .D(sig0000019e),
    .Q(sig0000010e)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000c8 (
    .C(clk),
    .D(sig0000019d),
    .Q(sig0000010d)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000c9 (
    .C(clk),
    .D(sig0000019c),
    .Q(sig0000010c)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000ca (
    .C(clk),
    .D(sig0000019b),
    .Q(sig0000010b)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000cb (
    .C(clk),
    .D(sig0000019a),
    .Q(sig0000010a)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000cc (
    .C(clk),
    .D(sig00000199),
    .Q(sig00000109)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000cd (
    .C(clk),
    .D(sig00000198),
    .Q(sig00000108)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000ce (
    .C(clk),
    .D(sig00000197),
    .Q(sig00000107)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000cf (
    .C(clk),
    .D(sig00000196),
    .Q(sig00000106)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000d0 (
    .C(clk),
    .D(sig00000195),
    .Q(sig00000105)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000d1 (
    .C(clk),
    .D(sig00000194),
    .Q(sig00000104)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000d2 (
    .C(clk),
    .D(sig00000193),
    .Q(sig00000103)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000d3 (
    .C(clk),
    .D(sig00000192),
    .Q(sig00000102)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000d4 (
    .C(clk),
    .D(sig00000191),
    .Q(sig00000101)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000d5 (
    .C(clk),
    .D(sig00000190),
    .Q(sig000001eb)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000d6 (
    .C(clk),
    .D(sig0000018f),
    .Q(sig000001ea)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000d7 (
    .C(clk),
    .D(sig0000018e),
    .Q(sig000001e9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000d8 (
    .C(clk),
    .D(sig0000018d),
    .Q(sig000001e8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000d9 (
    .C(clk),
    .D(sig0000018c),
    .Q(sig000001e7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000da (
    .C(clk),
    .D(sig0000018b),
    .Q(sig000001e6)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000db (
    .C(clk),
    .D(sig0000018a),
    .Q(sig000001e5)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000dc (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001e4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000dd (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001e3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000de (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001e2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000df (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001e1)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000e0 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001e0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000e1 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001df)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000e2 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001de)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000e3 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001dd)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000e4 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001dc)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000e5 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001db)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000e6 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001da)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000e7 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001d9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000e8 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001d8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000e9 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001d7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000ea (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001d6)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000eb (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001d5)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000ec (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001d4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000ed (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001d3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000ee (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001d2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000ef (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001d1)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f0 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001d0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f1 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001cf)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f2 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001ce)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f3 (
    .C(clk),
    .D(sig000001bb),
    .Q(sig00000124)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f4 (
    .C(clk),
    .D(sig000001ba),
    .Q(sig00000123)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f5 (
    .C(clk),
    .D(sig000001b9),
    .Q(sig00000122)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f6 (
    .C(clk),
    .D(sig000001b8),
    .Q(sig00000121)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f7 (
    .C(clk),
    .D(sig000001b7),
    .Q(sig00000120)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f8 (
    .C(clk),
    .D(sig000001b6),
    .Q(sig0000011f)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f9 (
    .C(clk),
    .D(sig000001b5),
    .Q(sig0000011e)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000fa (
    .C(clk),
    .D(sig000001b4),
    .Q(sig0000011d)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000fb (
    .C(clk),
    .D(sig000001b3),
    .Q(sig0000011c)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000fc (
    .C(clk),
    .D(sig000001b2),
    .Q(sig0000011b)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000fd (
    .C(clk),
    .D(sig000001b1),
    .Q(sig0000011a)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000fe (
    .C(clk),
    .D(sig000001b0),
    .Q(sig00000119)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000ff (
    .C(clk),
    .D(sig000001af),
    .Q(sig00000118)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000100 (
    .C(clk),
    .D(sig000001ae),
    .Q(sig00000117)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000101 (
    .C(clk),
    .D(sig000001ad),
    .Q(sig00000116)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000102 (
    .C(clk),
    .D(sig000001ac),
    .Q(sig00000115)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000103 (
    .C(clk),
    .D(sig000001ab),
    .Q(sig00000114)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000104 (
    .C(clk),
    .D(sig000001aa),
    .Q(sig00000113)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000105 (
    .C(clk),
    .D(sig000001a9),
    .Q(sig00000209)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000106 (
    .C(clk),
    .D(sig000001a8),
    .Q(sig00000208)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000107 (
    .C(clk),
    .D(sig000001a7),
    .Q(sig00000207)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000108 (
    .C(clk),
    .D(sig000001a6),
    .Q(sig00000206)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000109 (
    .C(clk),
    .D(sig000001a5),
    .Q(sig00000205)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000010a (
    .C(clk),
    .D(sig000001a4),
    .Q(sig00000204)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000010b (
    .C(clk),
    .D(sig000001a3),
    .Q(sig00000203)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000010c (
    .C(clk),
    .D(sig00000189),
    .Q(sig00000202)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000010d (
    .C(clk),
    .D(sig00000189),
    .Q(sig00000201)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000010e (
    .C(clk),
    .D(sig00000189),
    .Q(sig00000200)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000010f (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001ff)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000110 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001fe)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000111 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001fd)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000112 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001fc)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000113 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001fb)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000114 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001fa)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000115 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001f9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000116 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001f8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000117 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001f7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000118 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001f6)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000119 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001f5)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000011a (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001f4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000011b (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001f3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000011c (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001f2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000011d (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001f1)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000011e (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001f0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000011f (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001ef)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000120 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001ee)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000121 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001ed)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000122 (
    .C(clk),
    .D(sig00000189),
    .Q(sig000001ec)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000123 (
    .C(clk),
    .D(sig0000003a),
    .Q(sig000001a2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000124 (
    .C(clk),
    .D(sig00000039),
    .Q(sig000001a1)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000125 (
    .C(clk),
    .D(sig00000038),
    .Q(sig000001a0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000126 (
    .C(clk),
    .D(sig00000037),
    .Q(sig0000019f)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000127 (
    .C(clk),
    .D(sig00000036),
    .Q(sig0000019e)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000128 (
    .C(clk),
    .D(sig00000035),
    .Q(sig0000019d)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000129 (
    .C(clk),
    .D(sig00000034),
    .Q(sig0000019c)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000012a (
    .C(clk),
    .D(sig00000033),
    .Q(sig0000019b)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000012b (
    .C(clk),
    .D(sig00000032),
    .Q(sig0000019a)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000012c (
    .C(clk),
    .D(sig00000031),
    .Q(sig00000199)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000012d (
    .C(clk),
    .D(sig00000030),
    .Q(sig00000198)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000012e (
    .C(clk),
    .D(sig0000002f),
    .Q(sig00000197)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000012f (
    .C(clk),
    .D(sig0000002e),
    .Q(sig00000196)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000130 (
    .C(clk),
    .D(sig0000002d),
    .Q(sig00000195)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000131 (
    .C(clk),
    .D(sig0000002c),
    .Q(sig00000194)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000132 (
    .C(clk),
    .D(sig0000002b),
    .Q(sig00000193)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000133 (
    .C(clk),
    .D(sig0000002a),
    .Q(sig00000192)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000134 (
    .C(clk),
    .D(sig00000029),
    .Q(sig00000191)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000135 (
    .C(clk),
    .D(sig00000028),
    .Q(sig00000190)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000136 (
    .C(clk),
    .D(sig00000027),
    .Q(sig0000018f)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000137 (
    .C(clk),
    .D(sig00000026),
    .Q(sig0000018e)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000138 (
    .C(clk),
    .D(sig00000025),
    .Q(sig0000018d)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000139 (
    .C(clk),
    .D(sig00000024),
    .Q(sig0000018c)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000013a (
    .C(clk),
    .D(sig00000023),
    .Q(sig0000018b)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000013b (
    .C(clk),
    .D(sig00000001),
    .Q(sig0000018a)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000013c (
    .C(clk),
    .D(sig00000052),
    .Q(sig000001bb)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000013d (
    .C(clk),
    .D(sig00000051),
    .Q(sig000001ba)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000013e (
    .C(clk),
    .D(sig00000050),
    .Q(sig000001b9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000013f (
    .C(clk),
    .D(sig0000004f),
    .Q(sig000001b8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000140 (
    .C(clk),
    .D(sig0000004e),
    .Q(sig000001b7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000141 (
    .C(clk),
    .D(sig0000004d),
    .Q(sig000001b6)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000142 (
    .C(clk),
    .D(sig0000004c),
    .Q(sig000001b5)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000143 (
    .C(clk),
    .D(sig0000004b),
    .Q(sig000001b4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000144 (
    .C(clk),
    .D(sig0000004a),
    .Q(sig000001b3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000145 (
    .C(clk),
    .D(sig00000049),
    .Q(sig000001b2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000146 (
    .C(clk),
    .D(sig00000048),
    .Q(sig000001b1)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000147 (
    .C(clk),
    .D(sig00000047),
    .Q(sig000001b0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000148 (
    .C(clk),
    .D(sig00000046),
    .Q(sig000001af)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000149 (
    .C(clk),
    .D(sig00000045),
    .Q(sig000001ae)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000014a (
    .C(clk),
    .D(sig00000044),
    .Q(sig000001ad)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000014b (
    .C(clk),
    .D(sig00000043),
    .Q(sig000001ac)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000014c (
    .C(clk),
    .D(sig00000042),
    .Q(sig000001ab)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000014d (
    .C(clk),
    .D(sig00000041),
    .Q(sig000001aa)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000014e (
    .C(clk),
    .D(sig00000040),
    .Q(sig000001a9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000014f (
    .C(clk),
    .D(sig0000003f),
    .Q(sig000001a8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000150 (
    .C(clk),
    .D(sig0000003e),
    .Q(sig000001a7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000151 (
    .C(clk),
    .D(sig0000003d),
    .Q(sig000001a6)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000152 (
    .C(clk),
    .D(sig0000003c),
    .Q(sig000001a5)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000153 (
    .C(clk),
    .D(sig0000003b),
    .Q(sig000001a4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000154 (
    .C(clk),
    .D(sig00000001),
    .Q(sig000001a3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000155 (
    .C(clk),
    .D(sig000001cd),
    .Q(sig00000188)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000156 (
    .C(clk),
    .D(sig000001cc),
    .Q(sig00000187)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000157 (
    .C(clk),
    .D(sig000001cb),
    .Q(sig00000186)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000158 (
    .C(clk),
    .D(sig000001ca),
    .Q(sig00000185)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000159 (
    .C(clk),
    .D(sig000001c9),
    .Q(sig00000184)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000015a (
    .C(clk),
    .D(sig000001c8),
    .Q(sig00000183)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000015b (
    .C(clk),
    .D(sig000001c7),
    .Q(sig00000182)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000015c (
    .C(clk),
    .D(sig000001c6),
    .Q(sig00000181)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000015d (
    .C(clk),
    .D(sig000001c5),
    .Q(sig00000180)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000015e (
    .C(clk),
    .D(sig000001c4),
    .Q(sig0000017f)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000015f (
    .C(clk),
    .D(sig000001c3),
    .Q(sig0000017e)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000160 (
    .C(clk),
    .D(sig000001c2),
    .Q(sig0000017d)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000161 (
    .C(clk),
    .D(sig000001c1),
    .Q(sig0000017c)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000162 (
    .C(clk),
    .D(sig000001c0),
    .Q(sig0000017b)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000163 (
    .C(clk),
    .D(sig000001bf),
    .Q(sig0000017a)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000164 (
    .C(clk),
    .D(sig000001be),
    .Q(sig00000179)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000165 (
    .C(clk),
    .D(sig000001bd),
    .Q(sig00000178)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000166 (
    .C(clk),
    .D(sig000001bc),
    .Q(sig00000177)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk00000167 (
    .I0(sig00000068),
    .I1(sig00000071),
    .O(sig0000007e)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000168 (
    .I0(sig00000068),
    .I1(sig00000071),
    .O(sig00000075)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk00000169 (
    .I0(sig0000006a),
    .I1(sig00000071),
    .O(sig00000080)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000016a (
    .I0(sig0000006a),
    .I1(sig00000071),
    .O(sig00000077)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk0000016b (
    .I0(sig0000006b),
    .I1(sig00000071),
    .O(sig00000081)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000016c (
    .I0(sig0000006b),
    .I1(sig00000071),
    .O(sig00000078)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk0000016d (
    .I0(sig00000069),
    .I1(sig00000071),
    .O(sig0000007f)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000016e (
    .I0(sig00000069),
    .I1(sig00000071),
    .O(sig00000076)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk0000016f (
    .I0(sig0000006d),
    .I1(sig00000071),
    .O(sig00000083)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000170 (
    .I0(sig0000006d),
    .I1(sig00000071),
    .O(sig0000007a)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk00000171 (
    .I0(sig0000006e),
    .I1(sig00000071),
    .O(sig00000084)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000172 (
    .I0(sig0000006e),
    .I1(sig00000071),
    .O(sig0000007b)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk00000173 (
    .I0(sig0000006c),
    .I1(sig00000071),
    .O(sig00000082)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000174 (
    .I0(sig0000006c),
    .I1(sig00000071),
    .O(sig00000079)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk00000175 (
    .I0(sig00000070),
    .I1(sig00000071),
    .O(sig00000086)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000176 (
    .I0(sig00000070),
    .I1(sig00000071),
    .O(sig0000007d)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk00000177 (
    .I0(sig0000006f),
    .I1(sig00000071),
    .O(sig00000085)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000178 (
    .I0(sig0000006f),
    .I1(sig00000071),
    .O(sig0000007c)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000179 (
    .I0(sig00000072),
    .I1(sig00000071),
    .O(sig00000074)
  );
  RAMB16BWER #(
    .INITP_00 ( 256'h03EA540FA950FEA503FA540FA950FE9503EA503EA543FA543FA940FA940FA940 ),
    .INITP_01 ( 256'hA5403FAA5403FA9540FEA5503FA9503FA9503FA9503FA9503FA950FEA540FA95 ),
    .INITP_02 ( 256'hA555000FFFAAA554003FFAA955003FEAA55003FEA95500FFAA5500FEA95403FA ),
    .INITP_03 ( 256'hFFFFFFFFFFFFFFFFFFFFEAAAAAAAA555555400000FFFFEAAAA55550000FFFEAA ),
    .INITP_04 ( 256'hFC15ABF056AF015AFC05ABF056AF016AFC15AFC15ABC05ABC056BF056BF056BF ),
    .INITP_05 ( 256'h5ABFC055ABFC056ABF015AAFC056AFC056AFC056AFC056AFC056AF015ABF056A ),
    .INITP_06 ( 256'h5AAAFFF000555AABFFC00556AAFFC0155AAFFC0156AAFF0055AAFF0156ABFC05 ),
    .INITP_07 ( 256'h00000000000000000000155555555AAAAAABFFFFF000015555AAAAFFFF000155 ),
    .INIT_00 ( 256'h15A4B1384CC8E85483DE1F64BAE9566BF1EA8D6828E5C4605FDAFB5396CC3244 ),
    .INIT_01 ( 256'h59CCF5B9919E2D7CC952652300ED9CB1386ED4266FD90B87A72F42D3DE727A0D ),
    .INIT_02 ( 256'h965632D9CF516BBE0820A47840C5DD0979431573B1994DB7E9CC85D821DCBDD8 ),
    .INIT_03 ( 256'hC76964C102099F423C6DD98A76981399B08C4D71EA4A871523D4C0875D2DF9C7 ),
    .INIT_04 ( 256'hE934879D25F2C435626500849E903C8BDA75784D1614B3CB5171EF078C8D2A03 ),
    .INIT_05 ( 256'hF7EF97A53743D6CC763E159BB4E25413F3309237312AD0086ED20D88AC2A4AB9 ),
    .INIT_06 ( 256'hEFDD911B323FD3497439150FB5CC5670F6FB976D37C7D80978331845B83F5823 ),
    .INIT_07 ( 256'hCD5070511334B5FA58A2FB2D9D9B3FECE22084392635C81569DA0B83AD114E85 ),
    .INIT_08 ( 256'h8CAB31A8D6847B3F1FD8C45168AA0CE2B0FA54F2F8CA9C83401DE39886F42A31 ),
    .INIT_09 ( 256'h2A60D192789F1F87C64B6CEB1366B9BE5FF20603ABF051BBF7629CE8424BE78B ),
    .INIT_0A ( 256'hA2FB4C98F60D9F5A487FF17C9A524300EB8893E83C22E4368C2433EBDB8D8309 ),
    .INIT_0B ( 256'hF31B9F594B6BF751A30D4E9DFA03A53F504FFB36A5F35086FAF0A5304F47F936 ),
    .INIT_0C ( 256'h1779C68B756E2423D2A981012F2BDD278AF63897E60B9352406DED5B9A1C46B2 ),
    .INIT_0D ( 256'h0CEABF0270E8229CD41F85713692E782984148D0F92EA95C595B0929B8C96839 ),
    .INIT_0E ( 256'hD05E85AC3AC6EFAAA45B58D70D1FC133751328C1DC3A8F814295F576A8245AA0 ),
    .INIT_0F ( 256'h5EE61798D01388564062F837AFD5673D1E6ED5688C2C42BBF913AF3665231ADB ),
    .INIT_10 ( 256'hB5B271F52DFDE9CBA55F60B91BDAD6C1916F4BE40620C02479EE3380ECDAA5FC ),
    .INIT_11 ( 256'hD215921251D11154D09A8FA44E720D04CB5A8974475304F7C25F7F8C3C7EF935 ),
    .INIT_12 ( 256'hB18675643903FC62BF8382654508076DC9938B7B4D260E92CFC190B2516511DC ),
    .INIT_13 ( 256'h51A21986E129A88A6FAB368AFD29C38689A34F80151CDA789F946470290CED69 ),
    .INIT_14 ( 256'hB02B7C3948031389DECCA9CD748A3F04093BD3309CE266522F7FF86BC114897C ),
    .INIT_15 ( 256'hCB0F9B666B773B430AC9DA0BA90777BF46321460E24AAFEF7D504A6D1745E3DA ),
    .INIT_16 ( 256'hA063752049961DC5F1ADC54E98A86BBB3E88110FE34FB54886FC586A2991FA73 ),
    .INIT_17 ( 256'h2E6807A6E09CB94991AD69C9419C1927F06AC7649E1774824AA4207FF613CB5F ),
    .INIT_18 ( 256'h738A51612EEF0C32E92BC5DAA23F7E5B5A2D35B510F3EBE9C694A0F77B1054E1 ),
    .INIT_19 ( 256'h6E6350E833231512F6B5D80EB91B99DD7A545A803A6119F8F944D845B6FC9568 ),
    .INIT_1A ( 256'h1DBA0500EBFAD2A7B9079F1C84E46A604F903474190CFD58E158C50CA8758B91 ),
    .INIT_1B ( 256'h80856C9B586343DE2F0C19ED0480EEC6D8C0C26CABCB94DE7DA3661C4E483627 ),
    .INIT_1C ( 256'h95EA86DC777F67D557DD47963702262014F00373F1A7DF8ECD28BA73A7719422 ),
    .INIT_1D ( 256'h5D3D5314489D3DD632C2275F1BAD0FAD035FF6C2E9D7DC9ECF16C140B31CA4AA ),
    .INIT_1E ( 256'hD604D0C7CB3AC55FBF35B8BCB1F4AADDA3789BC493C28B7082D079E170A46718 ),
    .INIT_1F ( 256'hFFF4FFA5FF07FE1AFCDFFB54F97AF751F4DAF213EEFEEB9AE7E6E3E4DF93DAF3 ),
    .INIT_20 ( 256'hEA5C4EC8B33817AC7C22E09C4517A9950E167298D71B3BA0A02604AD6934CDBC ),
    .INIT_21 ( 256'hA6340A476E62D28436AE9ADDFF13634FC7922BDA9027F47958D1BD2D218E85F3 ),
    .INIT_22 ( 256'h69AACD2730AF9442F7E05B88BF3B22F786BDEA8D4E67B24916347A28DE244228 ),
    .INIT_23 ( 256'h38979B3FFDF760BEC39326768968EC674F74B28F15B678EBDC2C3F79A2D30639 ),
    .INIT_24 ( 256'h16CC7863DA0E3BCB9D9BFF7C6170C375258B87B3E9EC4C35AE8F10F97373D5FD ),
    .INIT_25 ( 256'h0811685BC8BD293489C2EA654B1EABED0CD06DC9CED62FF8912EF27853D6B547 ),
    .INIT_26 ( 256'h10236EE5CDC12CB78BC7EAF14A34A99009056893C83927F787CDE7BB47C1A7DD ),
    .INIT_27 ( 256'h32B08FAFECCC4A06A75E04D36265C0141DE07BC7D9CB37EB9626F47D52EFB17B ),
    .INIT_28 ( 256'h7355CE58297C84C1E0283BAF9756F31E4F06AB0E0736637DBFE31C68790CD5CF ),
    .INIT_29 ( 256'hD5A02E6E8761E07939B59315EC9A4642A00EF9FD5410AE45089E6318BDB51875 ),
    .INIT_2A ( 256'h5D05B36809F360A6B7810E8465AEBD0014786C18C3DE1BCA73DCCC1524737CF7 ),
    .INIT_2B ( 256'h0CE560A7B49508AF5CF3B16305FD5AC1AFB104CA5A0DAF7A05105AD0B0B906CA ),
    .INIT_2C ( 256'hE88739758A92DBDD2D577EFFD0D522D9750AC76919F56CAEBF9312A565E4B94E ),
    .INIT_2D ( 256'hF31640FE8F18DD642BE17A8FC96E187E67BFB73006D256A4A6A5F6D7473797C7 ),
    .INIT_2E ( 256'h2FA27A54C53A10565BA5A729F2E13ECD8AEDD73F23C6707FBD6B0A8A57DCA560 ),
    .INIT_2F ( 256'hA11AE8682FED77AABF9E07C9502B98C3E1922A9873D4BD4506ED50CA9ADDE525 ),
    .INIT_30 ( 256'h4A4E8E0BD20316355AA19F47E426293F6E91B41CF9E03FDC8612CC8013265A04 ),
    .INIT_31 ( 256'h2DEB6DEEAE2FEEAC2F66705CB18EF2FC34A6768CB8ADFB093DA18074C38206CB ),
    .INIT_32 ( 256'h4E7A8A9CC6FD039E407D7D9BBAF8F893366D7485B2DAF16E303F6F4EAE9BEE24 ),
    .INIT_33 ( 256'hAE5EE67A1ED757769055C97602D73C7A765DB080EAE42588606C9B90D6F41297 ),
    .INIT_34 ( 256'h4FD583C7B7FDEC77213456338B76C0FCF6C52CD0631E99AED08107953EEC7684 ),
    .INIT_35 ( 256'h34F1649A9489C4BDF53725F556F98841B9CEEBA01DB6501182B0B593E8BB1C26 ),
    .INIT_36 ( 256'h5F9D8AE0B66AE23B0E533AB267589445C178EEF11CB14AB87904A796D66F058D ),
    .INIT_37 ( 256'hD198F85A1F6446B76E539637BE64E6D90F96389C61E98B7EB55CDF8109ED34A1 ),
    .INIT_38 ( 256'h8C76AE9FD111F3CE16D53A265DC181A5A5D3CA4BEF0D1417396C5F0984F0AB1F ),
    .INIT_39 ( 256'h919DAF18CCDDEAEE094B27F246E5662385ACA580C59FE60806BC27BB49046A98 ),
    .INIT_3A ( 256'hE246FB0014062D5946F960E47B1C95A0B070CB8CE6F402A81EA83AF4578B746F ),
    .INIT_3B ( 256'h7F7B9365A79DBC22D0F4E613FB80113A27403D9454356B22825D99E4B1B8C9D9 ),
    .INIT_3C ( 256'h6A1679248881982BA823B86AC8FED9E0EB10FC8D0E59207232D8458D588F6BDE ),
    .INIT_3D ( 256'hA2C3ACECB763C22ACD3ED8A1E453F053FCA1093E1629236230EA3EC04CE45B56 ),
    .INIT_3E ( 256'h29FC2F3934C63AA140CB47444E0C55235C88643C6C3E74907D30861F8F5C98E8 ),
    .INIT_3F ( 256'h000C005B00F901E6032104AC068608AF0B260DED11021466181A1C1C206D250D ),
    .INIT_A ( 36'h000000000 ),
    .INIT_B ( 36'h000000000 ),
    .WRITE_MODE_A ( "WRITE_FIRST" ),
    .WRITE_MODE_B ( "WRITE_FIRST" ),
    .DATA_WIDTH_A ( 18 ),
    .DATA_WIDTH_B ( 18 ),
    .DOA_REG ( 0 ),
    .DOB_REG ( 0 ),
    .EN_RSTRAM_A ( "TRUE" ),
    .EN_RSTRAM_B ( "TRUE" ),
    .RST_PRIORITY_A ( "CE" ),
    .RST_PRIORITY_B ( "CE" ),
    .RSTTYPE ( "SYNC" ),
    .SRVAL_A ( 36'h000000000 ),
    .SRVAL_B ( 36'h000000000 ),
    .SIM_COLLISION_CHECK ( "ALL" ),
    .SIM_DEVICE ( "SPARTAN6" ),
    .INIT_FILE ( "NONE" ))
  blk0000017a (
    .REGCEA(sig00000189),
    .CLKA(clk),
    .ENB(sig00000001),
    .RSTB(sig00000189),
    .CLKB(clk),
    .REGCEB(sig00000189),
    .RSTA(sig00000189),
    .ENA(sig00000001),
    .DIPA({\NLW_blk0000017a_DIPA<3>_UNCONNECTED , \NLW_blk0000017a_DIPA<2>_UNCONNECTED , sig00000189, sig00000189}),
    .WEA({sig00000189, sig00000189, sig00000189, sig00000189}),
    .DOA({\NLW_blk0000017a_DOA<31>_UNCONNECTED , \NLW_blk0000017a_DOA<30>_UNCONNECTED , \NLW_blk0000017a_DOA<29>_UNCONNECTED , 
\NLW_blk0000017a_DOA<28>_UNCONNECTED , \NLW_blk0000017a_DOA<27>_UNCONNECTED , \NLW_blk0000017a_DOA<26>_UNCONNECTED , 
\NLW_blk0000017a_DOA<25>_UNCONNECTED , \NLW_blk0000017a_DOA<24>_UNCONNECTED , \NLW_blk0000017a_DOA<23>_UNCONNECTED , 
\NLW_blk0000017a_DOA<22>_UNCONNECTED , \NLW_blk0000017a_DOA<21>_UNCONNECTED , \NLW_blk0000017a_DOA<20>_UNCONNECTED , 
\NLW_blk0000017a_DOA<19>_UNCONNECTED , \NLW_blk0000017a_DOA<18>_UNCONNECTED , \NLW_blk0000017a_DOA<17>_UNCONNECTED , 
\NLW_blk0000017a_DOA<16>_UNCONNECTED , sig00000096, sig00000095, sig00000094, sig00000093, sig00000092, sig00000091, sig00000090, sig0000008f, 
sig0000008e, sig0000008d, sig0000008c, sig0000008b, sig0000008a, sig00000089, sig00000088, sig00000087}),
    .ADDRA({sig000000ca, sig000000c9, sig000000c8, sig000000c7, sig000000c6, sig000000c5, sig000000c4, sig000000c3, sig000000c2, sig000000c1, 
\NLW_blk0000017a_ADDRA<3>_UNCONNECTED , \NLW_blk0000017a_ADDRA<2>_UNCONNECTED , \NLW_blk0000017a_ADDRA<1>_UNCONNECTED , 
\NLW_blk0000017a_ADDRA<0>_UNCONNECTED }),
    .ADDRB({sig000000c0, sig000000bf, sig000000be, sig000000bd, sig000000bc, sig000000bb, sig000000ba, sig000000b9, sig000000b8, sig000000b7, 
\NLW_blk0000017a_ADDRB<3>_UNCONNECTED , \NLW_blk0000017a_ADDRB<2>_UNCONNECTED , \NLW_blk0000017a_ADDRB<1>_UNCONNECTED , 
\NLW_blk0000017a_ADDRB<0>_UNCONNECTED }),
    .DIB({\NLW_blk0000017a_DIB<31>_UNCONNECTED , \NLW_blk0000017a_DIB<30>_UNCONNECTED , \NLW_blk0000017a_DIB<29>_UNCONNECTED , 
\NLW_blk0000017a_DIB<28>_UNCONNECTED , \NLW_blk0000017a_DIB<27>_UNCONNECTED , \NLW_blk0000017a_DIB<26>_UNCONNECTED , 
\NLW_blk0000017a_DIB<25>_UNCONNECTED , \NLW_blk0000017a_DIB<24>_UNCONNECTED , \NLW_blk0000017a_DIB<23>_UNCONNECTED , 
\NLW_blk0000017a_DIB<22>_UNCONNECTED , \NLW_blk0000017a_DIB<21>_UNCONNECTED , \NLW_blk0000017a_DIB<20>_UNCONNECTED , 
\NLW_blk0000017a_DIB<19>_UNCONNECTED , \NLW_blk0000017a_DIB<18>_UNCONNECTED , \NLW_blk0000017a_DIB<17>_UNCONNECTED , 
\NLW_blk0000017a_DIB<16>_UNCONNECTED , \NLW_blk0000017a_DIB<15>_UNCONNECTED , \NLW_blk0000017a_DIB<14>_UNCONNECTED , 
\NLW_blk0000017a_DIB<13>_UNCONNECTED , \NLW_blk0000017a_DIB<12>_UNCONNECTED , \NLW_blk0000017a_DIB<11>_UNCONNECTED , 
\NLW_blk0000017a_DIB<10>_UNCONNECTED , \NLW_blk0000017a_DIB<9>_UNCONNECTED , \NLW_blk0000017a_DIB<8>_UNCONNECTED , 
\NLW_blk0000017a_DIB<7>_UNCONNECTED , \NLW_blk0000017a_DIB<6>_UNCONNECTED , \NLW_blk0000017a_DIB<5>_UNCONNECTED , \NLW_blk0000017a_DIB<4>_UNCONNECTED 
, \NLW_blk0000017a_DIB<3>_UNCONNECTED , \NLW_blk0000017a_DIB<2>_UNCONNECTED , \NLW_blk0000017a_DIB<1>_UNCONNECTED , 
\NLW_blk0000017a_DIB<0>_UNCONNECTED }),
    .DOPA({\NLW_blk0000017a_DOPA<3>_UNCONNECTED , \NLW_blk0000017a_DOPA<2>_UNCONNECTED , sig00000098, sig00000097}),
    .DIPB({\NLW_blk0000017a_DIPB<3>_UNCONNECTED , \NLW_blk0000017a_DIPB<2>_UNCONNECTED , \NLW_blk0000017a_DIPB<1>_UNCONNECTED , 
\NLW_blk0000017a_DIPB<0>_UNCONNECTED }),
    .DOPB({\NLW_blk0000017a_DOPB<3>_UNCONNECTED , \NLW_blk0000017a_DOPB<2>_UNCONNECTED , sig000000b0, sig000000af}),
    .DOB({\NLW_blk0000017a_DOB<31>_UNCONNECTED , \NLW_blk0000017a_DOB<30>_UNCONNECTED , \NLW_blk0000017a_DOB<29>_UNCONNECTED , 
\NLW_blk0000017a_DOB<28>_UNCONNECTED , \NLW_blk0000017a_DOB<27>_UNCONNECTED , \NLW_blk0000017a_DOB<26>_UNCONNECTED , 
\NLW_blk0000017a_DOB<25>_UNCONNECTED , \NLW_blk0000017a_DOB<24>_UNCONNECTED , \NLW_blk0000017a_DOB<23>_UNCONNECTED , 
\NLW_blk0000017a_DOB<22>_UNCONNECTED , \NLW_blk0000017a_DOB<21>_UNCONNECTED , \NLW_blk0000017a_DOB<20>_UNCONNECTED , 
\NLW_blk0000017a_DOB<19>_UNCONNECTED , \NLW_blk0000017a_DOB<18>_UNCONNECTED , \NLW_blk0000017a_DOB<17>_UNCONNECTED , 
\NLW_blk0000017a_DOB<16>_UNCONNECTED , sig000000ae, sig000000ad, sig000000ac, sig000000ab, sig000000aa, sig000000a9, sig000000a8, sig000000a7, 
sig000000a6, sig000000a5, sig000000a4, sig000000a3, sig000000a2, sig000000a1, sig000000a0, sig0000009f}),
    .WEB({sig00000189, sig00000189, sig00000189, sig00000189}),
    .DIA({\NLW_blk0000017a_DIA<31>_UNCONNECTED , \NLW_blk0000017a_DIA<30>_UNCONNECTED , \NLW_blk0000017a_DIA<29>_UNCONNECTED , 
\NLW_blk0000017a_DIA<28>_UNCONNECTED , \NLW_blk0000017a_DIA<27>_UNCONNECTED , \NLW_blk0000017a_DIA<26>_UNCONNECTED , 
\NLW_blk0000017a_DIA<25>_UNCONNECTED , \NLW_blk0000017a_DIA<24>_UNCONNECTED , \NLW_blk0000017a_DIA<23>_UNCONNECTED , 
\NLW_blk0000017a_DIA<22>_UNCONNECTED , \NLW_blk0000017a_DIA<21>_UNCONNECTED , \NLW_blk0000017a_DIA<20>_UNCONNECTED , 
\NLW_blk0000017a_DIA<19>_UNCONNECTED , \NLW_blk0000017a_DIA<18>_UNCONNECTED , \NLW_blk0000017a_DIA<17>_UNCONNECTED , 
\NLW_blk0000017a_DIA<16>_UNCONNECTED , sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189})
  );
  RAMB8BWER #(
    .INIT_00 ( 256'h0302020202020202020202020101010101010101010100000000000000000000 ),
    .INIT_01 ( 256'h0606060505050505050505050504040404040404040404030303030303030303 ),
    .INIT_02 ( 256'h0909090808080808080808080808070707070707070707070606060606060606 ),
    .INIT_03 ( 256'h0C0C0C0B0B0B0B0B0B0B0B0B0B0B0A0A0A0A0A0A0A0A0A0A0909090909090909 ),
    .INIT_04 ( 256'h0F0E0E0E0E0E0E0E0E0E0E0E0D0D0D0D0D0D0D0D0D0D0D0D0C0C0C0C0C0C0C0C ),
    .INIT_05 ( 256'h1111111111111111111010101010101010101010100F0F0F0F0F0F0F0F0F0F0F ),
    .INIT_06 ( 256'h1414141413131313131313131313131313121212121212121212121212111111 ),
    .INIT_07 ( 256'h1616161616161616161515151515151515151515151515141414141414141414 ),
    .INIT_08 ( 256'h1818181818181818181818181717171717171717171717171717171616161616 ),
    .INIT_09 ( 256'h1A1A1A1A1A1A1A1A1A1A1A191919191919191919191919191919191918181818 ),
    .INIT_0A ( 256'h1C1C1C1C1C1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1A1A1A1A1A1A1A ),
    .INIT_0B ( 256'h1D1D1D1D1D1D1D1D1D1D1D1D1D1D1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C1C ),
    .INIT_0C ( 256'h1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1D1D1D1D1D1D1D1D1D1D1D1D ),
    .INIT_0D ( 256'h1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1E1E1E1E1E1E1E1E1E1E1E1E1E1E ),
    .INIT_0E ( 256'h1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F ),
    .INIT_0F ( 256'h1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F ),
    .INIT_10 ( 256'h3C3D3D3D3D3D3D3D3D3D3D3D3E3E3E3E3E3E3E3E3E3E3F3F3F3F3F3F3F3F3F3F ),
    .INIT_11 ( 256'h3939393A3A3A3A3A3A3A3A3A3A3B3B3B3B3B3B3B3B3B3B3C3C3C3C3C3C3C3C3C ),
    .INIT_12 ( 256'h3636363737373737373737373737383838383838383838383939393939393939 ),
    .INIT_13 ( 256'h3333333434343434343434343434353535353535353535353636363636363636 ),
    .INIT_14 ( 256'h3031313131313131313131313232323232323232323232323333333333333333 ),
    .INIT_15 ( 256'h2E2E2E2E2E2E2E2E2E2F2F2F2F2F2F2F2F2F2F2F2F3030303030303030303030 ),
    .INIT_16 ( 256'h2B2B2B2B2C2C2C2C2C2C2C2C2C2C2C2C2C2D2D2D2D2D2D2D2D2D2D2D2D2E2E2E ),
    .INIT_17 ( 256'h2929292929292929292A2A2A2A2A2A2A2A2A2A2A2A2A2A2B2B2B2B2B2B2B2B2B ),
    .INIT_18 ( 256'h2727272727272727272727272828282828282828282828282828282929292929 ),
    .INIT_19 ( 256'h2525252525252525252525262626262626262626262626262626262627272727 ),
    .INIT_1A ( 256'h2323232323242424242424242424242424242424242424242425252525252525 ),
    .INIT_1B ( 256'h2222222222222222222222222222232323232323232323232323232323232323 ),
    .INIT_1C ( 256'h2121212121212121212121212121212121212121222222222222222222222222 ),
    .INIT_1D ( 256'h2020202020202020202020202020202020202121212121212121212121212121 ),
    .INIT_1E ( 256'h2020202020202020202020202020202020202020202020202020202020202020 ),
    .INIT_1F ( 256'h2020202020202020202020202020202020202020202020202020202020202020 ),
    .INIT_A ( 18'h00000 ),
    .WRITE_MODE_A ( "WRITE_FIRST" ),
    .WRITE_MODE_B ( "WRITE_FIRST" ),
    .DATA_WIDTH_A ( 9 ),
    .DATA_WIDTH_B ( 9 ),
    .DOA_REG ( 0 ),
    .DOB_REG ( 0 ),
    .EN_RSTRAM_A ( "TRUE" ),
    .EN_RSTRAM_B ( "TRUE" ),
    .INITP_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_B ( 18'h00000 ),
    .RAM_MODE ( "TDP" ),
    .RST_PRIORITY_A ( "CE" ),
    .RST_PRIORITY_B ( "CE" ),
    .RSTTYPE ( "SYNC" ),
    .SRVAL_A ( 18'h00000 ),
    .SRVAL_B ( 18'h00000 ),
    .INIT_FILE ( "NONE" ),
    .SIM_COLLISION_CHECK ( "ALL" ))
  blk0000017b (
    .RSTBRST(sig00000189),
    .ENBRDEN(sig00000001),
    .REGCEA(sig00000189),
    .ENAWREN(sig00000001),
    .CLKAWRCLK(clk),
    .CLKBRDCLK(clk),
    .REGCEBREGCE(sig00000189),
    .RSTA(sig00000189),
    .WEAWEL({sig00000189, sig00000189}),
    .DOADO({\NLW_blk0000017b_DOADO<15>_UNCONNECTED , \NLW_blk0000017b_DOADO<14>_UNCONNECTED , \NLW_blk0000017b_DOADO<13>_UNCONNECTED , 
\NLW_blk0000017b_DOADO<12>_UNCONNECTED , \NLW_blk0000017b_DOADO<11>_UNCONNECTED , \NLW_blk0000017b_DOADO<10>_UNCONNECTED , 
\NLW_blk0000017b_DOADO<9>_UNCONNECTED , \NLW_blk0000017b_DOADO<8>_UNCONNECTED , \NLW_blk0000017b_DOADO<7>_UNCONNECTED , 
\NLW_blk0000017b_DOADO<6>_UNCONNECTED , sig0000009e, sig0000009d, sig0000009c, sig0000009b, sig0000009a, sig00000099}),
    .DOPADOP({\NLW_blk0000017b_DOPADOP<1>_UNCONNECTED , \NLW_blk0000017b_DOPADOP<0>_UNCONNECTED }),
    .DOPBDOP({\NLW_blk0000017b_DOPBDOP<1>_UNCONNECTED , \NLW_blk0000017b_DOPBDOP<0>_UNCONNECTED }),
    .WEBWEU({sig00000189, sig00000189}),
    .ADDRAWRADDR({sig000000ca, sig000000c9, sig000000c8, sig000000c7, sig000000c6, sig000000c5, sig000000c4, sig000000c3, sig000000c2, sig000000c1, 
\NLW_blk0000017b_ADDRAWRADDR<2>_UNCONNECTED , \NLW_blk0000017b_ADDRAWRADDR<1>_UNCONNECTED , \NLW_blk0000017b_ADDRAWRADDR<0>_UNCONNECTED }),
    .DIPBDIP({\NLW_blk0000017b_DIPBDIP<1>_UNCONNECTED , \NLW_blk0000017b_DIPBDIP<0>_UNCONNECTED }),
    .DIBDI({\NLW_blk0000017b_DIBDI<15>_UNCONNECTED , \NLW_blk0000017b_DIBDI<14>_UNCONNECTED , \NLW_blk0000017b_DIBDI<13>_UNCONNECTED , 
\NLW_blk0000017b_DIBDI<12>_UNCONNECTED , \NLW_blk0000017b_DIBDI<11>_UNCONNECTED , \NLW_blk0000017b_DIBDI<10>_UNCONNECTED , 
\NLW_blk0000017b_DIBDI<9>_UNCONNECTED , \NLW_blk0000017b_DIBDI<8>_UNCONNECTED , \NLW_blk0000017b_DIBDI<7>_UNCONNECTED , 
\NLW_blk0000017b_DIBDI<6>_UNCONNECTED , \NLW_blk0000017b_DIBDI<5>_UNCONNECTED , \NLW_blk0000017b_DIBDI<4>_UNCONNECTED , 
\NLW_blk0000017b_DIBDI<3>_UNCONNECTED , \NLW_blk0000017b_DIBDI<2>_UNCONNECTED , \NLW_blk0000017b_DIBDI<1>_UNCONNECTED , 
\NLW_blk0000017b_DIBDI<0>_UNCONNECTED }),
    .DIADI({\NLW_blk0000017b_DIADI<15>_UNCONNECTED , \NLW_blk0000017b_DIADI<14>_UNCONNECTED , \NLW_blk0000017b_DIADI<13>_UNCONNECTED , 
\NLW_blk0000017b_DIADI<12>_UNCONNECTED , \NLW_blk0000017b_DIADI<11>_UNCONNECTED , \NLW_blk0000017b_DIADI<10>_UNCONNECTED , 
\NLW_blk0000017b_DIADI<9>_UNCONNECTED , \NLW_blk0000017b_DIADI<8>_UNCONNECTED , sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189}),
    .ADDRBRDADDR({sig000000c0, sig000000bf, sig000000be, sig000000bd, sig000000bc, sig000000bb, sig000000ba, sig000000b9, sig000000b8, sig000000b7, 
\NLW_blk0000017b_ADDRBRDADDR<2>_UNCONNECTED , \NLW_blk0000017b_ADDRBRDADDR<1>_UNCONNECTED , \NLW_blk0000017b_ADDRBRDADDR<0>_UNCONNECTED }),
    .DOBDO({\NLW_blk0000017b_DOBDO<15>_UNCONNECTED , \NLW_blk0000017b_DOBDO<14>_UNCONNECTED , \NLW_blk0000017b_DOBDO<13>_UNCONNECTED , 
\NLW_blk0000017b_DOBDO<12>_UNCONNECTED , \NLW_blk0000017b_DOBDO<11>_UNCONNECTED , \NLW_blk0000017b_DOBDO<10>_UNCONNECTED , 
\NLW_blk0000017b_DOBDO<9>_UNCONNECTED , \NLW_blk0000017b_DOBDO<8>_UNCONNECTED , \NLW_blk0000017b_DOBDO<7>_UNCONNECTED , 
\NLW_blk0000017b_DOBDO<6>_UNCONNECTED , sig000000b6, sig000000b5, sig000000b4, sig000000b3, sig000000b2, sig000000b1}),
    .DIPADIP({\NLW_blk0000017b_DIPADIP<1>_UNCONNECTED , sig00000189})
  );
  RAMB16BWER #(
    .INITP_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_04 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_05 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_06 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_07 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_00 ( 256'h04A604AB04B004B504BA04BE04C304C804CD04D204D704DC04E104E504EA04EF ),
    .INIT_01 ( 256'h045B046004640469046E04720477047C04800485048A048F04930498049D04A2 ),
    .INIT_02 ( 256'h04120417041B042004240429042D04320436043B043F04440448044D04520456 ),
    .INIT_03 ( 256'h03CC03D003D403D903DD03E103E603EA03EE03F303F703FC040004050409040E ),
    .INIT_04 ( 256'h0388038C039003940398039D03A103A503A903AD03B203B603BA03BF03C303C7 ),
    .INIT_05 ( 256'h0346034A034E03520356035A035E03620366036B036F03730377037B037F0383 ),
    .INIT_06 ( 256'h0307030B030F03130316031A031E03220326032A032E03320336033A033E0342 ),
    .INIT_07 ( 256'h02CA02CE02D202D502D902DD02E102E502E802EC02F002F402F802FB02FF0303 ),
    .INIT_08 ( 256'h029002940297029B029E02A202A602A902AD02B102B402B802BC02BF02C302C7 ),
    .INIT_09 ( 256'h0259025C025F02630266026A026D027102740278027B027F028202860289028D ),
    .INIT_0A ( 256'h02230227022A022D023002340237023A023E024102440248024B024E02520255 ),
    .INIT_0B ( 256'h01F101F401F701FA01FD020002030206020A020D021002130216021A021D0220 ),
    .INIT_0C ( 256'h01C001C301C601C901CC01CF01D201D501D801DB01DE01E101E401E701EA01ED ),
    .INIT_0D ( 256'h019201950198019B019E01A101A301A601A901AC01AF01B201B501B801BA01BD ),
    .INIT_0E ( 256'h0167016A016C016F017201740177017A017D017F018201850187018A018D0190 ),
    .INIT_0F ( 256'h013E0141014301460148014B014D0150015201550158015A015D015F01620165 ),
    .INIT_10 ( 256'h0118011A011D011F0121012401260128012B012D01300132013401370139013C ),
    .INIT_11 ( 256'h00F400F600F800FB00FD00FF0101010301060108010A010C010F011101130116 ),
    .INIT_12 ( 256'h00D300D500D700D900DB00DD00DF00E100E300E500E700E900EB00EE00F000F2 ),
    .INIT_13 ( 256'h00B400B500B700B900BB00BD00BF00C100C300C500C700C900CB00CD00CE00D0 ),
    .INIT_14 ( 256'h00970099009A009C009E00A000A100A300A500A700A900AA00AC00AE00B000B2 ),
    .INIT_15 ( 256'h007D007E008000820083008500860088008A008B008D008F0090009200940095 ),
    .INIT_16 ( 256'h006500670068006A006B006C006E006F007100720074007500770078007A007B ),
    .INIT_17 ( 256'h00500051005300540055005700580059005A005C005D005E0060006100630064 ),
    .INIT_18 ( 256'h003E003F004000410042004300440045004700480049004A004B004D004E004F ),
    .INIT_19 ( 256'h002D002E002F0030003100320033003400350036003700380039003A003B003C ),
    .INIT_1A ( 256'h002000200021002200230024002400250026002700280029002A002B002B002C ),
    .INIT_1B ( 256'h00140015001600160017001800180019001A001A001B001C001D001D001E001F ),
    .INIT_1C ( 256'h000C000C000D000D000E000E000F000F00100010001100110012001300130014 ),
    .INIT_1D ( 256'h000500060006000600070007000700080008000900090009000A000A000B000B ),
    .INIT_1E ( 256'h0001000200020002000200020003000300030003000400040004000400050005 ),
    .INIT_1F ( 256'h0000000000000000000000000000000000000000000100010001000100010001 ),
    .INIT_20 ( 256'h0001000100010001000100000000000000000000000000000000000000000000 ),
    .INIT_21 ( 256'h0005000400040004000400030003000300030002000200020002000200010001 ),
    .INIT_22 ( 256'h000B000A000A0009000900090008000800070007000700060006000600050005 ),
    .INIT_23 ( 256'h0013001300120011001100100010000F000F000E000E000D000D000C000C000B ),
    .INIT_24 ( 256'h001E001D001D001C001B001A001A001900180018001700160016001500140014 ),
    .INIT_25 ( 256'h002B002B002A002900280027002600250024002400230022002100200020001F ),
    .INIT_26 ( 256'h003B003A0039003800370036003500340033003200310030002F002E002D002C ),
    .INIT_27 ( 256'h004E004D004B004A004900480047004500440043004200410040003F003E003C ),
    .INIT_28 ( 256'h006300610060005E005D005C005A00590058005700550054005300510050004F ),
    .INIT_29 ( 256'h007A007800770075007400720071006F006E006C006B006A0068006700650064 ),
    .INIT_2A ( 256'h009400920090008F008D008B008A008800860085008300820080007E007D007B ),
    .INIT_2B ( 256'h00B000AE00AC00AA00A900A700A500A300A100A0009E009C009A009900970095 ),
    .INIT_2C ( 256'h00CE00CD00CB00C900C700C500C300C100BF00BD00BB00B900B700B500B400B2 ),
    .INIT_2D ( 256'h00F000EE00EB00E900E700E500E300E100DF00DD00DB00D900D700D500D300D0 ),
    .INIT_2E ( 256'h01130111010F010C010A010801060103010100FF00FD00FB00F800F600F400F2 ),
    .INIT_2F ( 256'h01390137013401320130012D012B0128012601240121011F011D011A01180116 ),
    .INIT_30 ( 256'h0162015F015D015A0158015501520150014D014B0148014601430141013E013C ),
    .INIT_31 ( 256'h018D018A018701850182017F017D017A017701740172016F016C016A01670165 ),
    .INIT_32 ( 256'h01BA01B801B501B201AF01AC01A901A601A301A1019E019B0198019501920190 ),
    .INIT_33 ( 256'h01EA01E701E401E101DE01DB01D801D501D201CF01CC01C901C601C301C001BD ),
    .INIT_34 ( 256'h021D021A021602130210020D020A02060203020001FD01FA01F701F401F101ED ),
    .INIT_35 ( 256'h0252024E024B024802440241023E023A023702340230022D022A022702230220 ),
    .INIT_36 ( 256'h028902860282027F027B027802740271026D026A02660263025F025C02590255 ),
    .INIT_37 ( 256'h02C302BF02BC02B802B402B102AD02A902A602A2029E029B029702940290028D ),
    .INIT_38 ( 256'h02FF02FB02F802F402F002EC02E802E502E102DD02D902D502D202CE02CA02C7 ),
    .INIT_39 ( 256'h033E033A03360332032E032A03260322031E031A03160313030F030B03070303 ),
    .INIT_3A ( 256'h037F037B03770373036F036B03660362035E035A03560352034E034A03460342 ),
    .INIT_3B ( 256'h03C303BF03BA03B603B203AD03A903A503A1039D039803940390038C03880383 ),
    .INIT_3C ( 256'h04090405040003FC03F703F303EE03EA03E603E103DD03D903D403D003CC03C7 ),
    .INIT_3D ( 256'h0452044D04480444043F043B04360432042D042904240420041B04170412040E ),
    .INIT_3E ( 256'h049D04980493048F048A04850480047C04770472046E046904640460045B0456 ),
    .INIT_3F ( 256'h04EA04E504E104DC04D704D204CD04C804C304BE04BA04B504B004AB04A604A2 ),
    .WRITE_MODE_A ( "WRITE_FIRST" ),
    .DATA_WIDTH_A ( 18 ),
    .DATA_WIDTH_B ( 0 ),
    .DOA_REG ( 0 ),
    .DOB_REG ( 0 ),
    .EN_RSTRAM_A ( "TRUE" ),
    .EN_RSTRAM_B ( "TRUE" ),
    .INIT_A ( 36'h000000000 ),
    .INIT_B ( 36'h000000000 ),
    .RST_PRIORITY_A ( "CE" ),
    .RST_PRIORITY_B ( "CE" ),
    .RSTTYPE ( "SYNC" ),
    .SRVAL_A ( 36'h000000000 ),
    .SRVAL_B ( 36'h000000000 ),
    .WRITE_MODE_B ( "WRITE_FIRST" ),
    .SIM_COLLISION_CHECK ( "ALL" ),
    .SIM_DEVICE ( "SPARTAN6" ),
    .INIT_FILE ( "NONE" ))
  blk0000017c (
    .REGCEA(sig00000189),
    .CLKA(clk),
    .ENB(NLW_blk0000017c_ENB_UNCONNECTED),
    .RSTB(NLW_blk0000017c_RSTB_UNCONNECTED),
    .CLKB(NLW_blk0000017c_CLKB_UNCONNECTED),
    .REGCEB(NLW_blk0000017c_REGCEB_UNCONNECTED),
    .RSTA(sig00000189),
    .ENA(sig00000001),
    .DIPA({\NLW_blk0000017c_DIPA<3>_UNCONNECTED , \NLW_blk0000017c_DIPA<2>_UNCONNECTED , sig00000189, sig00000189}),
    .WEA({sig00000189, sig00000189, sig00000189, sig00000189}),
    .DOA({\NLW_blk0000017c_DOA<31>_UNCONNECTED , \NLW_blk0000017c_DOA<30>_UNCONNECTED , \NLW_blk0000017c_DOA<29>_UNCONNECTED , 
\NLW_blk0000017c_DOA<28>_UNCONNECTED , \NLW_blk0000017c_DOA<27>_UNCONNECTED , \NLW_blk0000017c_DOA<26>_UNCONNECTED , 
\NLW_blk0000017c_DOA<25>_UNCONNECTED , \NLW_blk0000017c_DOA<24>_UNCONNECTED , \NLW_blk0000017c_DOA<23>_UNCONNECTED , 
\NLW_blk0000017c_DOA<22>_UNCONNECTED , \NLW_blk0000017c_DOA<21>_UNCONNECTED , \NLW_blk0000017c_DOA<20>_UNCONNECTED , 
\NLW_blk0000017c_DOA<19>_UNCONNECTED , \NLW_blk0000017c_DOA<18>_UNCONNECTED , \NLW_blk0000017c_DOA<17>_UNCONNECTED , 
\NLW_blk0000017c_DOA<16>_UNCONNECTED , sig000000df, sig000000e0, sig000000e1, sig000000e2, sig000000e3, sig000000e4, sig000000e5, sig000000e6, 
sig000000e7, sig000000e8, sig000000e9, sig000000ea, sig000000eb, sig000000ec, sig000000ed, sig000000ee}),
    .ADDRA({sig0000012e, sig0000012d, sig0000012c, sig0000012b, sig0000012a, sig00000129, sig00000128, sig00000127, sig00000126, sig00000125, 
\NLW_blk0000017c_ADDRA<3>_UNCONNECTED , \NLW_blk0000017c_ADDRA<2>_UNCONNECTED , \NLW_blk0000017c_ADDRA<1>_UNCONNECTED , 
\NLW_blk0000017c_ADDRA<0>_UNCONNECTED }),
    .ADDRB({\NLW_blk0000017c_ADDRB<13>_UNCONNECTED , \NLW_blk0000017c_ADDRB<12>_UNCONNECTED , \NLW_blk0000017c_ADDRB<11>_UNCONNECTED , 
\NLW_blk0000017c_ADDRB<10>_UNCONNECTED , \NLW_blk0000017c_ADDRB<9>_UNCONNECTED , \NLW_blk0000017c_ADDRB<8>_UNCONNECTED , 
\NLW_blk0000017c_ADDRB<7>_UNCONNECTED , \NLW_blk0000017c_ADDRB<6>_UNCONNECTED , \NLW_blk0000017c_ADDRB<5>_UNCONNECTED , 
\NLW_blk0000017c_ADDRB<4>_UNCONNECTED , \NLW_blk0000017c_ADDRB<3>_UNCONNECTED , \NLW_blk0000017c_ADDRB<2>_UNCONNECTED , 
\NLW_blk0000017c_ADDRB<1>_UNCONNECTED , \NLW_blk0000017c_ADDRB<0>_UNCONNECTED }),
    .DIB({\NLW_blk0000017c_DIB<31>_UNCONNECTED , \NLW_blk0000017c_DIB<30>_UNCONNECTED , \NLW_blk0000017c_DIB<29>_UNCONNECTED , 
\NLW_blk0000017c_DIB<28>_UNCONNECTED , \NLW_blk0000017c_DIB<27>_UNCONNECTED , \NLW_blk0000017c_DIB<26>_UNCONNECTED , 
\NLW_blk0000017c_DIB<25>_UNCONNECTED , \NLW_blk0000017c_DIB<24>_UNCONNECTED , \NLW_blk0000017c_DIB<23>_UNCONNECTED , 
\NLW_blk0000017c_DIB<22>_UNCONNECTED , \NLW_blk0000017c_DIB<21>_UNCONNECTED , \NLW_blk0000017c_DIB<20>_UNCONNECTED , 
\NLW_blk0000017c_DIB<19>_UNCONNECTED , \NLW_blk0000017c_DIB<18>_UNCONNECTED , \NLW_blk0000017c_DIB<17>_UNCONNECTED , 
\NLW_blk0000017c_DIB<16>_UNCONNECTED , \NLW_blk0000017c_DIB<15>_UNCONNECTED , \NLW_blk0000017c_DIB<14>_UNCONNECTED , 
\NLW_blk0000017c_DIB<13>_UNCONNECTED , \NLW_blk0000017c_DIB<12>_UNCONNECTED , \NLW_blk0000017c_DIB<11>_UNCONNECTED , 
\NLW_blk0000017c_DIB<10>_UNCONNECTED , \NLW_blk0000017c_DIB<9>_UNCONNECTED , \NLW_blk0000017c_DIB<8>_UNCONNECTED , 
\NLW_blk0000017c_DIB<7>_UNCONNECTED , \NLW_blk0000017c_DIB<6>_UNCONNECTED , \NLW_blk0000017c_DIB<5>_UNCONNECTED , \NLW_blk0000017c_DIB<4>_UNCONNECTED 
, \NLW_blk0000017c_DIB<3>_UNCONNECTED , \NLW_blk0000017c_DIB<2>_UNCONNECTED , \NLW_blk0000017c_DIB<1>_UNCONNECTED , 
\NLW_blk0000017c_DIB<0>_UNCONNECTED }),
    .DOPA({\NLW_blk0000017c_DOPA<3>_UNCONNECTED , \NLW_blk0000017c_DOPA<2>_UNCONNECTED , sig000000dd, sig000000de}),
    .DIPB({\NLW_blk0000017c_DIPB<3>_UNCONNECTED , \NLW_blk0000017c_DIPB<2>_UNCONNECTED , \NLW_blk0000017c_DIPB<1>_UNCONNECTED , 
\NLW_blk0000017c_DIPB<0>_UNCONNECTED }),
    .DOPB({\NLW_blk0000017c_DOPB<3>_UNCONNECTED , \NLW_blk0000017c_DOPB<2>_UNCONNECTED , \NLW_blk0000017c_DOPB<1>_UNCONNECTED , 
\NLW_blk0000017c_DOPB<0>_UNCONNECTED }),
    .DOB({\NLW_blk0000017c_DOB<31>_UNCONNECTED , \NLW_blk0000017c_DOB<30>_UNCONNECTED , \NLW_blk0000017c_DOB<29>_UNCONNECTED , 
\NLW_blk0000017c_DOB<28>_UNCONNECTED , \NLW_blk0000017c_DOB<27>_UNCONNECTED , \NLW_blk0000017c_DOB<26>_UNCONNECTED , 
\NLW_blk0000017c_DOB<25>_UNCONNECTED , \NLW_blk0000017c_DOB<24>_UNCONNECTED , \NLW_blk0000017c_DOB<23>_UNCONNECTED , 
\NLW_blk0000017c_DOB<22>_UNCONNECTED , \NLW_blk0000017c_DOB<21>_UNCONNECTED , \NLW_blk0000017c_DOB<20>_UNCONNECTED , 
\NLW_blk0000017c_DOB<19>_UNCONNECTED , \NLW_blk0000017c_DOB<18>_UNCONNECTED , \NLW_blk0000017c_DOB<17>_UNCONNECTED , 
\NLW_blk0000017c_DOB<16>_UNCONNECTED , \NLW_blk0000017c_DOB<15>_UNCONNECTED , \NLW_blk0000017c_DOB<14>_UNCONNECTED , 
\NLW_blk0000017c_DOB<13>_UNCONNECTED , \NLW_blk0000017c_DOB<12>_UNCONNECTED , \NLW_blk0000017c_DOB<11>_UNCONNECTED , 
\NLW_blk0000017c_DOB<10>_UNCONNECTED , \NLW_blk0000017c_DOB<9>_UNCONNECTED , \NLW_blk0000017c_DOB<8>_UNCONNECTED , 
\NLW_blk0000017c_DOB<7>_UNCONNECTED , \NLW_blk0000017c_DOB<6>_UNCONNECTED , \NLW_blk0000017c_DOB<5>_UNCONNECTED , \NLW_blk0000017c_DOB<4>_UNCONNECTED 
, \NLW_blk0000017c_DOB<3>_UNCONNECTED , \NLW_blk0000017c_DOB<2>_UNCONNECTED , \NLW_blk0000017c_DOB<1>_UNCONNECTED , 
\NLW_blk0000017c_DOB<0>_UNCONNECTED }),
    .WEB({\NLW_blk0000017c_WEB<3>_UNCONNECTED , \NLW_blk0000017c_WEB<2>_UNCONNECTED , \NLW_blk0000017c_WEB<1>_UNCONNECTED , 
\NLW_blk0000017c_WEB<0>_UNCONNECTED }),
    .DIA({\NLW_blk0000017c_DIA<31>_UNCONNECTED , \NLW_blk0000017c_DIA<30>_UNCONNECTED , \NLW_blk0000017c_DIA<29>_UNCONNECTED , 
\NLW_blk0000017c_DIA<28>_UNCONNECTED , \NLW_blk0000017c_DIA<27>_UNCONNECTED , \NLW_blk0000017c_DIA<26>_UNCONNECTED , 
\NLW_blk0000017c_DIA<25>_UNCONNECTED , \NLW_blk0000017c_DIA<24>_UNCONNECTED , \NLW_blk0000017c_DIA<23>_UNCONNECTED , 
\NLW_blk0000017c_DIA<22>_UNCONNECTED , \NLW_blk0000017c_DIA<21>_UNCONNECTED , \NLW_blk0000017c_DIA<20>_UNCONNECTED , 
\NLW_blk0000017c_DIA<19>_UNCONNECTED , \NLW_blk0000017c_DIA<18>_UNCONNECTED , \NLW_blk0000017c_DIA<17>_UNCONNECTED , 
\NLW_blk0000017c_DIA<16>_UNCONNECTED , sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, 
sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189, sig00000189})
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk0000017d (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000b6),
    .Q(sig0000020a),
    .Q15(NLW_blk0000017d_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000017e (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000020a),
    .Q(sig0000003a)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk0000017f (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000b5),
    .Q(sig0000020b),
    .Q15(NLW_blk0000017f_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000180 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000020b),
    .Q(sig00000039)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000181 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000b4),
    .Q(sig0000020c),
    .Q15(NLW_blk00000181_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000182 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000020c),
    .Q(sig00000038)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000183 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000b3),
    .Q(sig0000020d),
    .Q15(NLW_blk00000183_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000184 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000020d),
    .Q(sig00000037)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000185 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000b2),
    .Q(sig0000020e),
    .Q15(NLW_blk00000185_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000186 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000020e),
    .Q(sig00000036)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000187 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000b1),
    .Q(sig0000020f),
    .Q15(NLW_blk00000187_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000188 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000020f),
    .Q(sig00000035)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000189 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000b0),
    .Q(sig00000210),
    .Q15(NLW_blk00000189_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000018a (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000210),
    .Q(sig00000034)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk0000018b (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000af),
    .Q(sig00000211),
    .Q15(NLW_blk0000018b_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000018c (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000211),
    .Q(sig00000033)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk0000018d (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000ae),
    .Q(sig00000212),
    .Q15(NLW_blk0000018d_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000018e (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000212),
    .Q(sig00000032)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk0000018f (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000ad),
    .Q(sig00000213),
    .Q15(NLW_blk0000018f_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000190 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000213),
    .Q(sig00000031)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000191 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000ac),
    .Q(sig00000214),
    .Q15(NLW_blk00000191_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000192 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000214),
    .Q(sig00000030)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000193 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000ab),
    .Q(sig00000215),
    .Q15(NLW_blk00000193_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000194 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000215),
    .Q(sig0000002f)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000195 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000a8),
    .Q(sig00000216),
    .Q15(NLW_blk00000195_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000196 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000216),
    .Q(sig0000002c)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000197 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000aa),
    .Q(sig00000217),
    .Q15(NLW_blk00000197_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000198 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000217),
    .Q(sig0000002e)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000199 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000a9),
    .Q(sig00000218),
    .Q15(NLW_blk00000199_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000019a (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000218),
    .Q(sig0000002d)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk0000019b (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000a7),
    .Q(sig00000219),
    .Q15(NLW_blk0000019b_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000019c (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000219),
    .Q(sig0000002b)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk0000019d (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000a6),
    .Q(sig0000021a),
    .Q15(NLW_blk0000019d_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000019e (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000021a),
    .Q(sig0000002a)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk0000019f (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000a5),
    .Q(sig0000021b),
    .Q15(NLW_blk0000019f_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001a0 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000021b),
    .Q(sig00000029)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001a1 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000a4),
    .Q(sig00000028),
    .Q15(NLW_blk000001a1_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001a2 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000a1),
    .Q(sig00000025),
    .Q15(NLW_blk000001a2_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001a3 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000a3),
    .Q(sig00000027),
    .Q15(NLW_blk000001a3_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001a4 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000a2),
    .Q(sig00000026),
    .Q15(NLW_blk000001a4_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001a5 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000a0),
    .Q(sig00000024),
    .Q15(NLW_blk000001a5_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001a6 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000009f),
    .Q(sig00000023),
    .Q15(NLW_blk000001a6_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001a7 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000009e),
    .Q(sig0000021c),
    .Q15(NLW_blk000001a7_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001a8 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000021c),
    .Q(sig00000052)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001a9 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000009d),
    .Q(sig0000021d),
    .Q15(NLW_blk000001a9_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001aa (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000021d),
    .Q(sig00000051)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001ab (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000009a),
    .Q(sig0000021e),
    .Q15(NLW_blk000001ab_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001ac (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000021e),
    .Q(sig0000004e)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001ad (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000009c),
    .Q(sig0000021f),
    .Q15(NLW_blk000001ad_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001ae (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000021f),
    .Q(sig00000050)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001af (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000009b),
    .Q(sig00000220),
    .Q15(NLW_blk000001af_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001b0 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000220),
    .Q(sig0000004f)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001b1 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000099),
    .Q(sig00000221),
    .Q15(NLW_blk000001b1_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001b2 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000221),
    .Q(sig0000004d)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001b3 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000098),
    .Q(sig00000222),
    .Q15(NLW_blk000001b3_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001b4 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000222),
    .Q(sig0000004c)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001b5 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000097),
    .Q(sig00000223),
    .Q15(NLW_blk000001b5_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001b6 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000223),
    .Q(sig0000004b)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001b7 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000096),
    .Q(sig00000224),
    .Q15(NLW_blk000001b7_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001b8 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000224),
    .Q(sig0000004a)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001b9 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000095),
    .Q(sig00000225),
    .Q15(NLW_blk000001b9_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001ba (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000225),
    .Q(sig00000049)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001bb (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000094),
    .Q(sig00000226),
    .Q15(NLW_blk000001bb_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001bc (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000226),
    .Q(sig00000048)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001bd (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000093),
    .Q(sig00000227),
    .Q15(NLW_blk000001bd_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001be (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000227),
    .Q(sig00000047)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001bf (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000092),
    .Q(sig00000228),
    .Q15(NLW_blk000001bf_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001c0 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000228),
    .Q(sig00000046)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001c1 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000091),
    .Q(sig00000229),
    .Q15(NLW_blk000001c1_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001c2 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000229),
    .Q(sig00000045)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001c3 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000090),
    .Q(sig0000022a),
    .Q15(NLW_blk000001c3_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001c4 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000022a),
    .Q(sig00000044)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001c5 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000008f),
    .Q(sig0000022b),
    .Q15(NLW_blk000001c5_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001c6 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000022b),
    .Q(sig00000043)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001c7 (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000008e),
    .Q(sig0000022c),
    .Q15(NLW_blk000001c7_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001c8 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000022c),
    .Q(sig00000042)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001c9 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000008b),
    .Q(sig0000003f),
    .Q15(NLW_blk000001c9_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001ca (
    .A0(sig00000189),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000008d),
    .Q(sig0000022d),
    .Q15(NLW_blk000001ca_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001cb (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000022d),
    .Q(sig00000041)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001cc (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000008c),
    .Q(sig00000040),
    .Q15(NLW_blk000001cc_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001cd (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig0000008a),
    .Q(sig0000003e),
    .Q15(NLW_blk000001cd_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001ce (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000089),
    .Q(sig0000003d),
    .Q15(NLW_blk000001ce_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001cf (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000088),
    .Q(sig0000003c),
    .Q15(NLW_blk000001cf_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001d0 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig00000087),
    .Q(sig0000003b),
    .Q15(NLW_blk000001d0_Q15_UNCONNECTED)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001d1 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000f2),
    .Q(sig0000022e),
    .Q15(NLW_blk000001d1_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001d2 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000022e),
    .Q(sig0000012c)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001d3 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000f0),
    .Q(sig0000022f),
    .Q15(NLW_blk000001d3_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001d4 (
    .C(clk),
    .CE(sig00000001),
    .D(sig0000022f),
    .Q(sig0000012e)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001d5 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000f1),
    .Q(sig00000230),
    .Q15(NLW_blk000001d5_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001d6 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000230),
    .Q(sig0000012d)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001d7 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000f3),
    .Q(sig00000231),
    .Q15(NLW_blk000001d7_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001d8 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000231),
    .Q(sig0000012b)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001d9 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000f4),
    .Q(sig00000232),
    .Q15(NLW_blk000001d9_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001da (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000232),
    .Q(sig0000012a)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001db (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000f5),
    .Q(sig00000233),
    .Q15(NLW_blk000001db_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001dc (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000233),
    .Q(sig00000129)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001dd (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000f6),
    .Q(sig00000234),
    .Q15(NLW_blk000001dd_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001de (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000234),
    .Q(sig00000128)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001df (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000f9),
    .Q(sig00000235),
    .Q15(NLW_blk000001df_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001e0 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000235),
    .Q(sig00000125)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001e1 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000f7),
    .Q(sig00000236),
    .Q15(NLW_blk000001e1_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001e2 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000236),
    .Q(sig00000127)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk000001e3 (
    .A0(sig00000001),
    .A1(sig00000189),
    .A2(sig00000189),
    .A3(sig00000189),
    .CE(sig00000001),
    .CLK(clk),
    .D(sig000000f8),
    .Q(sig00000237),
    .Q15(NLW_blk000001e3_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000001e4 (
    .C(clk),
    .CE(sig00000001),
    .D(sig00000237),
    .Q(sig00000126)
  );
  XORCY   \blk00000024/blk00000085  (
    .CI(\blk00000024/sig000002d6 ),
    .LI(\blk00000024/sig000002d7 ),
    .O(sig00000003)
  );
  MUXCY   \blk00000024/blk00000084  (
    .CI(\blk00000024/sig000002d6 ),
    .DI(sig00000072),
    .S(\blk00000024/sig000002d7 ),
    .O(sig00000002)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000083  (
    .I0(sig00000072),
    .I1(pinc_in[31]),
    .O(\blk00000024/sig000002d7 )
  );
  XORCY   \blk00000024/blk00000082  (
    .CI(\blk00000024/sig000002d4 ),
    .LI(\blk00000024/sig000002d5 ),
    .O(sig00000004)
  );
  MUXCY   \blk00000024/blk00000081  (
    .CI(\blk00000024/sig000002d4 ),
    .DI(sig00000071),
    .S(\blk00000024/sig000002d5 ),
    .O(\blk00000024/sig000002d6 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000080  (
    .I0(pinc_in[30]),
    .I1(sig00000071),
    .O(\blk00000024/sig000002d5 )
  );
  XORCY   \blk00000024/blk0000007f  (
    .CI(\blk00000024/sig000002d2 ),
    .LI(\blk00000024/sig000002d3 ),
    .O(sig00000005)
  );
  MUXCY   \blk00000024/blk0000007e  (
    .CI(\blk00000024/sig000002d2 ),
    .DI(sig00000070),
    .S(\blk00000024/sig000002d3 ),
    .O(\blk00000024/sig000002d4 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000007d  (
    .I0(sig00000070),
    .I1(pinc_in[29]),
    .O(\blk00000024/sig000002d3 )
  );
  XORCY   \blk00000024/blk0000007c  (
    .CI(\blk00000024/sig000002d0 ),
    .LI(\blk00000024/sig000002d1 ),
    .O(sig00000006)
  );
  MUXCY   \blk00000024/blk0000007b  (
    .CI(\blk00000024/sig000002d0 ),
    .DI(sig0000006f),
    .S(\blk00000024/sig000002d1 ),
    .O(\blk00000024/sig000002d2 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000007a  (
    .I0(sig0000006f),
    .I1(pinc_in[28]),
    .O(\blk00000024/sig000002d1 )
  );
  XORCY   \blk00000024/blk00000079  (
    .CI(\blk00000024/sig000002ce ),
    .LI(\blk00000024/sig000002cf ),
    .O(sig00000007)
  );
  MUXCY   \blk00000024/blk00000078  (
    .CI(\blk00000024/sig000002ce ),
    .DI(sig0000006e),
    .S(\blk00000024/sig000002cf ),
    .O(\blk00000024/sig000002d0 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000077  (
    .I0(sig0000006e),
    .I1(pinc_in[27]),
    .O(\blk00000024/sig000002cf )
  );
  XORCY   \blk00000024/blk00000076  (
    .CI(\blk00000024/sig000002cc ),
    .LI(\blk00000024/sig000002cd ),
    .O(sig00000008)
  );
  MUXCY   \blk00000024/blk00000075  (
    .CI(\blk00000024/sig000002cc ),
    .DI(sig0000006d),
    .S(\blk00000024/sig000002cd ),
    .O(\blk00000024/sig000002ce )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000074  (
    .I0(pinc_in[26]),
    .I1(sig0000006d),
    .O(\blk00000024/sig000002cd )
  );
  XORCY   \blk00000024/blk00000073  (
    .CI(\blk00000024/sig000002ca ),
    .LI(\blk00000024/sig000002cb ),
    .O(sig00000009)
  );
  MUXCY   \blk00000024/blk00000072  (
    .CI(\blk00000024/sig000002ca ),
    .DI(sig0000006c),
    .S(\blk00000024/sig000002cb ),
    .O(\blk00000024/sig000002cc )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000071  (
    .I0(pinc_in[25]),
    .I1(sig0000006c),
    .O(\blk00000024/sig000002cb )
  );
  XORCY   \blk00000024/blk00000070  (
    .CI(\blk00000024/sig000002c8 ),
    .LI(\blk00000024/sig000002c9 ),
    .O(sig0000000a)
  );
  MUXCY   \blk00000024/blk0000006f  (
    .CI(\blk00000024/sig000002c8 ),
    .DI(sig0000006b),
    .S(\blk00000024/sig000002c9 ),
    .O(\blk00000024/sig000002ca )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000006e  (
    .I0(pinc_in[24]),
    .I1(sig0000006b),
    .O(\blk00000024/sig000002c9 )
  );
  XORCY   \blk00000024/blk0000006d  (
    .CI(\blk00000024/sig000002c6 ),
    .LI(\blk00000024/sig000002c7 ),
    .O(sig0000000b)
  );
  MUXCY   \blk00000024/blk0000006c  (
    .CI(\blk00000024/sig000002c6 ),
    .DI(sig0000006a),
    .S(\blk00000024/sig000002c7 ),
    .O(\blk00000024/sig000002c8 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000006b  (
    .I0(pinc_in[23]),
    .I1(sig0000006a),
    .O(\blk00000024/sig000002c7 )
  );
  XORCY   \blk00000024/blk0000006a  (
    .CI(\blk00000024/sig000002c4 ),
    .LI(\blk00000024/sig000002c5 ),
    .O(sig0000000c)
  );
  MUXCY   \blk00000024/blk00000069  (
    .CI(\blk00000024/sig000002c4 ),
    .DI(sig00000069),
    .S(\blk00000024/sig000002c5 ),
    .O(\blk00000024/sig000002c6 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000068  (
    .I0(pinc_in[22]),
    .I1(sig00000069),
    .O(\blk00000024/sig000002c5 )
  );
  XORCY   \blk00000024/blk00000067  (
    .CI(\blk00000024/sig000002c2 ),
    .LI(\blk00000024/sig000002c3 ),
    .O(sig0000000d)
  );
  MUXCY   \blk00000024/blk00000066  (
    .CI(\blk00000024/sig000002c2 ),
    .DI(sig00000068),
    .S(\blk00000024/sig000002c3 ),
    .O(\blk00000024/sig000002c4 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000065  (
    .I0(pinc_in[21]),
    .I1(sig00000068),
    .O(\blk00000024/sig000002c3 )
  );
  XORCY   \blk00000024/blk00000064  (
    .CI(\blk00000024/sig000002c0 ),
    .LI(\blk00000024/sig000002c1 ),
    .O(sig0000000e)
  );
  MUXCY   \blk00000024/blk00000063  (
    .CI(\blk00000024/sig000002c0 ),
    .DI(sig00000067),
    .S(\blk00000024/sig000002c1 ),
    .O(\blk00000024/sig000002c2 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000062  (
    .I0(pinc_in[20]),
    .I1(sig00000067),
    .O(\blk00000024/sig000002c1 )
  );
  XORCY   \blk00000024/blk00000061  (
    .CI(\blk00000024/sig000002be ),
    .LI(\blk00000024/sig000002bf ),
    .O(sig0000000f)
  );
  MUXCY   \blk00000024/blk00000060  (
    .CI(\blk00000024/sig000002be ),
    .DI(sig00000066),
    .S(\blk00000024/sig000002bf ),
    .O(\blk00000024/sig000002c0 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000005f  (
    .I0(pinc_in[19]),
    .I1(sig00000066),
    .O(\blk00000024/sig000002bf )
  );
  XORCY   \blk00000024/blk0000005e  (
    .CI(\blk00000024/sig000002bc ),
    .LI(\blk00000024/sig000002bd ),
    .O(sig00000010)
  );
  MUXCY   \blk00000024/blk0000005d  (
    .CI(\blk00000024/sig000002bc ),
    .DI(sig00000065),
    .S(\blk00000024/sig000002bd ),
    .O(\blk00000024/sig000002be )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000005c  (
    .I0(pinc_in[18]),
    .I1(sig00000065),
    .O(\blk00000024/sig000002bd )
  );
  XORCY   \blk00000024/blk0000005b  (
    .CI(\blk00000024/sig000002ba ),
    .LI(\blk00000024/sig000002bb ),
    .O(sig00000011)
  );
  MUXCY   \blk00000024/blk0000005a  (
    .CI(\blk00000024/sig000002ba ),
    .DI(sig00000064),
    .S(\blk00000024/sig000002bb ),
    .O(\blk00000024/sig000002bc )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000059  (
    .I0(pinc_in[17]),
    .I1(sig00000064),
    .O(\blk00000024/sig000002bb )
  );
  XORCY   \blk00000024/blk00000058  (
    .CI(\blk00000024/sig000002b8 ),
    .LI(\blk00000024/sig000002b9 ),
    .O(sig00000012)
  );
  MUXCY   \blk00000024/blk00000057  (
    .CI(\blk00000024/sig000002b8 ),
    .DI(sig00000063),
    .S(\blk00000024/sig000002b9 ),
    .O(\blk00000024/sig000002ba )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000056  (
    .I0(pinc_in[16]),
    .I1(sig00000063),
    .O(\blk00000024/sig000002b9 )
  );
  XORCY   \blk00000024/blk00000055  (
    .CI(\blk00000024/sig000002b6 ),
    .LI(\blk00000024/sig000002b7 ),
    .O(sig00000013)
  );
  MUXCY   \blk00000024/blk00000054  (
    .CI(\blk00000024/sig000002b6 ),
    .DI(sig00000062),
    .S(\blk00000024/sig000002b7 ),
    .O(\blk00000024/sig000002b8 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000053  (
    .I0(pinc_in[15]),
    .I1(sig00000062),
    .O(\blk00000024/sig000002b7 )
  );
  XORCY   \blk00000024/blk00000052  (
    .CI(\blk00000024/sig000002b4 ),
    .LI(\blk00000024/sig000002b5 ),
    .O(sig00000014)
  );
  MUXCY   \blk00000024/blk00000051  (
    .CI(\blk00000024/sig000002b4 ),
    .DI(sig00000061),
    .S(\blk00000024/sig000002b5 ),
    .O(\blk00000024/sig000002b6 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000050  (
    .I0(pinc_in[14]),
    .I1(sig00000061),
    .O(\blk00000024/sig000002b5 )
  );
  XORCY   \blk00000024/blk0000004f  (
    .CI(\blk00000024/sig000002b2 ),
    .LI(\blk00000024/sig000002b3 ),
    .O(sig00000015)
  );
  MUXCY   \blk00000024/blk0000004e  (
    .CI(\blk00000024/sig000002b2 ),
    .DI(sig00000060),
    .S(\blk00000024/sig000002b3 ),
    .O(\blk00000024/sig000002b4 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000004d  (
    .I0(pinc_in[13]),
    .I1(sig00000060),
    .O(\blk00000024/sig000002b3 )
  );
  XORCY   \blk00000024/blk0000004c  (
    .CI(\blk00000024/sig000002b0 ),
    .LI(\blk00000024/sig000002b1 ),
    .O(sig00000016)
  );
  MUXCY   \blk00000024/blk0000004b  (
    .CI(\blk00000024/sig000002b0 ),
    .DI(sig0000005f),
    .S(\blk00000024/sig000002b1 ),
    .O(\blk00000024/sig000002b2 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000004a  (
    .I0(pinc_in[12]),
    .I1(sig0000005f),
    .O(\blk00000024/sig000002b1 )
  );
  XORCY   \blk00000024/blk00000049  (
    .CI(\blk00000024/sig000002ae ),
    .LI(\blk00000024/sig000002af ),
    .O(sig00000017)
  );
  MUXCY   \blk00000024/blk00000048  (
    .CI(\blk00000024/sig000002ae ),
    .DI(sig0000005e),
    .S(\blk00000024/sig000002af ),
    .O(\blk00000024/sig000002b0 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000047  (
    .I0(pinc_in[11]),
    .I1(sig0000005e),
    .O(\blk00000024/sig000002af )
  );
  XORCY   \blk00000024/blk00000046  (
    .CI(\blk00000024/sig000002ac ),
    .LI(\blk00000024/sig000002ad ),
    .O(sig00000018)
  );
  MUXCY   \blk00000024/blk00000045  (
    .CI(\blk00000024/sig000002ac ),
    .DI(sig0000005d),
    .S(\blk00000024/sig000002ad ),
    .O(\blk00000024/sig000002ae )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000044  (
    .I0(pinc_in[10]),
    .I1(sig0000005d),
    .O(\blk00000024/sig000002ad )
  );
  XORCY   \blk00000024/blk00000043  (
    .CI(\blk00000024/sig000002aa ),
    .LI(\blk00000024/sig000002ab ),
    .O(sig00000019)
  );
  MUXCY   \blk00000024/blk00000042  (
    .CI(\blk00000024/sig000002aa ),
    .DI(sig0000005c),
    .S(\blk00000024/sig000002ab ),
    .O(\blk00000024/sig000002ac )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000041  (
    .I0(pinc_in[9]),
    .I1(sig0000005c),
    .O(\blk00000024/sig000002ab )
  );
  XORCY   \blk00000024/blk00000040  (
    .CI(\blk00000024/sig000002a8 ),
    .LI(\blk00000024/sig000002a9 ),
    .O(sig0000001a)
  );
  MUXCY   \blk00000024/blk0000003f  (
    .CI(\blk00000024/sig000002a8 ),
    .DI(sig0000005b),
    .S(\blk00000024/sig000002a9 ),
    .O(\blk00000024/sig000002aa )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000003e  (
    .I0(pinc_in[8]),
    .I1(sig0000005b),
    .O(\blk00000024/sig000002a9 )
  );
  XORCY   \blk00000024/blk0000003d  (
    .CI(\blk00000024/sig000002a6 ),
    .LI(\blk00000024/sig000002a7 ),
    .O(sig0000001b)
  );
  MUXCY   \blk00000024/blk0000003c  (
    .CI(\blk00000024/sig000002a6 ),
    .DI(sig0000005a),
    .S(\blk00000024/sig000002a7 ),
    .O(\blk00000024/sig000002a8 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000003b  (
    .I0(pinc_in[7]),
    .I1(sig0000005a),
    .O(\blk00000024/sig000002a7 )
  );
  XORCY   \blk00000024/blk0000003a  (
    .CI(\blk00000024/sig000002a4 ),
    .LI(\blk00000024/sig000002a5 ),
    .O(sig0000001c)
  );
  MUXCY   \blk00000024/blk00000039  (
    .CI(\blk00000024/sig000002a4 ),
    .DI(sig00000059),
    .S(\blk00000024/sig000002a5 ),
    .O(\blk00000024/sig000002a6 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000038  (
    .I0(pinc_in[6]),
    .I1(sig00000059),
    .O(\blk00000024/sig000002a5 )
  );
  XORCY   \blk00000024/blk00000037  (
    .CI(\blk00000024/sig000002a2 ),
    .LI(\blk00000024/sig000002a3 ),
    .O(sig0000001d)
  );
  MUXCY   \blk00000024/blk00000036  (
    .CI(\blk00000024/sig000002a2 ),
    .DI(sig00000058),
    .S(\blk00000024/sig000002a3 ),
    .O(\blk00000024/sig000002a4 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000035  (
    .I0(pinc_in[5]),
    .I1(sig00000058),
    .O(\blk00000024/sig000002a3 )
  );
  XORCY   \blk00000024/blk00000034  (
    .CI(\blk00000024/sig000002a0 ),
    .LI(\blk00000024/sig000002a1 ),
    .O(sig0000001e)
  );
  MUXCY   \blk00000024/blk00000033  (
    .CI(\blk00000024/sig000002a0 ),
    .DI(sig00000057),
    .S(\blk00000024/sig000002a1 ),
    .O(\blk00000024/sig000002a2 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000032  (
    .I0(pinc_in[4]),
    .I1(sig00000057),
    .O(\blk00000024/sig000002a1 )
  );
  XORCY   \blk00000024/blk00000031  (
    .CI(\blk00000024/sig0000029e ),
    .LI(\blk00000024/sig0000029f ),
    .O(sig0000001f)
  );
  MUXCY   \blk00000024/blk00000030  (
    .CI(\blk00000024/sig0000029e ),
    .DI(sig00000056),
    .S(\blk00000024/sig0000029f ),
    .O(\blk00000024/sig000002a0 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000002f  (
    .I0(pinc_in[3]),
    .I1(sig00000056),
    .O(\blk00000024/sig0000029f )
  );
  XORCY   \blk00000024/blk0000002e  (
    .CI(\blk00000024/sig0000029c ),
    .LI(\blk00000024/sig0000029d ),
    .O(sig00000020)
  );
  MUXCY   \blk00000024/blk0000002d  (
    .CI(\blk00000024/sig0000029c ),
    .DI(sig00000055),
    .S(\blk00000024/sig0000029d ),
    .O(\blk00000024/sig0000029e )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk0000002c  (
    .I0(pinc_in[2]),
    .I1(sig00000055),
    .O(\blk00000024/sig0000029d )
  );
  XORCY   \blk00000024/blk0000002b  (
    .CI(\blk00000024/sig0000029a ),
    .LI(\blk00000024/sig0000029b ),
    .O(sig00000021)
  );
  MUXCY   \blk00000024/blk0000002a  (
    .CI(\blk00000024/sig0000029a ),
    .DI(sig00000054),
    .S(\blk00000024/sig0000029b ),
    .O(\blk00000024/sig0000029c )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000029  (
    .I0(pinc_in[1]),
    .I1(sig00000054),
    .O(\blk00000024/sig0000029b )
  );
  XORCY   \blk00000024/blk00000028  (
    .CI(\blk00000024/sig00000298 ),
    .LI(\blk00000024/sig00000299 ),
    .O(sig00000022)
  );
  MUXCY   \blk00000024/blk00000027  (
    .CI(\blk00000024/sig00000298 ),
    .DI(sig00000053),
    .S(\blk00000024/sig00000299 ),
    .O(\blk00000024/sig0000029a )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000024/blk00000026  (
    .I0(pinc_in[0]),
    .I1(sig00000053),
    .O(\blk00000024/sig00000299 )
  );
  GND   \blk00000024/blk00000025  (
    .G(\blk00000024/sig00000298 )
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

// synthesis translate_on
