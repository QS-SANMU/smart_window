// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Sat Nov 14 16:56:26 2020
// Host        : PC-20181004GSVN running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               D:/jk/chuan_new/chuan_new.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_100m, clk_vga, clk_50m, xclk, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_100m,clk_vga,clk_50m,xclk,clk_in1" */;
  output clk_100m;
  output clk_vga;
  output clk_50m;
  output xclk;
  input clk_in1;
endmodule
