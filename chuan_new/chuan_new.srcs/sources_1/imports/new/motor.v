`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/05 14:34:07
// Design Name: 
// Module Name: motor
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


module motor(
    clk,
	rst_n,
	key1_p,
	key2_p,
	key1_n,
	key2_n,
	out1,
	out2,
	key_state1_n,
	key_state1_p,
	key_state2_n,
	key_state2_p
	
    );
input clk;
input rst_n;

input key1_p;//窗户1  打开 
input key2_p;//窗户2  打开
input key1_n;//窗户1  关闭 
input key2_n;//窗户2  关闭
output reg [1:0]out1; //窗户1信号
output reg [1:0]out2;//窗户2信号

output reg key_state1_p;
output reg key_state2_p;
output reg key_state1_n;
output reg key_state2_n;


//寄存按键之前的状态
reg key1_p_ed;  
reg key2_p_ed;
reg key1_n_ed;
reg key2_n_ed;
//上升沿检测   
wire key1_p_pose;
wire key1_n_pose;
wire key2_p_pose;
wire key2_n_pose;

//控制信号
/*
reg key_state1_p;
reg key_state2_p;
reg key_state1_n;
reg key_state2_n;
*/
//控制信号时间计数器
reg [31:0]cnt1;
reg [31:0]cnt2;

//0.5us时钟
reg [18:0]cnt_p1;
reg clk_3ms_p1;
reg [18:0]cnt_n1;
reg clk_3ms_n1;
reg [18:0]cnt_p2;
reg clk_3ms_p2;
reg [18:0]cnt_n2;
reg clk_3ms_n2;
parameter delay_cnt =5000;   //脉冲周期0.5us//50000

//检测上升沿
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            key1_p_ed<=0;
            key2_p_ed<=0;
            key1_n_ed<=0;
            key2_n_ed<=0;
        end
    else 
        begin
            key1_p_ed<=key1_p;
            key2_p_ed<=key2_p;
            key1_n_ed<=key1_n;
            key2_n_ed<=key2_n;
        end
end


assign key1_p_pose=(!key1_p_ed & key1_p)?1:0;
assign key1_n_pose=(!key1_n_ed & key1_n)?1:0;
assign key2_p_pose=(!key2_p_ed & key2_p)?1:0;
assign key2_n_pose=(!key2_n_ed & key2_n)?1:0;


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            key_state1_p<=0;
			key_state1_n<=0;
            cnt1<=0;
         end
     else if(key1_p_pose)
                key_state1_p<=1;
     else if(key1_n_pose)
                key_state1_n<=1;
     else
        begin
             if(cnt_p1 >= delay_cnt/2 -1 | cnt_n1 >= delay_cnt/2 -1)   
                    cnt1<=cnt1+1;
               else
                    cnt1<=cnt1;
              if(cnt1=='d150000000)   //10s
                  begin
                    key_state1_p<=0;
                    key_state1_n<=0;
                    cnt1<=0;
                  end
               else
					begin
                    key_state1_p<=key_state1_p;
                    key_state1_n<=key_state1_n;
					end
            end
end
     

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
            begin
            cnt2<=0;
            key_state2_p<=0;
            end
     else if(key2_p_pose)
                key_state2_p<=1;
     else if(key2_n_pose)
                key_state2_n<=1;
     else
        begin
             if(cnt_p2 >= delay_cnt/2 -1 | cnt_n2 >= delay_cnt/2 -1)   
                    cnt2<=cnt2+1;
               else
                    cnt2<=cnt2;
              if(cnt2=='d150000000)
                  begin
                    key_state2_p<=0;
                    key_state2_n<=0;
                    cnt2<=0;
                  end
               else
					begin
                    key_state2_p<=key_state2_p;
                    key_state2_n<=key_state2_n;
					end
            end
end
     


//打开窗户1
always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    cnt_p1 <= 0;
	else if(key_state1_p)begin
        if(cnt_p1 == delay_cnt - 1)
	        cnt_p1 <= 0;
	    else 
	        cnt_p1 <= cnt_p1 + 1'b1;
		end
	else 
        cnt_p1 <= 0;


always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    clk_3ms_p1 <= 0;
	else if(cnt_p1 >= delay_cnt/2 -1)
	    clk_3ms_p1 <= 1;
	else 
	    clk_3ms_p1 <= 0;
		
//打开窗户2
always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    cnt_p2 <= 0;
	else if(key_state2_p)begin
        if(cnt_p2 == delay_cnt - 1)
	        cnt_p2 <= 0;
	    else 
	        cnt_p2 <= cnt_p2 + 1'b1;
		end
	else 
        cnt_p2 <= 0;

		
always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    clk_3ms_p2 <= 0;
	else if(cnt_p2 >= delay_cnt/2 -1)
	    clk_3ms_p2 <= 1;
	else 
	    clk_3ms_p2 <= 0;
		
		
//关闭窗户1
always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    cnt_n1 <= 0;
	else if(key_state1_n)begin
        if(cnt_n1 == delay_cnt - 1)
	        cnt_n1 <= 0;
	    else 
	        cnt_n1 <= cnt_n1 + 1'b1;
		end
	else 
        cnt_n1 <= 0;

		
always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    clk_3ms_n1 <= 0;
	else if(cnt_n1 >= delay_cnt/2 - 1)
	    clk_3ms_n1 <= 1;
	else 
	    clk_3ms_n1 <= 0;
		
//关闭窗户2
always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    cnt_n2 <= 0;
	else if(key_state2_n)begin
        if(cnt_n2 == delay_cnt - 1)
	        cnt_n2 <= 0;
	    else 
	        cnt_n2 <= cnt_n2 + 1'b1;
		end
	else 
        cnt_n2 <= 0;

		
always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    clk_3ms_n2 <= 0;
	else if(cnt_n2 >= delay_cnt/2 - 1)
	    clk_3ms_n2 <= 1;
	else 
	    clk_3ms_n2 <= 0;
		
		
//窗户1打开或关闭
always @(posedge clk or negedge rst_n)
	if(!rst_n)
        out1 <= 2'b10;//正向  低电平
    else if(key_state1_p)//打开1
        out1 <= {1'b0,clk_3ms_p1};	
	else if(key_state1_n)//关闭1
        out1 <= {1'b1,clk_3ms_n1};	
	else
		out1 <= 2'b10;//正向  低电平
		
		
//窗户2打开或关闭
always @(posedge clk or negedge rst_n)
	if(!rst_n)
        out2 <= 2'b10;//正向  低电平
    else if(key_state2_p)//打开1
        out2 <= {1'b0,clk_3ms_p2};	
	else if(key_state2_n)//关闭1
        out2 <= {1'b1,clk_3ms_n2};	
	else
		out2 <= 2'b10;//正向  低电平
		
endmodule
