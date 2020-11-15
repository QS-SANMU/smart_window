`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/20 16:21:09
// Design Name: 
// Module Name: connect
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


module connect(
input clk,
input ce,
input d,
output q1,
output q2//一列三行，其中两行由shift_ram产生
    );
    c_shift_ram_2 c1(
    .D(d),
    .CLK(clk),
    .CE(ce),
    .Q(q1)
    );
    
    c_shift_ram_3 c2(
    .D(q1),
    .CLK(clk),
    .CE(ce),
    .Q(q2)
    );
endmodule
