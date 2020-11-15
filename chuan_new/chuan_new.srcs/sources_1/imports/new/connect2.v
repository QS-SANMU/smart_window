`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/24 21:01:38
// Design Name: 
// Module Name: connect2
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


module connect2(
input clk,
input ce,
input d,
output q1,
output q2//一列三行，其中两行由shift_ram产生
    );
    c_shift_ram_4 c1(
    .D(d),
    .CLK(clk),
    .CE(ce),
    .Q(q1)
    );
    
    c_shift_ram_5 c2(
    .D(q1),
    .CLK(clk),
    .CE(ce),
    .Q(q2)
    );
endmodule
