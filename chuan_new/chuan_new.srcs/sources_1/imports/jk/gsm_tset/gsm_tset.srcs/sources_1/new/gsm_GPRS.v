`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/06 15:14:12
// Design Name: 
// Module Name: gsm_GPRS
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
module gsm_GPRS(
    clk,
	rst_n,
	key_flag,
	line_tx
    );
     input clk;
	 input rst_n;
	 input key_flag;
	 output reg line_tx;
	 
	 
parameter tx_start = 0,tx_stop = 1;
parameter delay_cnt = 25000000;
parameter telephone = "16713725197";
//parameter data_tx = "A"; 
reg [7:0]data_tx;
reg [12:0] cnt;  //波特率计数
reg clk_tx;      //分频时钟（波特率）
reg [3:0] cnt_tx;
reg en ;
reg [6:0]stop;

reg [24:0]cnt_20ms; //每发送一串指令后的延时
reg en_cnt_20ms;


always @(posedge clk or negedge rst_n)
    if(!rst_n)
	    en_cnt_20ms <= 0;
	else if(cnt_20ms == delay_cnt - 1'b1)
	    en_cnt_20ms <= 0;
	else if(stop == 7 && cnt_tx == 11)//第一串指令发完
	    en_cnt_20ms <= 1;
	else if(stop == 17 && cnt_tx == 11)//第二串指令发完
	    en_cnt_20ms <= 1;
	else if(stop == 26 && cnt_tx == 11)//第三串指令发完
	    en_cnt_20ms <= 1;
     else if(stop == 70 && cnt_tx == 11)//第三串指令发完
	    en_cnt_20ms <= 1;
	else if(stop == 81&& cnt_tx == 11)//第四串指令发完
	    en_cnt_20ms <= 1;
	else if(stop == 89 && cnt_tx == 11)//第五串指令发完
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
	else if(stop == 91 && cnt_tx == 11)       //改 98；
	    stop <= 0;
	else if(cnt_tx == 11)
	    stop <= stop + 1'b1;
	else 
	    stop <= stop;
		
always @(posedge clk or negedge rst_n)
    if(!rst_n)
	     data_tx <= 8'b1011_1110;
	else if(en)
	     case(stop)
	     
	                'd0: data_tx<="A";
					'd1: data_tx<="T";
                    'd2: data_tx<="+";
                    'd3: data_tx<="C";
                    'd4: data_tx<="S";
                    'd5: data_tx<="T";
                    'd6: data_tx<="T";
                    'd7: data_tx<=8'h0d;
                    'd8: data_tx<=8'h0a;
                    'd9: data_tx<="A";
                    'd10 :data_tx<="T";
                    'd11 :data_tx<="+";
                    'd12 :data_tx<="C";
                    'd13 :data_tx<="I";
                    'd14 :data_tx<="I";
                    'd15 :data_tx<="C";
                    'd16 :data_tx<="R";
                    'd17 :data_tx<=8'h0d;
                  
                    'd18 :data_tx<="A";
                    'd19 :data_tx<="T";
                    'd20 :data_tx<="+";
                    'd21 :data_tx<="C";
                    'd22 :data_tx<="I";
                    'd23 :data_tx<="F";
                    'd24 :data_tx<="S";
                    'd25 :data_tx<="R";
                    'd26 :data_tx<=8'h0d;
                   
                    'd27 :data_tx<="A";
                    'd28 :data_tx<="T";
                    'd29 :data_tx<="+";
                    'd30 :data_tx<="C";
                    'd31 :data_tx<="I";
                    'd32 :data_tx<="P";
                    'd33 :data_tx<="S";
                    'd34 :data_tx<="T";
                    'd35 :data_tx<="A";
                    'd36 :data_tx<="R";
                    'd37 :data_tx<="T";
                    'd38 :data_tx<="=";
                    'd39:data_tx<=8'h22;
                    'd40 :data_tx<="T";
                    'd41 :data_tx<="C";
                    'd42 :data_tx<="P";
                    'd43 :data_tx<=8'h22;
                    'd44 :data_tx<=",";
                    'd45 :data_tx<=8'h22;
                    'd46 :data_tx<="1";
                    'd47 :data_tx<="2";
                    'd48 :data_tx<="2";
                    'd49 :data_tx<=".";
                    'd50 :data_tx<="1";
                    'd51 :data_tx<="1";
                    'd52 :data_tx<="4";
                    'd53 :data_tx<=".";
                    'd54 :data_tx<="1";
                    'd55 :data_tx<="2";
                    'd56 :data_tx<="2";
                    'd57 :data_tx<=".";
                    'd58 :data_tx<="1";
                    'd59 :data_tx<="7";
                    'd60 :data_tx<="4";
                    'd61 :data_tx<=8'h22;
                    'd62 :data_tx<=",";
                    'd63 :data_tx<=8'h22;
                    'd64 :data_tx<="4";
                    'd65 :data_tx<="4";
                    'd66 :data_tx<="7";
                    'd67 :data_tx<="5";
                    'd68 :data_tx<="7";
                    'd69:data_tx<=8'h22;
                    'd70 :data_tx<=8'h0d;
                  
                    'd71 :data_tx<="A";
                    'd72 :data_tx<="T";
                    'd73 :data_tx<="+";
                    'd74 :data_tx<="C";
                    'd75 :data_tx<="I";
                    'd76 :data_tx<="P";
                    'd77 :data_tx<="S";
                    'd78 :data_tx<="E";
                    'd79 :data_tx<="N";
                    'd80 :data_tx<="D";
                    'd81 :data_tx<=8'h0d;
                 
                    'd82 :data_tx<="W";
                    'd83 :data_tx<="A";
                    'd84 :data_tx<="R";
                    'd85 :data_tx<="N";
                    'd86 :data_tx<="I";
                    'd87 :data_tx<="N";
                    'd88 :data_tx<="G";
                    'd89 :data_tx<=8'h0d;
                   
                    'd90 :data_tx<=8'h1a;
                    'd91 :data_tx<=8'h0d;
              
		 endcase		
		
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	    en <= 0;
	else if(key_flag)
	    en <= 1;
	else if(cnt_20ms == delay_cnt - 1'b1)
	    en <= 1;
	else if(stop == 7 && cnt_tx == 11)//第一串指令发完
	    en <= 0;
	else if(stop == 17 && cnt_tx == 11)//第二串指令发完
	    en <= 0;
	else if(stop == 26 && cnt_tx == 11)//第三串指令发完
	    en <= 0;
	 else if(stop == 70 && cnt_tx == 11)//第三串指令发完
	    en <= 0;
	else if(stop == 81&& cnt_tx == 11)//第四串指令发完
	    en <= 0;
	else if(stop == 89 && cnt_tx == 11)//第五串指令发完
	    en <= 0;
	else if(stop == 91 && cnt_tx == 11)//第六串指令发完
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



