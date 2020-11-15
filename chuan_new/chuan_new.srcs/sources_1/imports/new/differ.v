`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/04 14:20:16
// Design Name: 
// Module Name: differ
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


module differ(
input pclk,//摄像头的时钟
input rst_0,
//input [1:0]count_r,//指示灰度像素哪一行有效;
//input l_o,//一行结束的标志
input complete,//一个灰像素好了的标志
input nothing,//第二行第三行;
input [3:0]dina,//reduce 存储的像素
input [3:0]douta,//ram读优先时的输出
input con,//第一帧存储完的标志;
//output reg [9:0]r,//行
//output reg [9:0]c,//列
output reg [3:0]save,  //帧差法的输出结果
output reg clk_differ,
output reg clear//fifo0复位
    );
    //根据波形图，为了对齐douta和灰度像素，延时两个complete，然后每个pclk上升沿时count1加一，每当count1为1时douta和灰度像素对其,此时相减
    //当（addrb+1）%320为0时，complete_count应该回到原始状态
    wire flag;
    reg [9:0]r;
    reg [2:0]count1;
     assign flag = (r == 'd319&&count1 == 'd4) ? 1'b1 : 1'b0;
    
    
    reg [1:0]complete_count;
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
            complete_count <= 'd0;
        else if(con == 1'b0)
            complete_count <= 'd0;
        else if(flag == 1'b1)
            complete_count <= 'd0;
        else if(complete == 1'b1&&nothing == 1'b0)
        begin
            if(complete_count == 'd2)
            complete_count <= complete_count;
            else
            complete_count <= complete_count + 'd1;
        end
    end
    
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        count1 <= 'd5;
        else if(con == 1'b0)
        count1 <= 'd5;
        else if(flag == 1'b1)
        count1 <= 'd5;
        /*else if(nothing == 1'b1&&count1 == 'd4)
        count1 <= 'd5;*/
        else if(complete_count == 'd2)
        begin
               if(count1 == 'd5)
               count1 <= 'd0;
               else
               begin
                    if(count1 == 'd4)
                    count1 <= 'd1;
                    else
                    count1 <= count1 + 'd1;
               end
        end
        else
            count1 <= 'd5;
    end
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //将dina与douta做差
    wire [3:0]del;
    assign del = (dina>= douta)?(dina - douta):(douta-dina);
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //每当count1为1时将del存入save,并且序号加一
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            save <= 'd0;
        end
        else if(con == 1'b0)
        begin
            save <= 'd0;
        end
        else
        begin
            if(count1 == 'd1) //&& addrb == 'd51199)
            begin
                save <= del;
                //addrb <= 'd0;
            end
            else
            begin
                save <= save;
                //addrb <= addrb + 'd1;
            end
        end
    end 
    
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        clk_differ <= 1'b0;
        else if(con == 1'b0)
        clk_differ <= 1'b0;
        else if(count1 == 'd2)
        clk_differ <= 1'b1;
        else
        clk_differ <= 1'b0;
    end
    
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            r <= 'd319;//0
        end
        else if(con == 1'b0)
        begin
            r <= 'd319;//0
        end
        else if(r == 'd319&&clk_differ == 1'b1)//count1 == 'd4)//320
        begin
            r <= 'd0;
        end
        else if(clk_differ == 1'b1)//count1
        begin
                r <= r + 'd1;
        end
        /*else if(nothing == 1'b1&&count1 == 'd4)
                begin
                    r <= 'd0;
                end*/
    end
    
    reg [9:0]c;
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            c <= 'd159;
        end
        else if(con == 1'b0)
        begin
            c <= 'd159;
        end
        else if(r == 'd319&&clk_differ == 1'b1)//count1 == 'd4)//320
        begin
            if(c == 'd159)
            c <= 'd0;
            else
            c <= c + 'd1;
        end
    end
    
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            clear <= 1'b1;
        end
        else if(con == 1'b0)
        begin
            clear <= 1'b1;
        end
        else if(c == 'd159 && r == 'd319&&complete == 1'b1)//添加clk--differ
        begin
            clear <= 1'b0;
        end
        else if(c == 'd159 && r == 'd318)//count1
        begin
            clear <= 1'b1;
        end
    end
    /////////////////////////////////////////////////////////////////////////////////////////////
    
endmodule
