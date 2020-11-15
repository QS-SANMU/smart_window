`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 14:03:07
// Design Name: 
// Module Name: top
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


module finger(
	input clk,
	input rst,
	input data_in,	
	output led,
	output data_out
	);
	
	wire cmd_1 ;
	wire cmd_2 ;
	wire cmd_3 ;
	wire rx_cmd_1_yes;
	wire rx_cmd_2_yes;
	wire rx_cmd_3_yes;
	wire rx_cmd_1_no;
	wire rx_cmd_2_no;
	wire rx_cmd_3_no;
	
	wire check_ok ;
	wire check_no ;
	
	wire [3:0] state;
	
	wire rx_done;
	wire [7:0] data;
	
	
	reg [1:0] led_1;
		
	always@(posedge clk or negedge rst)
	if(!rst)
	   
		led_1 <= 2'b00;
	else if(check_ok)	
		led_1 <= 2'b10;
	else if(check_no)
		led_1 <= 2'b01;
	else
		led_1 <= led_1;;
		
	assign led = led_1;
	
	

	
	cmd_sel u1(
	.clk(clk),
	.rst(rst),
	.cmd_1(cmd_1),
	.cmd_2(cmd_2),
	.cmd_3(cmd_3),
	.data_out(data_out)
    );
	
	cmd_center u2(
	.clk(clk),
	.rst(rst),
	.rx_cmd_1_yes(rx_cmd_1_yes),
	.rx_cmd_2_yes(rx_cmd_2_yes),
	.rx_cmd_3_yes(rx_cmd_3_yes),
	.rx_cmd_1_no(rx_cmd_1_no),
	.rx_cmd_2_no(rx_cmd_2_no),
	.rx_cmd_3_no(rx_cmd_3_no),
	.cmd_1(cmd_1),
	.cmd_2(cmd_2),
	.cmd_3(cmd_3),
	.check_ok(check_ok),
	.check_no(check_no),
	.state(state)
    );
	
	data_rx u3(
	.clk(clk),
	.rst(rst),
	.rx_done(rx_done),
	.data_in(data),
	.state(state),
	.rx_cmd_1_yes(rx_cmd_1_yes),
	.rx_cmd_2_yes(rx_cmd_2_yes),
	.rx_cmd_3_yes(rx_cmd_3_yes),
	.rx_cmd_1_no(rx_cmd_1_no),
	.rx_cmd_2_no(rx_cmd_2_no),
	.rx_cmd_3_no(rx_cmd_3_no)
    );
	
	UART_RX_1 u4(
	.clk(clk),
	.rst(rst),
	.data_rx(data_in),
	.tx_en(rx_done),
	.rx_data(data)
    );
	

endmodule
