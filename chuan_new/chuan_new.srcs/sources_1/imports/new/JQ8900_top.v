`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/09 18:11:59
// Design Name: 
// Module Name: JQ8900_top
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


module JQ8900_TOP(clk,rst_n,rs232_tx,cmds,send_en_1,send_en_2,cmd_end
    );
	input clk;
	input rst_n;
	input send_en_1;    //LD3320µÄsend_en;
	input send_en_2;//senser
	
	
	output  rs232_tx;
	output cmd_end;
	input  [4:0]cmds;///////////////////////////////////////////////////////////////////////////////
	
	wire [7:0]data;
	wire tx_done;
	wire uart_state;
	wire cmd_end;
	wire rx_done;
	wire send_en;

	
assign send_en=(send_en_1 | send_en_2);

JQ8900_uart_tx U1( 
	.clk            (clk),
	.rst_n         (rst_n),
	.data_byte    (data),
	.send_en       (send_en),
	.rs232_tx      (rs232_tx),
	.tx_done      (tx_done),
	.uart_state    (uart_state),
	.cmd_end        (cmd_end)
    );
	
JQ8900_cmds U2(
	.clk          (clk) ,
	.rst_n      (rst_n) ,
	.uart_state    (uart_state) ,
	.tx_done    (tx_done) ,
	.cmds       (cmds) ,
	.data       (data) ,
	.cmd_end    (cmd_end)
    );
/*	
uart_rx U3(
	.clk(clk),
	.rst_n(rst_n),
	.rs232_rx(rs232_rx),
	.rx_done(rx_done),
	.dout(dout)
		
    );
	
LD3320_cmds U4(
	.clk(clk),
	.rst_n(rst_n),
	.rx_done(rx_done),
	.data(dout),
	.cmds(cmds)
//	.send_en(send_en)
    );
    
 send_en U5(
    .clk(clk),
    .rst_n(rst_n),
    .rx_done(rx_done),
    .send_en(send_en)

    );
 */

endmodule
