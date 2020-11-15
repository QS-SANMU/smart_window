`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/06 10:27:44
// Design Name: 
// Module Name: gsm_test
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
module gsm_call(
      clk,
	  rst_n,
	  key_flag1,
	  key_flag2,
	  telephone,
	  line_tx
    );
     input clk;
	 input rst_n;
	 input key_flag1;
	 input key_flag2;
	 input [87:0] telephone;
	 output reg line_tx;
	
	 
parameter tx_start = 0,tx_stop = 1;
parameter delay_cnt = 25000000;
//parameter telephone = "18237299475";
//parameter data_tx = "A"; 
reg [7:0]data_tx;
reg [12:0] cnt;  //波特率计数
reg clk_tx;      //分频时钟（波特率）
reg [3:0] cnt_tx;
reg en ;
reg [5:0]stop;

reg [24:0]cnt_20ms; //每发送一串指令后的延时
reg en_cnt_20ms;


        

always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    en_cnt_20ms <= 0;
	else if(cnt_20ms == delay_cnt - 1'b1)
	    en_cnt_20ms <= 0;
	else if(stop == 2 && cnt_tx == 11)//第一串指令发完
	    en_cnt_20ms <= 1;
	else if(stop == 11 && cnt_tx == 11)//第二串指令发完
	    en_cnt_20ms <= 1;
	else if(stop == 18 && cnt_tx == 11)//第三串指令发完
	    en_cnt_20ms <= 1;
	else if(stop == 27 && cnt_tx == 11)//第四串指令发完
	    en_cnt_20ms <= 1;
	else if(stop == 37 && cnt_tx == 11)//第五串指令发完
	    en_cnt_20ms <= 1;
	else if(key_flag2)
	    en_cnt_20ms <= 1;
	else 
	    en_cnt_20ms <= en_cnt_20ms;
		
always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    cnt_20ms <= 0;
	else if(en_cnt_20ms)
	    if(cnt_20ms == delay_cnt - 1'b1)
		    cnt_20ms <= 0;
		else 
		    cnt_20ms <= cnt_20ms + 1'b1;
	else 
	    cnt_20ms <= 0;

always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    stop <= 0;
	else if(stop == 57 && cnt_tx == 11)
	    stop <= 0;
	else if(cnt_tx == 11)
	    stop <= stop + 1'b1;
	else 
	    stop <= stop;
		
always @(posedge clk or negedge rst_n)
    if(!rst_n)
	     data_tx <= "1";
	else if(en)
	     case(stop)
	     'd0:data_tx <= "A";	 
	     'd1:data_tx <= "T";
		 'd2:data_tx <= 8'b0000_1101;//回车
		 'd3:data_tx <= "A";	 
	     'd4:data_tx <= "T";
		 'd5:data_tx <= "+";
		 'd6:data_tx <= "C";	 
	     'd7:data_tx <= "P";
		 'd8:data_tx <= "I";
		 'd9:data_tx <= "N";
		 'd10:data_tx <= "?";
		 'd11:data_tx <= 8'b0000_1101;//回车
		 'd12:data_tx <= "A";	 
	     'd13:data_tx <= "T";
		 'd14:data_tx <= "+";
		 'd15:data_tx <= "C";	 
	     'd16:data_tx <= "S";
		 'd17:data_tx <= "Q";
		 'd18:data_tx <= 8'b0000_1101;//回车
		 'd19:data_tx <= "A";	 
	     'd20:data_tx <= "T";
		 'd21:data_tx <= "+";
		 'd22:data_tx <= "C";	 
	     'd23:data_tx <= "R";
		 'd24:data_tx <= "E";
		 'd25:data_tx <= "G";
		 'd26:data_tx <= "?";
		 'd27:data_tx <= 8'b0000_1101;//回车
		 'd28:data_tx <= "A";	 
	     'd29:data_tx <= "T";
		 'd30:data_tx <= "+";
		 'd31:data_tx <= "C";	 
	     'd32:data_tx <= "G";
		 'd33:data_tx <= "A";
		 'd34:data_tx <= "T";
		 'd35:data_tx <= "T";
		 'd36:data_tx <= "?";
		 'd37:data_tx <= 8'b0000_1101;//回车
		 'd38:data_tx <= "A";
		 'd39:data_tx <= "T";
		 'd40:data_tx <= "D";
		 'd41:data_tx <= telephone[87:80];
		 'd42:data_tx <= telephone[79:72];
		 'd43:data_tx <= telephone[71:64];
		 'd44:data_tx <= telephone[63:56];
		 'd45:data_tx <= telephone[55:48];
		 'd46:data_tx <= telephone[47:40];
		 'd47:data_tx <= telephone[39:32];
		 'd48:data_tx <= telephone[31:24];
		 'd49:data_tx <= telephone[23:16];
		 'd50:data_tx <= telephone[15:8];
		 'd51:data_tx <= telephone[7:0];
		 'd52:data_tx <= ";";
		 'd53:data_tx <= 8'b0000_1101;//回车
		 'd54:data_tx <= "A";
		 'd55:data_tx <= "T";
		 'd56:data_tx <= "H";
		 'd57:data_tx <= 8'b0000_1101;//回车
	     endcase		
		
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	    en <= 0;
	else if(key_flag1)
	    en <= 1;
	else if(cnt_20ms == delay_cnt - 1'b1)
	    en <= 1;
	else if(stop == 2 && cnt_tx == 11)//第一串指令发完
	    en <= 0;
	else if(stop == 11 && cnt_tx == 11)//第二串指令发完
	    en <= 0;
	else if(stop == 18 && cnt_tx == 11)//第三串指令发完
	    en <= 0;
	else if(stop == 27 && cnt_tx == 11)//第四串指令发完
	    en <= 0;
	else if(stop == 37 && cnt_tx == 11)//第五串指令发完
	    en <= 0;
	else if(stop == 53 && cnt_tx == 11)//第六串指令发完
	    en <= 0;
	else if(stop == 57 && cnt_tx == 11)//第六串指令发完
	    en <= 0;
	else 
	    en <= en;
end

// 按键按下使能端打开，以及使能的停止


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	     cnt <= 0;
	 else if(en)
	 begin
	     if(cnt == 5207)
	         cnt <= 0;
	     else 
	         cnt <= cnt + 1'b1;
	 end
	 else 
	     cnt <= 0;
end
//分频计数

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	     clk_tx <= 0;
	 else if(cnt == 2)
	     clk_tx <= 1;
	 else 
	     clk_tx <= 0;
end
//分频时钟的产生

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	     cnt_tx <= 0;
	 else if(en)
	 begin
	     if(cnt_tx == 11)
	         cnt_tx <= 0;
	     else if(clk_tx)
	         cnt_tx <= cnt_tx + 1'b1;
	 end
	 else 
	     cnt_tx <= 0;
end

//用来传输数据的计数
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        line_tx <= 1;
	 else if(en)
	 case(cnt_tx)
	 'd0:line_tx <= 1;
	 'd1:line_tx <= tx_start;
	 'd2:line_tx <= data_tx[0];
	 'd3:line_tx <= data_tx[1];
	 'd4:line_tx <= data_tx[2];
	 'd5:line_tx <= data_tx[3];
	 'd6:line_tx <= data_tx[4];
	 'd7:line_tx <= data_tx[5];
	 'd8:line_tx <= data_tx[6];
	 'd9:line_tx <= data_tx[7];
	 'd10:line_tx <= tx_stop;
	 default:line_tx <= 1;
	 endcase
end


endmodule
