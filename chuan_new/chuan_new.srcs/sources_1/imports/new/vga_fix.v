`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/26 18:31:18
// Design Name: 
// Module Name: vga_fix
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


module vga_fix(
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
output reg clk_delay,
output reg vga_finashed,//一帧读完
output reg pixel_finashed//////////////////////////////////////
//output reg rd_en_f1
    );
        wire rst_n;
        assign rst_n = rst_mix&con;
        reg [11:0]rgb;
        wire [11:0]pix;
        assign {red,green,blue} = pix;
        assign pix = (rgb >= 12'b000111111111 ) ? 12'hfff : 12'h0;
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
        
        //为了扩大,延缓时钟
        always@(posedge clk_vga or negedge rst_n)
        begin
            if(rst_n == 1'b0)
            clk_delay <= 1'b0;
            else
            clk_delay <= ~clk_delay;
        end
        //缓存一行像素,重复三次
        reg [2559 : 0]buffer;
        always@(posedge clk_vga or negedge rst_n)//存入的速率是读出速率的两倍
        begin
            if(rst_n == 1'b0)
            begin
                buffer <= 'd0;
            end 
            else if(read_begin == 1'b1)
            begin
                buffer <= {dout , buffer[2559 : 4]};
            end
            else if(count_r >= 'd143 && count_r <= 'd782)
            begin
                buffer <= {buffer[3 : 0] , buffer[2559 : 4]};
            end
        end
        
        //控制read_begin以及vga_finished
        always@(posedge clk_vga or negedge rst_n)
        begin
            if(rst_n == 1'b0)
            begin
                    rgb<=12'h0;
                    read_begin<=1'b0;
                    vga_finashed<=1'b1;
                    pixel_finashed <= 1'b0;
            end
            else
            begin
                if(count_c <= 'd35 || count_c >= 'd516)
                begin
                    if(count_c>='d516)//516
                    begin
                      rgb<=12'h0;
                      read_begin<=1'b0;
                      vga_finashed<=1'b1;
                      pixel_finashed <= 1'b1;
                    end
                    else if(count_c=='d35)
                    begin
                      rgb<=12'h0;
                      read_begin<=1'b0;
                      vga_finashed<=1'b0;
                      pixel_finashed <= 1'b0;
                     end
                     else
                     begin
                       rgb <= 12'h0;
                       read_begin <= 1'b0;
                       vga_finashed <= 1'b1;
                       pixel_finashed <= 1'b1;
                     end
                end
                else if(count_r <= 'd142 || count_r >= 'd783)
                begin
                    if( count_c % 3 != 'd0)
                    begin
                        rgb <= 12'h0;
                        read_begin <= 1'b0;
                        vga_finashed <= 1'b0;//1
                        pixel_finashed <= 1'b1;
                    end
                    else if(count_r == 'd142 && count_c % 3 == 'd0)
                    begin
                        rgb <= 12'h0;
                        read_begin <= 1'b1;
                        vga_finashed <= 1'b0;
                        pixel_finashed <= 1'b0;
                    end
                    else
                    begin
                        rgb<=12'h0;
                        read_begin<=1'b0;
                        vga_finashed <= 1'b0;
                        pixel_finashed <= 1'b0;
                    end
                end
                else
                begin
                    if(count_c >= 'd504)
                    begin
                        read_begin <= 1'b0;
                        rgb <= 'd0;//{buffer[3:0] , buffer[3:0] , buffer[3:0]};
                        vga_finashed <= 1'b0;
                        pixel_finashed <= 1'b1;
                    end
                    else if( count_c % 3 == 'd0)
                    begin
                        read_begin <= 1'b1;
                        rgb <= {dout , dout , dout};
                        vga_finashed <= 1'b0;
                        pixel_finashed <= 1'b0;
                    end
                    else
                    begin
                        read_begin <= 1'b0;
                        rgb <= {buffer[3:0] , buffer[3:0] , buffer[3:0]};
                        vga_finashed <= 1'b0;
                        pixel_finashed <= 1'b1;
                    end
                end
            end
        end
endmodule
