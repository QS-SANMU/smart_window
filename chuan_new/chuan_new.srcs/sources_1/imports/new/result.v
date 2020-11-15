`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/24 14:49:29
// Design Name: 
// Module Name: result
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


module result(
input [31:0]gravity0,
input [31:0]gravity1,
output fall
    );
    parameter [31:0]value = 700;
    assign fall = (gravity0 > gravity1) ? (((gravity0 - gravity1) > value) ? 1'b1 : 1'b0) : 1'b0;
endmodule
