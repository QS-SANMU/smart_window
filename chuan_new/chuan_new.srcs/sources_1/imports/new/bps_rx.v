`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 14:01:23
// Design Name: 
// Module Name: bps_rx
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


module bps_rx(
	input clk,
	input rst,
	input rx_en,
	
	output reg rx_sel_data,   //波特率的计数的中心点（采集数据的使能信号）
	output reg [3:0] rx_num   //一帧数据0~9
    );
	
		
	parameter bps_div = 13'd867,
			  bps_div_2 = 13'd433;
	//parameter bps_div = 13'd433,
	//		  bps_div_2 = 13'd216;
			 
	reg flag;
	always@(posedge clk or negedge rst)
	if(!rst)
		flag <= 0;
	else if(rx_en)
		flag <= 1;
	else if(rx_num == 'd10)
		flag <= 0;
	else
		flag <= flag;
		
	
	reg [12:0] cnt;
    always@(posedge clk or negedge rst)
	if(!rst)
		cnt <= 0;
	else if(flag && cnt < bps_div)
		cnt <= cnt +1;
	else
		cnt <= 0;
		
	always@(posedge clk or negedge rst)
	if(!rst)
		rx_sel_data <= 0;
	else if(cnt == bps_div_2)
		rx_sel_data <= 1;
	else
		rx_sel_data <= 0;
		
	always@(posedge clk or negedge rst)
	if(!rst)
		rx_num <= 0;
	else if(rx_sel_data && flag)
		rx_num <= rx_num +1;
	else if(rx_num == 'd10)
		rx_num <= 0;
	

endmodule
