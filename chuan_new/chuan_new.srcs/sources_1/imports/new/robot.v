`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/31 10:17:34
// Design Name: 
// Module Name: robot
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


module robot(clk,rst_n,down,pwm,dingous
    );

	input clk;
	input rst_n;
	input down;
	input dingous;
	output reg pwm;
	
	reg [30:0]cnt_time;
	reg [3:0]cnt_sec;
	
	reg [23:0]cnt;
	wire pwm1;
	wire pwm2;
	wire pwm3;
	wire pwm4;
	wire pwm5;
	wire pwm6;
	wire pwm7;
    wire pwm8;
	wire pwm9;
	wire pwm10;
	
	
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
    else if(down)
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
    else if(down)
        begin
            if(cnt_sec==4'd9)
                cnt_sec<=4'd9;
            else if(cnt_time==31'd24999999)
                 cnt_sec<=cnt_sec+1;
            else
                  cnt_sec<=cnt_sec;
        end
    else
        cnt_sec<=4'd0;
end
           
	
assign pwm1=(cnt>=24'd1&cnt<=24'd50000)?1:0;     //0.5ms,0度
assign pwm2=(cnt>=24'd1&cnt<=24'd60000)?1:0;     //0.6ms,
assign pwm3=(cnt>=24'd1&cnt<=24'd70000)?1:0;     //0.7ms,
assign pwm4=(cnt>=24'd1&cnt<=24'd80000)?1:0;     //0.8ms,
assign pwm5=(cnt>=24'd1&cnt<=24'd90000)?1:0;     //0.9ms,
assign pwm6=(cnt>=24'd1&cnt<=24'd100000)?1:0;     //1.0ms,
assign pwm7=(cnt>=24'd1&cnt<=24'd110000)?1:0;     //1.1ms,
assign pwm8=(cnt>=24'd1&cnt<=24'd120000)?1:0;     //1.2ms,
assign pwm9=(cnt>=24'd1&cnt<=24'd130000)?1:0;     //1.3ms,
assign pwm10=(cnt>=24'd1&cnt<=24'd140000)?1:0;     //1.4ms,

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        pwm<=pwm1;
     else if(dingous)
        pwm<=pwm10;
     else if(down)
        case(cnt_sec)
         4'd0:pwm<=pwm1;
         4'd1:pwm<=pwm2;
         4'd2:pwm<=pwm3;
         4'd3:pwm<=pwm4;
         4'd4:pwm<=pwm5;
         4'd5:pwm<=pwm6;
         4'd6:pwm<=pwm7;
         4'd7:pwm<=pwm8;
         4'd8:pwm<=pwm9;
         4'd9:pwm<=pwm10;
         default:pwm<=pwm1;
         endcase   
      else
        pwm<=pwm1;
 end
 
        
endmodule

