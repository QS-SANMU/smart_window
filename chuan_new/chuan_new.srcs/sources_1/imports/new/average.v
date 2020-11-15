`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/28 16:58:45
// Design Name: 
// Module Name: average
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


module average(
input rst_0,
input [3:0]grey,
input complete,
output reg[3:0]grey_a
    );//使用中值滤波
    wire [3:0]q1;
    wire [3:0]q2;
    reg start;
    always@(posedge complete or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        start <= 1'b0;
        else
        start <= 1'b1;
    end
    
    connect3 c1(
    .d(grey),
    .clk(complete),
    .ce(start),
    .q1(q1),
    .q2(q2)
    );
    
    //第一步，取每一列中的最大值最小值和中间值
    reg [3:0]max_1;
    reg [3:0]mid_1;
    reg [3:0]min_1;
    always@(posedge complete or negedge rst_0)//求最大值
    begin
        if(rst_0 == 1'b0)
        begin
            max_1 <= 4'd0;
        end
        else if(q1 >= q2 && q1 >= grey)
        begin
            max_1 <= q1;
        end
        else if(q2 >= q1 && q2 >= grey)
        begin
            max_1 <= q2;
        end
        else
        begin
            max_1 <= grey;
        end
    end
    
    always@(posedge complete or negedge rst_0)//求最小
    begin
        if(rst_0 == 1'b0)
        begin
            min_1 <= 'd0;
        end
        else if(q1 <= q2 && q1 <= grey)
        begin
            min_1 <= q1;
        end
        else if(q2 <= q1 && q2 <= grey)
        begin
            min_1 <= q2;
        end
        else
        begin
            min_1 <= grey;
        end
    end
    
    always@(posedge complete or negedge rst_0)//中间值
    begin
        if(rst_0 == 1'b0)
        begin
            mid_1 <= 'd0;
        end
        else if(q1 >= q2 && q1 >= grey)
        begin
            if(q2 >= grey)
            mid_1 <= q2;
            else
            mid_1 <= grey; 
        end
        else if(q2 >= q1 && q2 >= grey)
        begin
            if(q1 >= grey)
            mid_1 <= q1;
            else
            mid_1 <= grey;
        end
        else
        begin
            if(q1 >= q2)
            mid_1 <= q1;
            else
            mid_1 <= q2;
        end
    end
    //////////////////////////////////////////////////////////////////////流水线缓存两级，使三列的最大最小值中间值都求出；
    reg [3:0]max_2;
    reg [3:0]mid_2;
    reg [3:0]min_2;
    always@(posedge complete or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            max_2 <= 4'b0;
            mid_2 <= 4'b0;
            min_2 <= 4'b0;
        end
        else
        begin
            max_2 <= max_1;
            mid_2 <= mid_1;
            min_2 <= min_1;
        end
    end
    
    reg [3:0]max_3;
    reg [3:0]mid_3;
    reg [3:0]min_3;
    always@(posedge complete or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            max_3 <= 4'b0;
            mid_3 <= 4'b0;
            min_3 <= 4'b0;
        end
        else
        begin
            max_3 <= max_2;
            mid_3 <= mid_2;
            min_3 <= min_2;
        end
    end
    
    //////////////////////////////////////////////////////////////////////////////////////第二步 找最大中的最小，中间的中间，最小的最大；
    reg [3:0]max_min;
    reg [3:0]mid_mid;
    reg [3:0]min_max;
    always@(posedge complete or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            max_min <= 4'b0;
        end
        else if(max_1 <= max_2 && max_1 <= max_3)
        begin
            max_min <= max_1;
        end
        else if(max_2 <= max_1 && max_2 <= max_3)
        begin
            max_min <= max_2;
        end
        else
        begin
            max_min <= max_3;
        end
    end
    
    always@(posedge complete or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            min_max <= 4'b0;
        end
        else if(min_1 >= min_2 && min_1 >= min_3)
        begin
            min_max <= min_1;
        end
        else if(min_2 >= min_1 && min_2 >= min_3)
        begin
            min_max <= min_2;
        end
        else
        begin
            min_max <= min_3;
        end
    end
    
always@(posedge complete or negedge rst_0)//中间值
        begin
            if(rst_0 == 1'b0)
            begin
                mid_mid <= 'd0;
            end
            else if(mid_1 >= mid_2 && mid_1 >= mid_3)
            begin
                if(mid_2 >= mid_3)
                mid_mid <= mid_2;
                else
                mid_mid <= mid_3; 
            end
            else if(mid_2 >= mid_1 && mid_2 >= mid_3)
            begin
                if(mid_1 >= mid_3)
                mid_mid <= mid_1;
                else
                mid_mid <= mid_3;
            end
            else
            begin
                if(mid_1 >= mid_2)
                mid_mid <= mid_1;
                else
                mid_mid <= mid_2;
            end
        end
        
        //////////////////////////////////////////////////////////////////////////////第三步取max_min mid_mid  min_max的中间值作为输出
        always@(posedge complete or negedge rst_0)
        begin
            if(rst_0 == 1'b0)
            begin
                grey_a <= 4'b0;
            end
            else if(max_min >= mid_mid && max_min >= min_max)
            begin
                if(mid_mid >= min_max)
                grey_a <= mid_mid;
                else
                grey_a <= min_max;
            end
            else if(mid_mid >= max_min && mid_mid >= min_max)
            begin
                if(max_min >= min_max)
                grey_a <= max_min;
                else
                grey_a <= min_max;
            end
            else
            begin
                if(mid_mid >= max_min)
                grey_a <= mid_mid;
                else
                grey_a <= max_min;
            end
        end
endmodule