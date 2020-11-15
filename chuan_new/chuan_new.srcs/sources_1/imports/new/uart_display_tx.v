`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/07 00:37:43
// Design Name: 
// Module Name: uart_display_tx
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

/*
module uart_display_tx( clk,rst_n,data_byte,send_en,rs232_tx,tx_done,uart_state
    );
  input clk;
  input rst_n;
  input send_en;
  input [7:0]data_byte;
  
  output reg rs232_tx;
  output reg tx_done;
  output reg uart_state;
  
  reg [16:0]div_cnt;
  reg bps_clk;
  reg [3:0]bps_cnt;
  reg [7:0]r_data_byte;
  
//��Ƶ������
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
  
//��Ƶʱ��
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  bps_clk<=1'b0;
  else if(div_cnt==16'd1)
  bps_clk<=1'b1;
  else
  bps_clk<=1'b0;
  
//��Ƶ����
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  bps_cnt<=4'd0;
  else if(tx_done)
  bps_cnt<=4'd0;
  else if(bps_clk)
  bps_cnt<=bps_cnt+1'b1;
  else
  bps_cnt<=bps_cnt;
  
//�Ĵ����洢���͵�����
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  r_data_byte<=8'd0;
  else if(send_en)
  r_data_byte<=data_byte;
  else
  r_data_byte<=r_data_byte;
  
//���ݷ���ģ��
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

//һ�η������
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  tx_done<=1'b0;
  else if(bps_cnt==4'd10)
   tx_done<=1'b1;
	else
	tx_done<=1'b0;
		
//����״̬
  always@(posedge clk or negedge rst_n)
  if(!rst_n)
  uart_state<=1'b0;
  else if(send_en)
  uart_state<=1'b1;
  else if(tx_done)
  uart_state<=1'b0;
  else
  uart_state<=uart_state;

  

endmodule

*/

module uart_display_tx(
    input clk,      //ϵͳʱ���ź�
	input rst_n,    //��λ�ź�
	input send_en,     //����ʹ���ź�
	input [7:0] date_byte,    //�����͵ĵ����ֽڣ����У�
	output reg serial_data_tx,     //���͵Ĵ�������
	output reg tx_down      //һ���ֽڷ�������ź�
	);
	reg uart_state;    // ����״̬
	reg[12:0]bps_count;  //���������ʵļ�����
	reg bps_clk;     //�������ź�
	reg[3:0] uart_count;  //����λ��������10λ��
	//reg [7:0] reserve_date_byte;   //���汻���͵Ĳ�������
	parameter BPSBPS=16'd5207;////////////////////////////////////////////////////////////////////////////////////////////////
	//parameter BPSBPS=13'd5;
	//���汻���͵Ĳ�������
	//always@(posedge clk or negedge rst_n)
	//begin
	//if(!rst_n)
		//reserve_date_byte<=8'd0;
	//else if(send_en)
		//reserve_date_byte<=date_byte;
	//else
		//reserve_date_byte<=reserve_date_byte;
	//end
	//����״̬ȷ��
	always@(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
	uart_state<=4'b0;
	else if(send_en)
	uart_state<=1'b1;
	else if(tx_down == 1'b1 || send_en == 1'b0)
	uart_state<=1'b0;
	else
	uart_state<=uart_state;
	end
	//��Ƶ����ģ�飨9600bps��
	always@(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
		bps_count<=16'd0;
	else if(uart_state==1'b1)
	begin
		if(bps_count==BPSBPS)
			bps_count<=16'd0;
		else
			bps_count<=bps_count+1'b1;
	end
	else
		bps_count<=16'd0;
	end
		
	// �������źŲ���ģ��
	always@(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
		bps_clk<=1'b0;
	else if(bps_count==16'd1)
		bps_clk<=1'b1;
	else
		bps_clk<=1'b0;
	end
	
	// ����λ��������ѡ��
	always@(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
		uart_count<=4'b0;
	else if(uart_count==4'd11)       //��������8λ+��ʼλ+ֹͣλ����10λ��ȥ��0����1~10
		uart_count<=4'b0;
	else if(bps_clk)
		uart_count<=uart_count+1'b1;
	else
		uart_count<=uart_count;
	end
	// ���ֽڷ�������ź�
	always@(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
		tx_down<=1'b0;
	else if(uart_count==4'd11)
		tx_down<=1'b1;
	else
		tx_down<=1'b0;
	end
	//��������
	always@(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
		serial_data_tx<=1'b1;////////////////////////////////////////////////////////////////////////////////////
	else
	begin
		case(uart_count)
		4'b0000:serial_data_tx<=1'b1;
		4'b0001:serial_data_tx<=1'b0;
		4'b0010:serial_data_tx<=date_byte[0];
		4'b0011:serial_data_tx<=date_byte[1];
		4'b0100:serial_data_tx<=date_byte[2];
		4'b0101:serial_data_tx<=date_byte[3];
		4'b0110:serial_data_tx<=date_byte[4];
		4'b0111:serial_data_tx<=date_byte[5];
		4'b1000:serial_data_tx<=date_byte[6];
		4'b1001:serial_data_tx<=date_byte[7];
		4'b1010:serial_data_tx<=1'b1;
		default:serial_data_tx<=1'b1;
		endcase
	end
	end



endmodule



