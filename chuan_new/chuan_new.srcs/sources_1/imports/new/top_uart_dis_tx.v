`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/07 00:30:50
// Design Name: 
// Module Name: top_uart_dis_tx
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


module top_uart_dis_tx(
input clk_50M,
input clk_25M,
    input rst_n,
    //input p,
    output wire serial_data_tx,
    output [7:0]temperature_data,
    inout data
    );
    
  //  wire clk_25M;
  //  wire clk_50M;
 wire tx_down;
 wire   temperature_int;
wire  humidity_int;
wire  send_en;
wire  [7:0]data_byte;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//wire temperature_data;
wire [7:0]humidity_data;
//wire tx_down;
//wire humidity_data;

tx_judge u1(
   .clk(clk_50M),
   .rst_n(rst_n),
   .temperature_data(temperature_data),
   .humidity_data(humidity_data),
   .data_byte(data_byte),
   .send_en(send_en),
   .tx_down(tx_down)
    );
	
uart_display_tx u2(
 .clk(clk_50M),      //ϵͳʱ���ź�
 .rst_n(rst_n),    //��λ�ź�
 .send_en(send_en),     //����ʹ���ź�
 .date_byte(data_byte),    //�����͵ĵ����ֽڣ����У�
 .serial_data_tx(serial_data_tx),     //���͵Ĵ�������
 .tx_down(tx_down)      //һ���ֽڷ�������ź�
 
);

/*press p1(
.clk50(clk_50M),
.rst_n(rst_n),
.data(temperature_data),
.p(p)
);*/

top_DHT11 u3 (
    .clk_25M(clk_25M),
    .clk_50M(clk_50M),
	.rst_n(rst_n),
	.data(data),
	.temperature_decade(),
	.humidity_decade(),
	.humidity_one(),
	.temperature_one(),
	.humidity_int(humidity_data),
	.temperature_int(temperature_data)
    );
      
   
endmodule