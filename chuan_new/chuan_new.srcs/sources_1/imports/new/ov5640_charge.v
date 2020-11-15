`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/14 19:42:46
// Design Name: 
// Module Name: ov5640_charge
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


module ov5640_charge( //上电时序
input clk,
input rst_mix,
output reg dvp_reset,
output reg pwdn,
output reg dvp_reset_flag//此时可以开始sccb操作
    );
	localparam delay_6ms = 30_0000;//6ms
	localparam delay_2ms = 10_0000;//2ms
	localparam delay_21ms = 105_0000;//21ms
	
	/*计数器*/
	reg [31:0] cnt_6ms;
	reg [31:0] cnt_2ms;
	reg [20:0] cnt_21ms;
	
	/*count*/
	always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix == 1'b0)
			cnt_6ms <= 'd0;
		else if(pwdn == 1'b1)
		begin
			if(cnt_6ms == delay_6ms)
				cnt_6ms <= cnt_6ms;
			else
				cnt_6ms <= cnt_6ms + 'd1;//板子上电后pown至少有效6ms;
		end
	end
	
	always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix == 1'b0)
			pwdn <= 1'b1;
		else if(cnt_6ms == delay_6ms)//此处也可以使用==
			pwdn <= 1'b0;
	end
	
	always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix == 1'b0)
			cnt_2ms <= 'd0;
		else if(pwdn == 1'b0)
		begin
			if(cnt_2ms == delay_2ms)
				cnt_2ms <= cnt_2ms;
			else
				cnt_2ms <= cnt_2ms + 'd1;
		end
	end
	
	always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix == 1'b0)
			dvp_reset <= 1'b0;
		else if(cnt_2ms == delay_2ms)
			dvp_reset <= 1'b1;
	end
	
	always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix == 1'b0)
			cnt_21ms <= 21'd0;
		else if(dvp_reset == 1'b1)
		begin
			if(cnt_21ms == delay_21ms)
				cnt_21ms <= cnt_21ms;
			else
				cnt_21ms <= cnt_21ms + 21'd1; 
		end
	end
	
	always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix == 1'b0)
			dvp_reset_flag <= 1'b0;
		else if(cnt_21ms == delay_21ms)
			dvp_reset_flag <= 1'b1;
	end

endmodule
