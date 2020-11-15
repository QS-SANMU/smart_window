`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 00:15:18
// Design Name: 
// Module Name: etching
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


module etching(///改为腐蚀
input clk_25m,
input rst_mix,
input con,
input etch,//
input start,
output reg start1,
output exp//膨胀结果
    );
	
	wire rst_n;
	assign rst_n = rst_mix&con;
	reg rgb;
	
	wire pixel;
	assign pixel = rgb;
    reg read_begin;
	reg [9:0]count_r;//行计数器
	reg [9:0]count_c;//列计数器
	always@(posedge clk_25m or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		count_r<='d0;
		end
		else if(start == 1'b1)// if(vga_begin==1'b1)
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
	end
	
	always@(posedge clk_25m or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		count_c<='d0;
		end
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
	
	always@(posedge clk_25m or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		rgb<='d0;
		read_begin<=1'b0;
		end
		else
		begin
			if(count_c<='d35||count_c>='d516)//516
			begin
				if(count_c>='d516)
                begin
                rgb<='d0;
                read_begin <= 1'b0;
                end
                else if(count_c=='d35)
                begin
                rgb<='d0;
                read_begin <= 1'b0;
                end
			end
			else if(count_r<='d142||count_r>='d783)//if(count_r<='d143||count_r>='d785)<= 783 
			begin
                if(count_r == 'd142)
                begin
                read_begin <= 1'b1;
                rgb <= etch;
                end
                else
                begin
                read_begin <= 1'b0;
                rgb <= etch;
                end
			end
			else
			begin
			     if(count_c >= 'd504)
			     begin
			     read_begin <= 1'b0;
			     rgb <= 'd0;
			     end
			     else
			     begin
			     read_begin <= 1'b1;
			     rgb <= etch;
			     end
			end
		end
	end		
	
	always@(posedge clk_25m or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   start1 <= 1'b0;
	   else if(count_c == 'd1 && count_r == 'd798)
	   start1 <= 1'b1;
	end
	/*接入shiftram*/
	wire q1;
	wire q2;
	connect1 c1(
	.clk(clk_25m),
    .ce(read_begin),
    .d(pixel),
    .q1(q1),
    .q2(q2)
	);
	
	reg exp1;
	reg exp2;
	reg exp3;
	always@(posedge clk_25m or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   begin
	       exp1 <= 1'b0;
	   end
	   else
	   begin
	       exp1 <= q1 & q2 & pixel;
	   end
	end
	
	always@(posedge clk_25m or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   begin
	       exp2 <= 1'b0;
	   end
	   else
	   begin
	       exp2 <= exp1;
	   end
	end
	
	always@(posedge clk_25m or negedge rst_n)
        begin
           if(rst_n == 1'b0)
           begin
               exp3 <= 1'b0;
           end
           else
           begin
               exp3 <= exp2;
           end
        end
        
        assign exp = exp1 & exp2 & exp3;
endmodule