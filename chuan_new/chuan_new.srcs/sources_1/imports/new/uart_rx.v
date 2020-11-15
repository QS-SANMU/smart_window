`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 13:59:18
// Design Name: 
// Module Name: UART_RX
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

module UART_RX_1(
	input clk,
	input rst,
	input data_rx,
	output tx_en,
	output [7:0] rx_data
    );

	wire rx_en;
	wire rx_sel_data;
	wire [3:0] rx_num;

	bps_rx u1(
	.clk(clk),
	.rst(rst),
	.rx_en(rx_en),
	
	.rx_sel_data(rx_sel_data),   //波特率的计数的中心点（采集数据的使能信号）
	.rx_num(rx_num)   //一帧数据0~9
    );
	
	rx u2(
	.clk(clk),
	.rst(rst),
	.data_rx(data_rx),
	.rx_num(rx_num),
	.rx_sel_data(rx_sel_data),
	
	.rx_en(rx_en),
	.tx_en(tx_en),
	.rx_data(rx_data)
    );

endmodule
