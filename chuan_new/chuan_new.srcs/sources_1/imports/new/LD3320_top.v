`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/07 19:51:45
// Design Name: 
// Module Name: LD3320_top
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


module LD3320_top(
    clk,
    rst_n,
    rs232_rx,
    LD3320_cmds,
    send_en_1,
    cmd_end
    

    );
    input clk;
    input rst_n;
    input rs232_rx;
    input cmd_end;

    output [3:0]LD3320_cmds;
    output send_en_1;
    
    wire rx_done;
    wire [7:0]dout;
    
    uart_rx U1(
	.clk(clk),
	.rst_n(rst_n),
	.rs232_rx(rs232_rx),
	.rx_done(rx_done),
	.dout(dout)
		
    );
	
LD3320_cmds U2(
	.clk(clk),
	.rst_n(rst_n),
	.rx_done(rx_done),
	.data(dout),
	.cmds(LD3320_cmds),
	.cmd_end(cmd_end)
//	.send_en(send_en)
    );
    
 send_en U3(
    .clk(clk),
    .rst_n(rst_n),
    .rx_done(rx_done),
    .send_en(send_en_1)

    );
endmodule
