`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/08 17:54:02
// Design Name: 
// Module Name: uart_tx
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


module JQ8900_uart_tx( clk,rst_n,data_byte,send_en,rs232_tx,tx_done,uart_state,cmd_end
    );
  input clk;
  input rst_n;
  input send_en;
  input cmd_end;
  input [7:0]data_byte;
  
  output reg rs232_tx;
  output reg tx_done;
  output reg uart_state;
  
  reg [16:0]div_cnt;
  reg bps_clk;
  reg [3:0]bps_cnt;
  reg [7:0]r_data_byte;
 
  
//分频计数�?
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  div_cnt<=16'd0;
  else if(uart_state)begin
   if(div_cnt==16'd5207)
	   div_cnt<=16'd0;
		else 
		div_cnt<=div_cnt+1'b1;
		end
  else
          div_cnt<=16'd0;
  
//分频时钟
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  bps_clk<=1'b0;
  else if(div_cnt==16'd1)
  bps_clk<=1'b1;
  else
  bps_clk<=1'b0;
  
//分频计数
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  bps_cnt<=4'd0;
  else if(tx_done)
  bps_cnt<=4'd0;
  else if(bps_clk)
  bps_cnt<=bps_cnt+1'b1;
  else
  bps_cnt<=bps_cnt;
  
//寄存器存储发送的数据
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  r_data_byte<=8'd0;
  else if(send_en)
  r_data_byte<=data_byte;
  else
  r_data_byte<=r_data_byte;
  
//数据发�?�模�?
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  rs232_tx<=1'b1;
  else begin
  case(bps_cnt)
  0:rs232_tx<=1'b1;
  1:rs232_tx<=1'b0;
  2:rs232_tx<=r_data_byte[0];
  3:rs232_tx<=r_data_byte[1];
  4:rs232_tx<=r_data_byte[2];
  5:rs232_tx<=r_data_byte[3];
  6:rs232_tx<=r_data_byte[4];
  7:rs232_tx<=r_data_byte[5];
  8:rs232_tx<=r_data_byte[6];
  9:rs232_tx<=r_data_byte[7];
  10:rs232_tx<=1'b1;
  default:rs232_tx<=1'b1;
  endcase
 end

//�?次发送完�?
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  tx_done<=1'b0;
  else if(bps_cnt==4'd10)
   tx_done<=1'b1;
	else
	tx_done<=1'b0;
		
//串口状�??
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  uart_state<=1'b0;
  else if(cmd_end)
  uart_state<=1'b0;
  else if(send_en)
  uart_state<=1'b1;
  else
  uart_state<=uart_state;

  

endmodule

