`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/07 18:08:58
// Design Name: 
// Module Name: main_control
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
module main_control(
clk,rst_n,massage,call,window_L,window_R,curtain_1,curtain_2,senser_cmds,GSM_cmds,window_cmds,curtain_cmds,tele_cancel,curtain_cmds1,window_cmds1
);
    input clk;
	input rst_n;
	input [1:0]massage;     //广场舞邀约
	input [3:0]call;     //打电话
	input [3:0]window_L;    //左窗户
	input [3:0]window_R;    //右窗户
	input [2:0]curtain_1;   //卧室窗帘
	input [2:0]curtain_2;   //客厅窗户
	input [3:0]senser_cmds;   
	
	output reg [3:0]GSM_cmds;
	//output reg [3:0]GSM_cmds1;
	
	output reg [3:0]window_cmds;
	output reg [3:0]window_cmds1;
	
	
	output reg [3:0]curtain_cmds;
	output reg [3:0]curtain_cmds1;
	output reg tele_cancel;
	


always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		GSM_cmds<=4'd0;
        tele_cancel<=0;
		end
	else if(call==4'd1 | call==4'd9)
			GSM_cmds<=4'd1;
	else if(call==4'd2 | call==4'd10)
			GSM_cmds<=4'd2;
	else if(call==4'd3 | call==4'd11 | senser_cmds==4'd3 | senser_cmds==4'd4 | senser_cmds==4'd5 | senser_cmds==4'd6)
		    GSM_cmds<=4'd3;
	else if(call==4'd4 | call==4'd12)
			GSM_cmds<=4'd4;
	else if(call==4'd8)
			tele_cancel<=1;
    else if(senser_cmds==4'd1 | senser_cmds==4'd2 )
           GSM_cmds<=4'd5; 
	else
	   begin
		GSM_cmds<=4'd0;
        tele_cancel<=0;
		end
end

/*always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	   window_cmds<=4'd0;
   else if(window_L==4'd0)  //关左
	   window_cmds<=4'd0;  
   else if(window_L==4'd9)   //开左
	   window_cmds<=4'd2;
   else if(window_R==4'd0)
	   window_cmds<=4'd0;
   else if(window_R==4'd9)
	   window_cmds<=4'd3;
   else
        window_cmds<=4'd0;
end*/
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        window_cmds <= 4'd15;
    else
    begin
        case(window_L)
        
        4'd1 : window_cmds <= 4'd0;
        4'd2 : window_cmds <= 4'd1;
        4'd3 : window_cmds <= 4'd2;
        4'd4 : window_cmds <= 4'd3;
        4'd5 : window_cmds <= 4'd4;
        4'd6 : window_cmds <= 4'd5;
        4'd7 : window_cmds <= 4'd6;
        4'd8 : window_cmds <= 4'd7;
        4'd9 : window_cmds <= 4'd8;   //原来是2
        
        default : window_cmds <= 4'd15;
        endcase
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        window_cmds1 <= 4'd15;
    else
    begin
        case(window_R)
        
        4'd1 : window_cmds1 <= 4'd0;
        4'd2 : window_cmds1 <= 4'd1;
        4'd3 : window_cmds1 <= 4'd2;
        4'd4 : window_cmds1 <= 4'd3;
        4'd5 : window_cmds1 <= 4'd4;
        4'd6 : window_cmds1 <= 4'd5;
        4'd7 : window_cmds1 <= 4'd6;
        4'd8 : window_cmds1 <= 4'd7;
        4'd9 : window_cmds1 <= 4'd8;//原来是3

        default : window_cmds1 <= 4'd15;
        endcase
    end
end

/*always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	   curtain_cmds<=4'd0;
    else if(curtain_1==0)  //开1
	   curtain_cmds<=4'd1;
	else if(curtain_1==5)  //关1
	   curtain_cmds<=4'd3;
	else if(curtain_2==0)  //开2
	   curtain_cmds<=4'd2;
    else if(curtain_2==5)  //关2
	   curtain_cmds<=4'd4;
    else
	   curtain_cmds<=4'd0;
end*/
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        curtain_cmds <= 4'd0;
    else if(curtain_1 == 0)///////0
        curtain_cmds <= 4'd1;
    else if(curtain_1 == 5)
        curtain_cmds <= 4'd3;
    else
        curtain_cmds <= 4'd0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        curtain_cmds1 <= 4'd0;
    else if(curtain_2==0)  ////////////开2 0
        curtain_cmds1<=4'd2;
    else if(curtain_2==5)  //关2
        curtain_cmds1<=4'd4;
    else
        curtain_cmds1<=4'd0;
end

endmodule