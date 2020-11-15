`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/09 23:25:39
// Design Name: 
// Module Name: dvp_to_fifo0
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


module dvp_to_fifo0(
input pclk,//摄像头时钟
input clk_differ,//写时钟(clk_differ)
//input rd_finish,//一次读完的标记
input change,
input rst_0,//(复位)
input rd_clk,//ram clk  100m
input con,//ram先存一帧
input [3:0]data,//differ
input clear,//rst
input rd_en_fifo0,//读使能
output [3:0]dout_f0,//传给ram
output reg [31:0]f0_count//计数fifo里有几个differ
    );
    //wire rst;
    //assign rst = ~rst_0;
    wire rst_n;
    assign rst_n = rst_0 & con;
    
        wire c_c;
        reg change1;
        reg change2;
        always@(posedge pclk or negedge rst_n)
        begin
            if(rst_n == 1'b0)
            begin
                change1 <= change;
                change2 <= change1;
            end
        end
        
            assign c_c = change1^change2;
            
            reg wr_en;
                always@(posedge pclk or negedge rst_n)
                begin
                    if(rst_n == 1'b0)
                    begin
                    wr_en <= 1'b0;
                    //be <= 1'b0;
                    end
                    else if(clear == 1'b1)
                    begin
                    wr_en <= 1'b0;
                    //be <= 1'b1;
                    end
                    else if(clear == 1'b0)
                    begin
                    wr_en <= 1'b1;
                    //be <= 1'b0;
                    end
                end
    
    reg rd_en_fifo1;
    reg rd_en_fifo2;
    reg rd_en_fifo3;
    wire rd_en_d;
    always@(posedge pclk or negedge rst_n)
    begin
        if(rst_n == 1'b0)
        begin
            rd_en_fifo1 <= 1'b0;
            rd_en_fifo2 <= 1'b0;
            rd_en_fifo3 <= 1'b0;
        end
        else
        begin
            rd_en_fifo1 <= rd_en_fifo0;
            rd_en_fifo2 <= rd_en_fifo1;
            rd_en_fifo3 <= rd_en_fifo2;
        end
    end
    
    assign rd_en_d = (~rd_en_fifo3) & rd_en_fifo2;
    
    //reg [31:0]count;//计数写入多少个differ
    always@(posedge pclk or negedge rst_n)
    begin
        if(rst_n == 1'b0)
        f0_count <= 'd0;
        else if(rd_en_d == 1'b1 && clk_differ == 1'b1)
        f0_count <= f0_count - 'd321;//160
        else if(rd_en_d == 1'b1)
        f0_count <= f0_count - 'd320;//159
        else if(clk_differ == 1'b1)
        f0_count <= f0_count + 'd1;
    end
    
    reg rst_cnt;
    always@(posedge pclk or negedge rst_n)
    begin
        if(rst_n == 1'b0)
        rst_cnt <= 1'b1;
        else if(c_c == 1'b1)
        rst_cnt <= 1'b1;
        else
        rst_cnt <= 1'b0;
        //else if(clear == 1'b0)
        //rst_cnt <= 1'b0;
    end
    
    wire wr_clk;
    assign wr_clk = wr_en == 1'b1 ? clk_differ : pclk;
    
    fifo_generator_0 f1(
       // .rst(rst),
       // .rst(rst_cnt),
        .wr_clk(wr_clk),//cle_differ
        .rd_clk(rd_clk),
        .din(data),
        .wr_en(wr_en),
        .rd_en(rd_en_fifo0),
        .dout(dout_f0)
    );
    
endmodule
