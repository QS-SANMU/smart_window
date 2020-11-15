`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 14:08:00
// Design Name: 
// Module Name: uart_tx_continuously_cmd_3
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


module uart_tx_continuously_cmd_3(
	input clk,
	input rst,
	input tx_start,
	output tx_data
    );
	
	wire [7:0] data;
	wire en;
	wire tx_done;

	
	
	TX u1(
    .clk(clk),
    .rst(rst),
    .tx_data(data),
    .tx_en(en),
	.tx_done(tx_done),
    .data_out(tx_data)
    );
	
	
	tx_contr_cmd_3 u2(
	.clk(clk),
	.rst(rst),
	.tx_start(tx_start),
	.tx_done(tx_done),
	.tx_en(en),
	.data_out(data)
    );

endmodule

