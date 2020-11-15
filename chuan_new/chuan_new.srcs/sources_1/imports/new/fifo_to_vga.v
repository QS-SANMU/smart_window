`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/08 00:16:21
// Design Name: 
// Module Name: fifo_to_vga
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


module fifo_to_vga(
input con,
input clk_wr,
input clk_rd,
//input rd_en,
input wr_en_f1,
input [3:0]data,
input rst_0,
input vga_finished,
input read_begin,//rd_en
//input rd_en_f1,
output reg ram_r_b,
(*MARK_DEBUG="TRUE"*)output  [3:0]dout
    );
    
    wire rst_n;
    assign rst_n = rst_0 & con;
    
     wire vga_finished_u;
       reg vga_finished0;
       reg vga_finished1;
       always@(posedge clk_rd or negedge rst_n)
       begin
           if(rst_n == 1'b0)
           begin
               vga_finished0 <= 1'b0;
               vga_finished1 <= 1'b0;
           end
           else
           begin
               vga_finished0 <= vga_finished;
               vga_finished1 <= vga_finished0;
           end
       end
       assign vga_finished_u = vga_finished0 & (~vga_finished1);
    
    wire wr_d;
    reg wr_en0;
    reg wr_en1;
    reg wr_en2;
    always@(posedge clk_rd or negedge rst_n)
    begin
        if(rst_n == 1'b0)
        begin
        wr_en0 <= 1'b0;
        wr_en1 <= 1'b0;
        wr_en2 <= 1'b0;
        end
        else
        begin
        wr_en0 <= wr_en_f1;
        wr_en1 <= wr_en0;
        wr_en2 <= wr_en1;
        end
    end
    assign wr_d = (~wr_en1)&wr_en2;
    
    reg [31:0]pix_count;
    always@(posedge clk_rd or negedge rst_n)
    begin
        if(rst_n == 1'b0)
        pix_count <= 'd0;
        else if(vga_finished_u == 1'b1)
        pix_count <= 'd0;
        else if(read_begin == 1'b1)
        begin
            if(pix_count == 'd320)//160
            pix_count <= 'd0;
            else
            pix_count <= pix_count + 'd1;
        end
        else
        begin
            pix_count <= 'd0;
        end
    end
    
    always@(posedge clk_rd or negedge rst_n)
    begin
        if(rst_n == 1'b0)
        ram_r_b <= 1'b0;
        else if(vga_finished_u == 1'b1)
        ram_r_b <= 1'b0;
        else if(pix_count == 'd318)//158 318
        ram_r_b <= 1'b1;           
        else if(wr_d == 1'b1)//ÎÕÊÖ
        ram_r_b <= 1'b0;
    end
    
    reg rst_cnt;
    always@(posedge clk_rd or negedge rst_n)
        begin
            if(rst_n==1'b0)
            begin
                rst_cnt<=1'b1;
            end
            else if(vga_finished_u==1'b1)
            begin
                rst_cnt<=1'b1;
            end
            else
            begin
                rst_cnt<=1'b0;
            end
        end
    wire dout1;
    fifo_generator_1 f2(
     .rst(rst_cnt),
     .wr_clk(clk_wr),
     .rd_clk(clk_rd),
     .din(data),
     .wr_en(wr_en_f1),
     .rd_en(read_begin),
     .dout(dout)
    );
    
    //assign dout = (dout1 == 4'h1) ? 4'h0 : 4'hf;
    
endmodule
