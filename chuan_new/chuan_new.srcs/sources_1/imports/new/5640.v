`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/07 15:38:25
// Design Name: 
// Module Name: 5640
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


module 5640(
input pclk,     
//input clk,
input href,		//异步信号，防止亚稳态;
input vsync,	//异步信号，防止亚稳态;
input rst_mix,
input [7:0]d,
input change,
input dvp_reset,
input done,
//output reg dvp_reset,
output reg[15:0]rgb,
output reg [3:0]led,
output reg rgb_flag//一个rgb像素收集完的标志
//output reg vsync_flag,//一帧收集完的标志
//output reg dvp_reset_flag
//output [3:0]led
//output reg dtf_en
    );
	reg done_1;
	reg done_2;
	always@(posedge pclk or negedge rst_mix)
	begin
		if(rst_mix==1'b0)
		begin
			done_1<=1'b0;
			done_2<=1'b0;
		end
		else
		begin
			done_1<=done;
			done_2<=done_1;
		end
	end
	
	/*reg vsync_1;
	reg vsync_2;
	wire down_vsync;
	always@(posedge pclk or negedge rst_mix)//检测vsync脉冲，上升沿为一帧结束，下降沿为一帧开始
	begin
		if(rst_mix==1'b0)
		begin
			vsync_1<=1'b0;
			vsync_2<=1'b0;
		end
		else
		begin
			vsync_1<=vsync;
			vsync_2<=vsync_1;
		end
	end
	assign down_vsync=vsync_2&(~vsync_1);//降
	assign up_vsync=(~vsync_2)&vsync_1;*/
	
	/*reg c_1;
	reg c_2;
	reg c_3;
	wire b_c;
	always@(posedge pclk or negedge rst_mix)
	begin
		if(rst_mix==1'b0)
		begin
			c_1<=1'b0;
			c_2<=1'b0;
			c_3<=1'b0;
		end
		else
		begin
			c_1<=change;
			c_2<=c_1;
			c_3<=c_2;
		end
	end
	assign b_c=c_3^c_2;//脉冲同步*/
	
	reg h_1;
	reg h_2;
	reg h_3;
	wire h_c;
	always@(posedge pclk or negedge rst_mix)
	begin
		if(rst_mix==1'b0)
		begin
			h_1<=1'b0;
			h_2<=1'b0;
			h_3<=1'b0;
		end
		else
		begin
			h_1<=href;
			h_2<=h_1;
			h_3<=h_2;
		end
	end
	assign h_c=~h_3&h_2;//脉冲同步
	/*reg [31:0]data_count;
	always@(posedge pclk or negedge rst_mix)
	begin
		if(rst_mix==1'b0)
		data_count<='d0;
		else if(h_c==1'b1&&done == 1'b1)
		data_count<=data_count+'d1;
		else if(up_vsync==1'b1)
		data_count<='d0;
	end*/
	
	//assign led=(data_count=='d1)?4'b1111:4'b0000;
	
	reg [1:0]state;
	(* mark_debug = "true" *)reg [1:0]rgb_count;//两个d拼接为一个rgb
	always@(posedge pclk or negedge rst_mix)
	begin
		if(rst_mix==1'b0)
		begin
			rgb<=16'd0;
			rgb_flag<=1'b0;
			rgb_count<='d1;//0
			state<='d0;
		end
		else if(dvp_reset==1'b0||done_2==1'b0)
		begin
			rgb<=16'd0;
			state<='d0;
			rgb_flag<=1'b0;
		end
		else
		begin
			case(state)
			'd0:
			begin
				if(href==1'b1)
				begin
					rgb_count<='d0;
					state<='d1;
					rgb<={rgb[7:0],d};
					rgb_flag<=1'b0;
				end
				else
				begin
					state<='d0;
					rgb<=16'h0;
					rgb_flag<=1'b0;
					rgb_count <= 1'b1;
				end
			end
			
			'd1:
			begin
			    if(href == 1'b0)
			    begin
			         rgb_count <= 'd1;
			         rgb_flag <= 1'b0;
			         rgb <= 16'h0;
			         state <= 'd0;
			    end
				else if(rgb_count=='d0)//2
				begin
					/*if(href==1'b0)
					begin
						rgb_count<='d1;
						rgb_flag<=1'b0;//
						state<='d0;
						rgb<='d0;
					end*/
					//else
					//begin
						rgb_count<=rgb_count+'d1;
						rgb_flag<=1'b1;//1
						rgb<={rgb[7:0],d};
					//end
				end
				else
				begin
					rgb_count<='d0;
					rgb_flag<=1'b0;//0
					rgb<={rgb[7:0],d};
				end
			end
			
			default:state<='d0;
			endcase
		end
	end
	
	reg [31:0]count_p;
	always@(posedge pclk or negedge rst_mix)
	begin
	   if(rst_mix == 1'b0)
	   begin
	       count_p <= 'd0;
	       led <= 4'b0000;
	   end
	   else if(count_p == 'd307200)
	   begin
	       count_p <= 'd0;
	       led <= led + 'd1;
	   end
	   else if(rgb_flag == 1'b1)
	   begin
	       count_p <= count_p + 'd1;
	       led <= led;
	   end
	end
	
	
endmodule
