////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.20131013
//  \   \         Application: netgen
//  /   /         Filename: dds_PG_pw24.v
// /___/   /\     Timestamp: Wed Oct 22 14:04:31 2025
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog C:/Users/fevi/Desktop/digital-servo-master/firmware/ipcore_dir/tmp/_cg/dds_PG_pw24.ngc C:/Users/fevi/Desktop/digital-servo-master/firmware/ipcore_dir/tmp/_cg/dds_PG_pw24.v 
// Device	: 6slx150fgg484-2
// Input file	: C:/Users/fevi/Desktop/digital-servo-master/firmware/ipcore_dir/tmp/_cg/dds_PG_pw24.ngc
// Output file	: C:/Users/fevi/Desktop/digital-servo-master/firmware/ipcore_dir/tmp/_cg/dds_PG_pw24.v
// # of Modules	: 1
// Design Name	: dds_PG_pw24
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

module dds_PG_pw24 (
  clk, pinc_in, phase_out
)/* synthesis syn_black_box syn_noprune=1 */;
  input clk;
  input [23 : 0] pinc_in;
  output [23 : 0] phase_out;
  
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
  wire \blk0000001a/sig00000092 ;
  wire \blk0000001a/sig00000091 ;
  wire \blk0000001a/sig00000090 ;
  wire \blk0000001a/sig0000008f ;
  wire \blk0000001a/sig0000008e ;
  wire \blk0000001a/sig0000008d ;
  wire \blk0000001a/sig0000008c ;
  wire \blk0000001a/sig0000008b ;
  wire \blk0000001a/sig0000008a ;
  wire \blk0000001a/sig00000089 ;
  wire \blk0000001a/sig00000088 ;
  wire \blk0000001a/sig00000087 ;
  wire \blk0000001a/sig00000086 ;
  wire \blk0000001a/sig00000085 ;
  wire \blk0000001a/sig00000084 ;
  wire \blk0000001a/sig00000083 ;
  wire \blk0000001a/sig00000082 ;
  wire \blk0000001a/sig00000081 ;
  wire \blk0000001a/sig00000080 ;
  wire \blk0000001a/sig0000007f ;
  wire \blk0000001a/sig0000007e ;
  wire \blk0000001a/sig0000007d ;
  wire \blk0000001a/sig0000007c ;
  wire \blk0000001a/sig0000007b ;
  wire \blk0000001a/sig0000007a ;
  wire \blk0000001a/sig00000079 ;
  wire \blk0000001a/sig00000078 ;
  wire \blk0000001a/sig00000077 ;
  wire \blk0000001a/sig00000076 ;
  wire \blk0000001a/sig00000075 ;
  wire \blk0000001a/sig00000074 ;
  wire \blk0000001a/sig00000073 ;
  wire \blk0000001a/sig00000072 ;
  wire \blk0000001a/sig00000071 ;
  wire \blk0000001a/sig00000070 ;
  wire \blk0000001a/sig0000006f ;
  wire \blk0000001a/sig0000006e ;
  wire \blk0000001a/sig0000006d ;
  wire \blk0000001a/sig0000006c ;
  wire \blk0000001a/sig0000006b ;
  wire \blk0000001a/sig0000006a ;
  wire \blk0000001a/sig00000069 ;
  wire \blk0000001a/sig00000068 ;
  wire \blk0000001a/sig00000067 ;
  wire \blk0000001a/sig00000066 ;
  wire \blk0000001a/sig00000065 ;
  wire \blk0000001a/sig00000064 ;
  wire \blk0000001a/sig00000063 ;
  wire [23 : 0] \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q ;
  assign
    phase_out[23] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [23],
    phase_out[22] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [22],
    phase_out[21] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [21],
    phase_out[20] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [20],
    phase_out[19] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [19],
    phase_out[18] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [18],
    phase_out[17] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [17],
    phase_out[16] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [16],
    phase_out[15] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [15],
    phase_out[14] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [14],
    phase_out[13] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [13],
    phase_out[12] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [12],
    phase_out[11] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [11],
    phase_out[10] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [10],
    phase_out[9] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [9],
    phase_out[8] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [8],
    phase_out[7] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [7],
    phase_out[6] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [6],
    phase_out[5] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [5],
    phase_out[4] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [4],
    phase_out[3] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [3],
    phase_out[2] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [2],
    phase_out[1] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [1],
    phase_out[0] = \NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [0];
  FD #(
    .INIT ( 1'b0 ))
  blk00000001 (
    .C(clk),
    .D(sig00000019),
    .Q(sig0000001a)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000002 (
    .C(clk),
    .D(sig00000018),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [23])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000003 (
    .C(clk),
    .D(sig00000017),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [22])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000004 (
    .C(clk),
    .D(sig00000016),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [21])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000005 (
    .C(clk),
    .D(sig00000015),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [20])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000006 (
    .C(clk),
    .D(sig00000014),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [19])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000007 (
    .C(clk),
    .D(sig00000013),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [18])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000008 (
    .C(clk),
    .D(sig00000012),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [17])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000009 (
    .C(clk),
    .D(sig00000011),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [16])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000a (
    .C(clk),
    .D(sig00000010),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [15])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000b (
    .C(clk),
    .D(sig0000000f),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [14])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000c (
    .C(clk),
    .D(sig0000000e),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [13])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000d (
    .C(clk),
    .D(sig0000000d),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [12])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000e (
    .C(clk),
    .D(sig0000000c),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [11])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000f (
    .C(clk),
    .D(sig0000000b),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [10])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000010 (
    .C(clk),
    .D(sig0000000a),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [9])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000011 (
    .C(clk),
    .D(sig00000009),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [8])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000012 (
    .C(clk),
    .D(sig00000008),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [7])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000013 (
    .C(clk),
    .D(sig00000007),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [6])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000014 (
    .C(clk),
    .D(sig00000006),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [5])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000015 (
    .C(clk),
    .D(sig00000005),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [4])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000016 (
    .C(clk),
    .D(sig00000004),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [3])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000017 (
    .C(clk),
    .D(sig00000003),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [2])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000018 (
    .C(clk),
    .D(sig00000002),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [1])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000019 (
    .C(clk),
    .D(sig00000001),
    .Q(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [0])
  );
  XORCY   \blk0000001a/blk00000063  (
    .CI(\blk0000001a/sig00000091 ),
    .LI(\blk0000001a/sig00000092 ),
    .O(sig00000018)
  );
  MUXCY   \blk0000001a/blk00000062  (
    .CI(\blk0000001a/sig00000091 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [23]),
    .S(\blk0000001a/sig00000092 ),
    .O(sig00000019)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000061  (
    .I0(pinc_in[23]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [23]),
    .O(\blk0000001a/sig00000092 )
  );
  XORCY   \blk0000001a/blk00000060  (
    .CI(\blk0000001a/sig0000008f ),
    .LI(\blk0000001a/sig00000090 ),
    .O(sig00000017)
  );
  MUXCY   \blk0000001a/blk0000005f  (
    .CI(\blk0000001a/sig0000008f ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [22]),
    .S(\blk0000001a/sig00000090 ),
    .O(\blk0000001a/sig00000091 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk0000005e  (
    .I0(pinc_in[22]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [22]),
    .O(\blk0000001a/sig00000090 )
  );
  XORCY   \blk0000001a/blk0000005d  (
    .CI(\blk0000001a/sig0000008d ),
    .LI(\blk0000001a/sig0000008e ),
    .O(sig00000016)
  );
  MUXCY   \blk0000001a/blk0000005c  (
    .CI(\blk0000001a/sig0000008d ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [21]),
    .S(\blk0000001a/sig0000008e ),
    .O(\blk0000001a/sig0000008f )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk0000005b  (
    .I0(pinc_in[21]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [21]),
    .O(\blk0000001a/sig0000008e )
  );
  XORCY   \blk0000001a/blk0000005a  (
    .CI(\blk0000001a/sig0000008b ),
    .LI(\blk0000001a/sig0000008c ),
    .O(sig00000015)
  );
  MUXCY   \blk0000001a/blk00000059  (
    .CI(\blk0000001a/sig0000008b ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [20]),
    .S(\blk0000001a/sig0000008c ),
    .O(\blk0000001a/sig0000008d )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000058  (
    .I0(pinc_in[20]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [20]),
    .O(\blk0000001a/sig0000008c )
  );
  XORCY   \blk0000001a/blk00000057  (
    .CI(\blk0000001a/sig00000089 ),
    .LI(\blk0000001a/sig0000008a ),
    .O(sig00000014)
  );
  MUXCY   \blk0000001a/blk00000056  (
    .CI(\blk0000001a/sig00000089 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [19]),
    .S(\blk0000001a/sig0000008a ),
    .O(\blk0000001a/sig0000008b )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000055  (
    .I0(pinc_in[19]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [19]),
    .O(\blk0000001a/sig0000008a )
  );
  XORCY   \blk0000001a/blk00000054  (
    .CI(\blk0000001a/sig00000087 ),
    .LI(\blk0000001a/sig00000088 ),
    .O(sig00000013)
  );
  MUXCY   \blk0000001a/blk00000053  (
    .CI(\blk0000001a/sig00000087 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [18]),
    .S(\blk0000001a/sig00000088 ),
    .O(\blk0000001a/sig00000089 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000052  (
    .I0(pinc_in[18]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [18]),
    .O(\blk0000001a/sig00000088 )
  );
  XORCY   \blk0000001a/blk00000051  (
    .CI(\blk0000001a/sig00000085 ),
    .LI(\blk0000001a/sig00000086 ),
    .O(sig00000012)
  );
  MUXCY   \blk0000001a/blk00000050  (
    .CI(\blk0000001a/sig00000085 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [17]),
    .S(\blk0000001a/sig00000086 ),
    .O(\blk0000001a/sig00000087 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk0000004f  (
    .I0(pinc_in[17]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [17]),
    .O(\blk0000001a/sig00000086 )
  );
  XORCY   \blk0000001a/blk0000004e  (
    .CI(\blk0000001a/sig00000083 ),
    .LI(\blk0000001a/sig00000084 ),
    .O(sig00000011)
  );
  MUXCY   \blk0000001a/blk0000004d  (
    .CI(\blk0000001a/sig00000083 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [16]),
    .S(\blk0000001a/sig00000084 ),
    .O(\blk0000001a/sig00000085 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk0000004c  (
    .I0(pinc_in[16]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [16]),
    .O(\blk0000001a/sig00000084 )
  );
  XORCY   \blk0000001a/blk0000004b  (
    .CI(\blk0000001a/sig00000081 ),
    .LI(\blk0000001a/sig00000082 ),
    .O(sig00000010)
  );
  MUXCY   \blk0000001a/blk0000004a  (
    .CI(\blk0000001a/sig00000081 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [15]),
    .S(\blk0000001a/sig00000082 ),
    .O(\blk0000001a/sig00000083 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000049  (
    .I0(pinc_in[15]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [15]),
    .O(\blk0000001a/sig00000082 )
  );
  XORCY   \blk0000001a/blk00000048  (
    .CI(\blk0000001a/sig0000007f ),
    .LI(\blk0000001a/sig00000080 ),
    .O(sig0000000f)
  );
  MUXCY   \blk0000001a/blk00000047  (
    .CI(\blk0000001a/sig0000007f ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [14]),
    .S(\blk0000001a/sig00000080 ),
    .O(\blk0000001a/sig00000081 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000046  (
    .I0(pinc_in[14]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [14]),
    .O(\blk0000001a/sig00000080 )
  );
  XORCY   \blk0000001a/blk00000045  (
    .CI(\blk0000001a/sig0000007d ),
    .LI(\blk0000001a/sig0000007e ),
    .O(sig0000000e)
  );
  MUXCY   \blk0000001a/blk00000044  (
    .CI(\blk0000001a/sig0000007d ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [13]),
    .S(\blk0000001a/sig0000007e ),
    .O(\blk0000001a/sig0000007f )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000043  (
    .I0(pinc_in[13]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [13]),
    .O(\blk0000001a/sig0000007e )
  );
  XORCY   \blk0000001a/blk00000042  (
    .CI(\blk0000001a/sig0000007b ),
    .LI(\blk0000001a/sig0000007c ),
    .O(sig0000000d)
  );
  MUXCY   \blk0000001a/blk00000041  (
    .CI(\blk0000001a/sig0000007b ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [12]),
    .S(\blk0000001a/sig0000007c ),
    .O(\blk0000001a/sig0000007d )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000040  (
    .I0(pinc_in[12]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [12]),
    .O(\blk0000001a/sig0000007c )
  );
  XORCY   \blk0000001a/blk0000003f  (
    .CI(\blk0000001a/sig00000079 ),
    .LI(\blk0000001a/sig0000007a ),
    .O(sig0000000c)
  );
  MUXCY   \blk0000001a/blk0000003e  (
    .CI(\blk0000001a/sig00000079 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [11]),
    .S(\blk0000001a/sig0000007a ),
    .O(\blk0000001a/sig0000007b )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk0000003d  (
    .I0(pinc_in[11]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [11]),
    .O(\blk0000001a/sig0000007a )
  );
  XORCY   \blk0000001a/blk0000003c  (
    .CI(\blk0000001a/sig00000077 ),
    .LI(\blk0000001a/sig00000078 ),
    .O(sig0000000b)
  );
  MUXCY   \blk0000001a/blk0000003b  (
    .CI(\blk0000001a/sig00000077 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [10]),
    .S(\blk0000001a/sig00000078 ),
    .O(\blk0000001a/sig00000079 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk0000003a  (
    .I0(pinc_in[10]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [10]),
    .O(\blk0000001a/sig00000078 )
  );
  XORCY   \blk0000001a/blk00000039  (
    .CI(\blk0000001a/sig00000075 ),
    .LI(\blk0000001a/sig00000076 ),
    .O(sig0000000a)
  );
  MUXCY   \blk0000001a/blk00000038  (
    .CI(\blk0000001a/sig00000075 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [9]),
    .S(\blk0000001a/sig00000076 ),
    .O(\blk0000001a/sig00000077 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000037  (
    .I0(pinc_in[9]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [9]),
    .O(\blk0000001a/sig00000076 )
  );
  XORCY   \blk0000001a/blk00000036  (
    .CI(\blk0000001a/sig00000073 ),
    .LI(\blk0000001a/sig00000074 ),
    .O(sig00000009)
  );
  MUXCY   \blk0000001a/blk00000035  (
    .CI(\blk0000001a/sig00000073 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [8]),
    .S(\blk0000001a/sig00000074 ),
    .O(\blk0000001a/sig00000075 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000034  (
    .I0(pinc_in[8]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [8]),
    .O(\blk0000001a/sig00000074 )
  );
  XORCY   \blk0000001a/blk00000033  (
    .CI(\blk0000001a/sig00000071 ),
    .LI(\blk0000001a/sig00000072 ),
    .O(sig00000008)
  );
  MUXCY   \blk0000001a/blk00000032  (
    .CI(\blk0000001a/sig00000071 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [7]),
    .S(\blk0000001a/sig00000072 ),
    .O(\blk0000001a/sig00000073 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000031  (
    .I0(pinc_in[7]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [7]),
    .O(\blk0000001a/sig00000072 )
  );
  XORCY   \blk0000001a/blk00000030  (
    .CI(\blk0000001a/sig0000006f ),
    .LI(\blk0000001a/sig00000070 ),
    .O(sig00000007)
  );
  MUXCY   \blk0000001a/blk0000002f  (
    .CI(\blk0000001a/sig0000006f ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [6]),
    .S(\blk0000001a/sig00000070 ),
    .O(\blk0000001a/sig00000071 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk0000002e  (
    .I0(pinc_in[6]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [6]),
    .O(\blk0000001a/sig00000070 )
  );
  XORCY   \blk0000001a/blk0000002d  (
    .CI(\blk0000001a/sig0000006d ),
    .LI(\blk0000001a/sig0000006e ),
    .O(sig00000006)
  );
  MUXCY   \blk0000001a/blk0000002c  (
    .CI(\blk0000001a/sig0000006d ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [5]),
    .S(\blk0000001a/sig0000006e ),
    .O(\blk0000001a/sig0000006f )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk0000002b  (
    .I0(pinc_in[5]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [5]),
    .O(\blk0000001a/sig0000006e )
  );
  XORCY   \blk0000001a/blk0000002a  (
    .CI(\blk0000001a/sig0000006b ),
    .LI(\blk0000001a/sig0000006c ),
    .O(sig00000005)
  );
  MUXCY   \blk0000001a/blk00000029  (
    .CI(\blk0000001a/sig0000006b ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [4]),
    .S(\blk0000001a/sig0000006c ),
    .O(\blk0000001a/sig0000006d )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000028  (
    .I0(pinc_in[4]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [4]),
    .O(\blk0000001a/sig0000006c )
  );
  XORCY   \blk0000001a/blk00000027  (
    .CI(\blk0000001a/sig00000069 ),
    .LI(\blk0000001a/sig0000006a ),
    .O(sig00000004)
  );
  MUXCY   \blk0000001a/blk00000026  (
    .CI(\blk0000001a/sig00000069 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [3]),
    .S(\blk0000001a/sig0000006a ),
    .O(\blk0000001a/sig0000006b )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000025  (
    .I0(pinc_in[3]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [3]),
    .O(\blk0000001a/sig0000006a )
  );
  XORCY   \blk0000001a/blk00000024  (
    .CI(\blk0000001a/sig00000067 ),
    .LI(\blk0000001a/sig00000068 ),
    .O(sig00000003)
  );
  MUXCY   \blk0000001a/blk00000023  (
    .CI(\blk0000001a/sig00000067 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [2]),
    .S(\blk0000001a/sig00000068 ),
    .O(\blk0000001a/sig00000069 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk00000022  (
    .I0(pinc_in[2]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [2]),
    .O(\blk0000001a/sig00000068 )
  );
  XORCY   \blk0000001a/blk00000021  (
    .CI(\blk0000001a/sig00000065 ),
    .LI(\blk0000001a/sig00000066 ),
    .O(sig00000002)
  );
  MUXCY   \blk0000001a/blk00000020  (
    .CI(\blk0000001a/sig00000065 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [1]),
    .S(\blk0000001a/sig00000066 ),
    .O(\blk0000001a/sig00000067 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk0000001f  (
    .I0(pinc_in[1]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [1]),
    .O(\blk0000001a/sig00000066 )
  );
  XORCY   \blk0000001a/blk0000001e  (
    .CI(\blk0000001a/sig00000063 ),
    .LI(\blk0000001a/sig00000064 ),
    .O(sig00000001)
  );
  MUXCY   \blk0000001a/blk0000001d  (
    .CI(\blk0000001a/sig00000063 ),
    .DI(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [0]),
    .S(\blk0000001a/sig00000064 ),
    .O(\blk0000001a/sig00000065 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk0000001a/blk0000001c  (
    .I0(pinc_in[0]),
    .I1(\NlwRenamedSig_OI_U0/i_synth/I_PHASEGEN.i_accum/i_fabric.i_common.i_phase_acc/opt_has_pipe.first_q [0]),
    .O(\blk0000001a/sig00000064 )
  );
  GND   \blk0000001a/blk0000001b  (
    .G(\blk0000001a/sig00000063 )
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
