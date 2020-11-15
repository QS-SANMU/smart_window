`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/07 00:47:11
// Design Name: 
// Module Name: uart_dis_top
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

module uart_dis_top(
//clk,
clk_50M,
clk_25M,
rst_n,data,serial_data_tx,serial_data_rx,massage,call,window_L,window_R,curtain_1,curtain_2

    );
    
   input clk_50M;
   input clk_25M;
  //  input clk;
    input rst_n;
    inout data;
    input serial_data_rx;
    output serial_data_tx;
    output [1:0]massage;     //�㳡����Լ
	output [3:0]call;     //��绰
	output [3:0]window_L;    //�󴰻�
	output [3:0]window_R;    //�Ҵ���
	output [2:0]curtain_1;   //���Ҵ���
	output [2:0]curtain_2;   //��������
	
    
    
    
    
    wire clk;
    wire clk_50M;
    wire clk_25M;
    
    
    top_uart_dis_rx u1(
    .clk_50M(clk_50M),
	.rst_n(rst_n),
	.uart_data_rx(serial_data_rx),
	.massage(massage),     //�㳡����Լ
	.call(call),        //��绰
	.window_L(window_L),    //�󴰻�
	.window_R(window_R),    //�Ҵ���
	.curtain_1(curtain_1),   //���Ҵ���
    .curtain_2(curtain_2)    //��������
	
    );
	
	top_uart_dis_tx u2(
     .clk_50M(clk_50M),
     .clk_25M(clk_25M),
     .rst_n(rst_n),
     .serial_data_tx(serial_data_tx),
     .data(data)
    );
  /*
    clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(clk_50M),     // output clk_out1
    .clk_out2(clk_25M),     // output clk_out2
    // Status and control signals
    .reset(!rst_n), // input reset
    .locked(),       // output locked
   // Clock in ports
    .clk_in1(clk));      // input clk_in1
// INST_TAG_END ------ End INSTANTIATION Template ---------
*/
endmodule
