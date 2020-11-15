`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/05 14:41:16
// Design Name: 
// Module Name: seg_dis
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


module seg_dis(clk,rst_n,dis_data,dtube_cs_n,dtube_data	
		);
	input clk;		//时钟信号25MHz
	input rst_n;			//复位信号a
	input [15:0] dis_data;//
	output reg[3:0] dtube_cs_n;	//段选数据位
	output reg[6:0] dtube_data;//位选数据位
	reg [3:0]TimeH;			//两位输入高位  [0]
	reg [3:0]TimeL;			//两位输入低位  [1]
	reg [3:0]TimeH1;		//两位输入高位  [2]
	reg [3:0]TimeL1;		//两位输入低位  [3]	
	reg [3:0] display_num;	//当前显示数据
	reg [19:0] div_cnt;	//延时计数器计数位
	always@(posedge clk or negedge rst_n)begin
		if(rst_n==1'b0)begin
			TimeH<=1'b0;	
			TimeL<=1'b0;	
			TimeH1<=1'b0;
			TimeL1<=1'b0;
		end
		else begin
			TimeH <=dis_data[7:4];		
			TimeL <=dis_data[3:0];
			TimeH1<=dis_data[15:12];
			TimeL1<=dis_data[11:8];
		end
	end
initial div_cnt = 0;//赋初值为0
//延时计数器模块
	always@ (posedge clk or negedge rst_n)
	begin
		if(!rst_n) 
			div_cnt <= 8'd0;
		else if(div_cnt==20'd160000)
			div_cnt <= 8'd0;		
		else 
			div_cnt <= div_cnt+1'b1;
	end
	
//显示当前的数据模块
	always @(posedge clk or negedge rst_n)
	begin
	if(!rst_n) 
		display_num <= 4'h0;
	else if(div_cnt < 20'd40000)
		display_num <= TimeL;
	else if((div_cnt>20'd40000)&(div_cnt <20'd80000))
		display_num <= TimeH;
	else if((div_cnt>20'd80000)&(div_cnt < 20'd120000))
		display_num <=TimeL1;
	else
		display_num <=TimeH1;
	end
		
//段选数据译码模块(共阴数码管)
	always @(*)
	begin
		if(!rst_n) 
			dtube_data <= 8'h00;
		else begin
			case(display_num) 
				4'h0: dtube_data <= 8'h40;
				4'h1: dtube_data <= 8'h79;
				4'h2: dtube_data <= 8'h24;
				4'h3: dtube_data <= 8'h30;
				4'h4: dtube_data <= 8'h19;
				4'h5: dtube_data <= 8'h12;
				4'h6: dtube_data <= 8'h02;
				4'h7: dtube_data <= 8'h78;
				4'h8: dtube_data <= 8'h20;
				4'h9: dtube_data <= 8'h10;
				default:dtube_data <= 8'h00;
			endcase
		end
	end
//位选选译模块
	always @(posedge clk or negedge rst_n)	
	begin
		if(!rst_n) 
			dtube_cs_n <=  4'b1111;
		else if(div_cnt <= 17'd40000)
			dtube_cs_n <= 4'b1110;
		else if((div_cnt>17'd40000)&(div_cnt <=17'd80000))
			dtube_cs_n <= 4'b1101;
		else if((div_cnt>17'd80000)&(div_cnt <=17'd120000))
			dtube_cs_n <= 4'b1011;
		else 
			dtube_cs_n <=4'b0111;
	end
endmodule