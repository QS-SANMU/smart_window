`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/01 10:42:16
// Design Name: 
// Module Name: connect_s
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


module connect_s(
input [3:0]d,
input clk,
input ce,
output [3:0]q1,
output [3:0]q2
    );
    c_shift_ram_8 c1(
    .D(d),
    .CLK(clk),
    .CE(ce),
    .Q(q1)
    );
    
    c_shift_ram_9 c2(
        .D(q1),
        .CLK(clk),
        .CE(ce),
        .Q(q2)
        );
endmodule