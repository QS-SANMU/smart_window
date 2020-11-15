`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 14:02:08
// Design Name: 
// Module Name: rx
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


module rx(
	input clk,
	input rst,
	input data_rx,
	input [3:0] rx_num,
	input rx_sel_data,
	
	output rx_en,
	output reg tx_en,
	output reg [7:0] rx_data
    );

	reg in_1,in_2;
	always@(posedge clk or negedge rst)
	if(!rst)
		begin
			in_1 <= 1;
			in_2 <= 1;
		end
	else
		begin
			in_1 <= data_rx;
			in_2 <= in_1;
		end

	assign rx_en = in_2 & (~in_1);
	
	reg [7:0] temp_rx_data;
	always@(posedge clk or negedge rst)
	if(!rst)
		begin
			temp_rx_data <= 0;
			rx_data <= 0;
		end
	else if(rx_sel_data)
		case(rx_num)
			0 : ;           //忽略开始位
			1 : temp_rx_data[0] <= data_rx;
			2 : temp_rx_data[1] <= data_rx;
			3 : temp_rx_data[2] <= data_rx;
			4 : temp_rx_data[3] <= data_rx;
			5 : temp_rx_data[4] <= data_rx;
			6 : temp_rx_data[5] <= data_rx;
			7 : temp_rx_data[6] <= data_rx;
			8 : temp_rx_data[7] <= data_rx;
			9 : rx_data <= temp_rx_data;    //锁存采集的8位数据（忽略停止位）
	        default : ;
		endcase
	
	always@(posedge clk or negedge rst)
	if(!rst)
		tx_en <= 0;
	else if(rx_num == 9 && rx_sel_data)
		tx_en <= 1;
	else
		tx_en <= 0;
		
		
endmodule
