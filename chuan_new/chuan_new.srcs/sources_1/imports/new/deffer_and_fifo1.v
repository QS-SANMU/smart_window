`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/07 20:50:30
// Design Name: 
// Module Name: deffer_and_fifo1
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


module deffer_and_fifo1(
input pclk,//摄像头时钟
input wr_clk,//写时钟(clk_differ)
//input rd_finish,//一次读完的标记
input rst_0,//(复位)
input rd_clk,//ram clk
input con,//ram先存一帧
input [3:0]data,//differ
input rd_en,//读使能
output [3:0]dout,//传给sram
output reg [31:0]count//计数fifo里有几个differ
    );
    //wire rst;
    //assign rst = ~rst_0;
    reg wr_en;
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        wr_en <= 1'b0;
        else if(con == 1'b0)
        wr_en <= 1'b0;
        else
        wr_en <= 1'b1;
    end
    
    //进行一次跨时钟域处理;判断rd_en下降沿来到，fifo中数据数目减去
    reg rd_en0;
    reg rd_en1;
    reg rd_en2;
    wire rd_flag;
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            rd_en0 <= 1'b0;
            rd_en1 <= 1'b0;
            rd_en2 <= 1'b0;
        end
        else
        begin
            rd_en0 <= rd_en;
            rd_en1 <= rd_en0;
            rd_en2 <= rd_en1;
        end 
    end
    
    assign rd_flag = (~rd_en1)&rd_en2;
    
    
    //reg [31:0]count;//计数写入多少个differ
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        count <= 'd0;
        else if(con == 1'b0)
        count <= 'd0;
        else if(rd_flag == 1'b1)
        count <= count - 'd320;
        else if(wr_clk == 1'b1)
        count <= count + 'd1;
    end
    
    fifo_generator_0 f1(
       // .rst(rst),
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .din(data),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .dout(dout)
    );
    
endmodule
