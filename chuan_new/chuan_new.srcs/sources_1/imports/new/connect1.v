`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/20 16:26:19
// Design Name: 
// Module Name: connect1
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


module connect1(
input clk,
input ce,
input d,
output q1,
output q2//һ�����У�����������shift_ram����
    );
    c_shift_ram_0 c1(
    .D(d),
    .CLK(clk),
    .CE(ce),
    .Q(q1)
    );
    
    c_shift_ram_1 c2(
    .D(q1),
    .CLK(clk),
    .CE(ce),
    .Q(q2)
    );
endmodule
