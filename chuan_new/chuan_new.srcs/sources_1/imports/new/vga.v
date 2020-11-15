`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/08 00:21:25
// Design Name: 
// Module Name: vga
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


module vga(
input clk_vga,
input rst_mix,
input [3:0]dout,//fifo
input con,
//input vga_begin,//sdram发来的控制vga是否工作的信号;
//input vsync,
output [3:0] red,
output [3:0] green,
output [3:0] blue,
output reg c_t,//场同步
output reg h_t,//行同步
output reg read_begin,
//output reg clk_vga
//output reg clk_vga//,
output reg vga_finashed//一帧读完
//output reg rd_en_f1
    );
	
	wire rst_n;
	assign rst_n = rst_mix&con;
	reg [11:0]rgb;
	
	assign {red,green,blue} = (rgb >= 12'b000101111111)?12'hfff:12'h000;
	
	/*always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix=='d0)
		clk_vga<=1'b0;
		else
		clk_vga<=~clk_vga;
	end*/
	
	reg [9:0]count_r;//行计数器
	reg [9:0]count_c;//列计数器
	always@(posedge clk_vga or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		count_r<='d0;
		end
		else// if(vga_begin==1'b1)
		begin
			if(count_r=='d799)
			begin
			count_r<='d0;
			end
			else
			begin
			count_r<=count_r+10'd1;
			end
		end
		/*else
		begin
			count_r<='d0;
		end*/
	end
	
	always@(posedge clk_vga or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		count_c<='d0;
		//vga_finashed<=1'b0;
		end
		/*else  if(down_begin==1'b1)//
		begin
			count_c<='d0;
		end*/
		else
		begin
			if(count_r=='d799)
			begin
				if(count_c=='d524)
				begin
				//vga_finashed<=1'b1;
				count_c<='d0;
				end
				else
				begin
				count_c<=count_c+9'd1;
				//vga_finashed<=1'b0;
				end
			end
			else
			begin
			count_c<=count_c;
			//vga_finashed<=1'b0;
			end
		end
	end
	
	always@(posedge clk_vga or negedge rst_n)  //行同步
	begin
		if(rst_n==1'b0)
		h_t<='d0;
		else if(count_r<='d95)//
		h_t<='d1;
		else
		h_t<='d0;
	end
	
	always@(posedge clk_vga or negedge rst_n) //场同步
	begin
		if(rst_n==1'b0)
		c_t<='d0;
		else if(count_c<='d1)//
		c_t<='d1;
		else
		c_t<=1'b0;
	end
	
	always@(posedge clk_vga or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		rgb<=12'h0;
		read_begin<=1'b0;
		vga_finashed<=1'b1;
		end
		else
		begin
			if(count_c<='d35||count_c>='d516)//516
			begin
				/*if(count_c>='d196)//516 >=
				begin
				rgb<=12'hfff;
				read_begin<=1'b0;
				vga_finashed<=1'b1;
				end
				else if(count_c=='d35)
				begin
				rgb<=12'hfff;
				read_begin<=1'b0;
				vga_finashed<=1'b0;
				end*/
				if(count_c>='d516)
                begin
                rgb<=16'h0;
                read_begin<=1'b0;
                vga_finashed<=1'b1;
                end
                else if(count_c=='d35)
                begin
                rgb<=16'h0;
                read_begin<=1'b0;
                vga_finashed<=1'b0;
                end
			end
			else if(count_r<='d142||count_r>='d783)//if(count_r<='d143||count_r>='d785)<= 783 
			begin
				/*if(count_r=='d142 && count_r<'d463)//783
				begin
				read_begin<=1'b1;
				rgb<=12'h0;
				end
				else
				begin
				rgb<=12'hfff;
				read_begin<=1'b0;
				end*/
				//if(count_r=='d142&&count_r<'d783)
                //begin
                //read_begin<=1'b0;
                //rgb<=16'h0;
                //end
                //else
               // begin
                rgb<=16'h0;
                read_begin<=1'b0;
                //end
			end
			else
			begin
			     if(count_r <='d462 && count_c <= 'd195)
                 begin
                    if(count_c == 'd195)
                    begin
                    rgb<={dout,dout,dout};
                    //rgb<=16'hffff;
                    read_begin<=1'b0;
                    vga_finashed <= 1'b0;
                    end
                    else if(count_r == 'd143)
                    begin
                    rgb <= 12'hfff;
                    read_begin <= 1'b0;
                    vga_finashed <= 1'b0;
                    end
                    else
                    begin
                    rgb<={dout,dout,dout};
                    //rgb<=16'hffff;
                    read_begin<=1'b1;
                    vga_finashed <= 1'b0;
                    end
                 end
                 else if(count_c >'d195)
                 begin
                 rgb<= 12'hfff;
                 //rgb<=16'hffff;
                 read_begin<=1'b0;
                 vga_finashed <= 1'b1;
                 end
                 else if(count_r == 'd463)
                 begin
                 rgb <= 12'hfff;
                 read_begin <= 1'b1;
                 vga_finashed <= 1'b0;
                 end
                 else if(count_r > 'd462)
                 begin
                 rgb <= 12'hfff;
                 read_begin <= 1'b0;
                 vga_finashed <= 1'b0;
                 end
             end
			  /*if(count_r>='d462)
              begin
              rgb<={dout,dout,dout};
               //rgb<=16'hffff;
              read_begin<=1'b0;
              end
              else
              begin
              rgb<={dout,dout,dout};
              //rgb<=16'hffff;
              read_begin<=1'b1;
              end
			 end*/
			
			/*
				if(count_r=='d783)//782 >=
				begin
				rgb<={dout,dout,dout};
				//rgb<=16'hffff;
				read_begin<=1'b0;
				end
				else
				begin
				rgb<={dout,dout,dout};
				//rgb<=16'hffff;
				read_begin<=1'b1;
				end
			end*/
		end
	end		
	
endmodule
