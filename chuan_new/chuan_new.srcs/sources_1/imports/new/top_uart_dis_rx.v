`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/06 23:55:23
// Design Name: 
// Module Name: top_uart_dis_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_uart_dis_rx(
    input clk_50M,
	input rst_n,
	input uart_data_rx,
	output [1:0]massage,     //广场舞邀约
	output [3:0]call,        //打电话
	output [3:0]window_L,    //左窗户
	output [3:0]window_R,    //右窗户
	output [2:0]curtain_1,   //卧室窗帘
	output [2:0]curtain_2    //客厅窗户
	
    );
	
	
	wire [7:0]parallel_data_rx;
	wire rx_down;

uart_display_rx  u1(
   .clk(clk_50M),
    .rst_n(rst_n), 
   .rx_data(uart_data_rx),
   .po_data(parallel_data_rx),
   .rx_down(rx_down)
);
 
rx_judge u2(
    .clk(clk_50M),
	.rst_n(rst_n),
	.parallel_data_rx(parallel_data_rx),
	.rx_down(rx_down),
	.call(call),
	.window_L(window_L),
	.window_R(window_R),
	.curtain_1(curtain_1),
	.curtain_2(curtain_2),
	.massage(massage)
);


endmodule
