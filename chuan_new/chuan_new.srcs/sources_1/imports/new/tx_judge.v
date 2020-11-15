`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:56:16 11/03/2020 
// Design Name: 
// Module Name:    tx_judge 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module tx_judge(
   clk,
   rst_n,
   temperature_data,
   humidity_data,
   data_byte,
   send_en,
   tx_down
   
    );
input clk ;
input rst_n;
input [7:0]temperature_data;
input [7:0]humidity_data;
input tx_down;
output reg send_en;
output reg [7:0]data_byte;

//reg stop_flag;
reg flag_1;
//reg flag_2;
reg [4:0]cnt_1;
reg [3:0]cnt_2;
reg[7:0]r_temperature_data;

//温度寄存器产生计数器cnt1始能信号
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	   r_temperature_data <= 'd0;
	else// if (temperature_data)
	    r_temperature_data <= temperature_data;
	//else
	  // r_temperature_data <= r_temperature_data;
	   
end

//产生cnt--1始能信号
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	   flag_1 <= 'd0;
	else if (temperature_data ^ r_temperature_data)
	   flag_1 <= 'd1;
	else if(cnt_1 == 5'd15 && tx_down == 1'b1)
	   flag_1 <= 'd0;
	else
	   flag_1 <= flag_1;
end

//产生cnt2使能信号
/*always@(posedge clk or negedge rst_n)
begin
   if(!rst_n)
     flag_2 <= 'd0;
	else if(cnt_1 == 'd7)
	  flag_2 <= 'd1;
	else if(cnt_2 == 'd8)
	  flag_2 <= 'd0;
	else 
	  flag_2 <= flag_2;
end*/

//产生计数器cnt1
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	   cnt_1 <= 'd0;
	else if(cnt_1 == 5'd15 && tx_down == 1'b1)
	   cnt_1 <= 'd0;
	else if(flag_1 == 1'b1 && tx_down == 1'b1)/////////////////////////////////////////////////错
	   cnt_1 <= cnt_1 + 1'b1;
end

//产生计数器cnt2
/*always@(posedge clk or negedge rst_n)
begin
   if(!rst_n)
      cnt_2 <= 4'd0;
	else if(cnt_2 == 'd8)
	  cnt_2 <= 'd0;
	else if(flag_2)
	  cnt_2 <= cnt_2 + 1'b1;
	else
	  cnt_2 <= 'd0;
end*/

// 产生send--en结束始能信号
/*always@(posedge clk or negedge rst_n)
begin
   if(!rst_n)
      stop_flag <= 'd0;
	//else if(flag_2 & cnt_2== 'd8)
	else if(cnt_1 == 'd15 && tx_down == 1'b1)
	  stop_flag <= 'd1;
	else
	  stop_flag <= 'd0;
end*/


 //产生send--en信号
 always@(posedge clk or negedge rst_n)
 begin
    if(!rst_n)
	   send_en <= 'd0;
	 //else if(cnt_1 == 'd1)
	 else if(cnt_1 == 'd15 && tx_down == 1'b1)
             send_en <= 'd0;
	 else if(flag_1 == 1'b1)
	    send_en <= 'd1;
	else 
	    send_en <= send_en;
 end
 
 
always@(posedge clk or negedge rst_n)
begin
   if(!rst_n)
     begin
	    data_byte <= 'd0;
	 end
   else if(flag_1)
     begin
	    case (cnt_1)
		5'd0: data_byte <= 8'hA5;
		5'd1: data_byte <= 8'h5A;
		5'd2: data_byte <= 8'h05;
		5'd3: data_byte <= 8'h82;
		5'd4: data_byte <= 8'h10;
		5'd5: data_byte <= 8'h00;
		5'd6: data_byte <= 8'h00;
		5'd7: data_byte <= temperature_data;
		5'd8: data_byte <= 8'hA5;
        5'd9: data_byte <= 8'h5A;
        5'd10: data_byte <= 8'h05;
        5'd11: data_byte <= 8'h82;
        5'd12: data_byte <= 8'h20;
        5'd13: data_byte <= 8'h00;
        5'd14: data_byte <= 8'h00;
        5'd15: data_byte <= humidity_data;
		default :data_byte <= 8'h0;
		endcase
	 end	
	/*else if( flag_2)
	  begin
		case (cnt_2)
		4'd1: data_byte <= 8'hA5;
		4'd2: data_byte <= 8'h5A;
		4'd3: data_byte <= 8'h05;
		4'd4: data_byte <= 8'h82;
		4'd5: data_byte <= 8'h20;
		4'd6: data_byte <= 8'h00;
		4'd7: data_byte <= 8'h00;
		4'd8: data_byte <= humidity_data;
		default : data_byte <= 8'h0;
		endcase
	  end*/
	 else data_byte <= 8'd0;
end

endmodule