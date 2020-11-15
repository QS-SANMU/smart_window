`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/07 07:06:14
// Design Name: 
// Module Name: door
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


module door(
clk,rst_n,pwm,open
    );

	input clk;  //100m
	input rst_n;
	input [1:0]open;
	output reg pwm;
	

	
	
	reg [23:0]cnt;
	wire pwm1;
	wire pwm2;
	reg [30:0]cnt_time;
	reg [3:0]cnt_sec;
	reg en;
	
//脉冲信号计数器	
always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			cnt<=24'd0;
	    else
		      begin
                  if(cnt==24'd1900000)
			         cnt<=24'd0;
		          else
			         cnt<=cnt+1;
	           end
	end
//1s时钟计数器	
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt_time<=31'd0;
    else if(en)
        begin
            if(cnt_time==31'd24999999)
                cnt_time<=31'd0;
            else
                 cnt_time<=cnt_time+1;
        end
    else
        cnt_time<=31'd0;
end

//10s计数器
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt_sec<=4'd0;
    else if(en)
        begin
            if(cnt_sec==4'd9)
                cnt_sec<=4'd0;
            else if(cnt_time==31'd24999999)
                 cnt_sec<=cnt_sec+1;
            else
                  cnt_sec<=cnt_sec;
        end
    else
        cnt_sec<=4'd0;
end
           
	
	
assign pwm1=(cnt>=24'd1&cnt<=24'd50000)?1:0;     //0.5ms,0度
assign pwm2=(cnt>=24'd1&cnt<=24'd140000)?1:0;     //1.4ms,

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        pwm<=pwm1;
     else if(open==2'b10)
        pwm<=pwm2;
      else if(en)
        pwm<=pwm;
      else 
       pwm<=pwm1;
 end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        en<=0;
     else if(open==2'b10)
         en<=1;
     else if(cnt_sec==4'd9) 
        en<=0;
     else 
        en<=en;
end
endmodule
