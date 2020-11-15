`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/05 14:35:00
// Design Name: 
// Module Name: RTC
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


module RTC(
    clk,
    rst_n,
    sda,
    scl,
    dtube_cs_n,
    dtube_data	

    );
    input clk;		
	input rst_n;			
    output scl;
    inout sda;
	output [3:0] dtube_cs_n;
	output [6:0] dtube_data;
     wire [15:0] dis_data;

     
     
     right_time u1(
    .clk(clk),
	.rst_n(rst_n),
	.sda(sda),
	.scl(scl),
    .right_time(dis_data)
    );
    
     seg_dis u2(
     .clk(clk),
     .rst_n(rst_n),
     .dis_data(dis_data),
     .dtube_cs_n(dtube_cs_n),
     .dtube_data(dtube_data)	
		);
   
endmodule