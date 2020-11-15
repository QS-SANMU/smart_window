`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/28 19:42:29
// Design Name: 
// Module Name: connect3
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


module connect3(
input [3:0]d,
input clk,
input ce,
output [3:0]q1,
output [3:0]q2
    );
    c_shift_ram_6 c1(
    .D(d),
    .CLK(clk),
    .CE(ce),
    .Q(q1)
    );
    
    c_shift_ram_7 c2(
        .D(q1),
        .CLK(clk),
        .CE(ce),
        .Q(q2)
        );
endmodule
