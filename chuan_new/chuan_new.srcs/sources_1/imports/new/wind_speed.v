`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/05 14:35:29
// Design Name: 
// Module Name: wind_speed
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

 module wind_speed(
    clk,
    rst_n,
    scl,
    sda,
    window_down,
    wind_speed
    );
    input clk;
    input rst_n;
    output scl;
    inout sda;
    output window_down;
    output [4:0]wind_speed;

    wire [7:0] data;     
    data_judge u1(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data),
    .window_down(window_down),
    .wind_speed(wind_speed)
    );
    
    ad_data_rd u2(
	.clk(clk),
	.rst_n(rst_n),
	.SCL(scl),
	.SDA(sda),
	.AD_DATA(data),
	.tx_start()
	);
	
	
endmodule
