`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/09 17:56:39
// Design Name: 
// Module Name: control_center
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


module control_center(
input clk,//100m
input rst_0,
input [31:0]f0_count,//fifo0 的 data 超过320才读
input [3:0]dout_f0,//fifo0的输出
input [3:0]dout_f1,//fifo1的输出
input ram_r_b,//读ram的信号
input vga_finished,//vga读完一帧的信号
input pixel_finashed,/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//input [3:0]dout,//ram的输出
input con,
output reg rd_en_f0,//fifo0的读信号
output reg wr_en_f1,//fifo1的写信号
output reg web,
output reg [17:0]adder,
output reg [3:0]din,
 output reg change
//output reg [9:0]count_w,// the num of write data;  the address of write
//output reg [9:0]count_r,//the num of read data;   the address of read
//output reg change//切换
    );
    reg pixel_finashed1;
    reg pixel_finashed2;
    reg pixel_finashed3;
    
    wire rst_n;
    assign rst_n = con & rst_0; 
    //异步信号同步化之 vga_finished
    reg vga_finished0;
    reg vga_finished1;
    reg vga_finished2;
    wire finished_d;
    wire finished_u;
////////////////////////////////////////////////////////////////////////////    
    always@(posedge clk or negedge rst_n)
    begin
        if(rst_n == 1'b0)
        begin
        pixel_finashed1 <= 1'b0;
        pixel_finashed2 <= 1'b0;
        pixel_finashed3 <= 1'b0;
        end
        else
        begin
        pixel_finashed1 <= pixel_finashed;
        pixel_finashed2 <= pixel_finashed1;
        pixel_finashed3 <= pixel_finashed2;
        end
    end
    ////////////////////////////////////////////////////////////////////
    always@(posedge clk or negedge rst_n)
    begin
        if(rst_n == 1'b0)
        begin
        vga_finished0 <= 1'b0;
        vga_finished1 <= 1'b0;
        vga_finished2 <= 1'b0;
        end
        else
        begin
        vga_finished0 <= vga_finished;
        vga_finished1 <= vga_finished0;
        vga_finished2 <= vga_finished1;
        end
    end
    assign finished_d = (~vga_finished1)&vga_finished2;
    assign finished_u = (~vga_finished2)&vga_finished1;
    //ram_r_b同步化
    reg ram_r_b0;
    reg ram_r_b1;
    reg ram_r_b2;
    wire ram_r_u;
    always@(posedge clk or negedge rst_n)
    begin
        if(rst_n == 1'b0)
        begin
        ram_r_b0 <= 1'b0;
        ram_r_b1 <= 1'b0;
        ram_r_b2 <= 1'b0;
        end
        else
        begin
        ram_r_b0 <= ram_r_b;
        ram_r_b1 <= ram_r_b0;
        ram_r_b2 <= ram_r_b1;
        end
    end
    assign ram_r_u = (~ram_r_b2)&ram_r_b1;
    
    reg [17:0]adder_w;
    reg [17:0]adder_r;
    reg [9:0]count_w;// the num of write data;  the address of write
    reg [9:0]count_r;//the num of read data;   the address of read
    parameter   idel =  3'b100;  //初始状态
    parameter write = 3'b010;//写状态
    parameter read = 3'b001;//读状态
    reg [2:0]state;
    
    reg wr_en_f2;
    always@(posedge clk or negedge rst_n)
    begin
        if(rst_n == 1'b0)
        begin
            change <= 1'b1;
            state <= idel;
            adder_w <= 'd0;//'d51199;
            adder_r <= 'd0;//'d51199;
            rd_en_f0 <= 1'b0;//fifo0的读信号
            wr_en_f2 <= 1'b0;//fifo1的写信号
            web  <= 1'b0;
            count_w <= 'd1;///////////////////////0
            count_r <= 'd0; 
            din <= 'd0;
        end
        else
        begin
            case(state)
                idel:
                begin
                    if(finished_u == 1'b1)
                    begin
                        state <= idel;
                        rd_en_f0 <= 1'b0;
                        wr_en_f2 <= 1'b0;
                        web <= 1'b0;
                        count_r <= 'd0;
                        count_w <= 'd0;
                        din <= 'd0;
                        adder_r <= 'd0;
                        adder_w <= adder_w;
                    end
                    if(finished_d == 1'b1)
                    begin
                        state <= read;
                        rd_en_f0 <= 1'b0;//fifo0的读信号
                        wr_en_f2 <= 1'b0;//fifo1的写信号
                        web  <= 1'b0;
                        count_r <= count_r + 'd1; 
                        count_w <= 'd0;
                        din <= 'd0;
                        adder_r <=  'd1;//'d0;
                        adder_w <= adder_w;
                    end
                    else if(ram_r_u == 1'b1)
                    begin
                        state <= read;
                        rd_en_f0 <= 1'b0;//fifo0的读信号
                        wr_en_f2 <= 1'b0;//fifo1的写信号
                        web  <= 1'b0;
                        count_r <= count_r + 'd1;
                        count_w <= 'd0; 
                        din <= 'd0;
                        adder_r <= adder_r + 'd1;
                        adder_w <= adder_w;
                    end
                    else if(vga_finished2 == 1'b1 && f0_count >= 'd320)//160
                    begin
                         wr_en_f2 <= 1'b0;//
                         count_r <= 'd0;
                         count_w <= count_w;//0
                         rd_en_f0 <= 1'b1;
                         web <= 1'b1;
                         din <= dout_f0;
                         state <= write;
                         adder_r <= adder_r;
                         
                         //if(adder_w == 'd51199)
                         //adder_w <= 'd0;
                         //else
                         //adder_w <= adder_w+'d1;
                         adder_w <= adder_w;
                         //adder_r <= adder_r;
                    end
                    else if(pixel_finashed3 == 1'b1 && f0_count >= 'd320)
                    begin
                        wr_en_f2 <= 1'b0;//
                        count_r <= 'd0;
                        count_w <= count_w;//0
                        rd_en_f0 <= 1'b1;
                        web <= 1'b1;
                        din <= dout_f0;
                        state <= write;
                        adder_r <= adder_r;
                                             
                                             //if(adder_w == 'd51199)
                                             //adder_w <= 'd0;
                                             //else
                                             //adder_w <= adder_w+'d1;
                        adder_w <= adder_w;
                                             //adder_r <= adder_r;
                    end
                    else
                    begin
                        rd_en_f0 <= 1'b0;//fifo0的读信号
                        wr_en_f2 <= 1'b0;//fifo1的写信号
                        web  <= 1'b0;
                        count_w <= count_w;//0
                        count_r <= 'd0; 
                        din <= 'd0;
                        adder_r <= adder_r;
                        adder_w <= adder_w;
                    end
                end
                
                read:
                    begin
                        if(adder_r == 'd51199 || finished_u == 1'b1)
                        begin
                            if(f0_count >= 'd320)//160
                            begin
                                 wr_en_f2 <= 1'b1;//
                                 count_r <= 'd0;
                                 count_w <= 'd0;
                                 rd_en_f0 <= 1'b1;
                                 web <= 1'b1;
                                 din <= dout_f0;
                                 state <= write;
                                 //adder_w <= adder_w+'d1;
                                 adder_w <= adder_w;
                                 adder_r <= 'd0;
                            end
                            else
                            begin
                                wr_en_f2 <= 1'b1;
                                count_r <= 'd0;
                                count_w <= 'd0;
                                rd_en_f0 <= 1'b0;
                                web <= 1'b0;
                                din <= 'd0;
                                state <= idel;
                                adder_w <= adder_w;
                                adder_r <= 'd0;
                            end
                        end
                        else if(count_r == 'd320 || finished_u == 1'b1)//160
                        begin
                            if(f0_count >= 'd320)//160
                            begin
                                wr_en_f2 <= 1'b1;//
                                count_r <= 'd0;
                                count_w <= 'd0;
                                rd_en_f0 <= 1'b1;
                                web <= 1'b1;
                                din <= dout_f0;
                                state <= write;
                                //adder_w <= adder_w+'d1;
                                adder_w <= adder_w;
                                adder_r <= adder_r;
                            end
                            else
                            begin
                                 wr_en_f2 <= 1'b1;
                                 count_r <= 'd0;
                                 count_w <= 'd0;
                                 rd_en_f0 <= 1'b0;
                                 web <= 1'b0;
                                 state <= idel;
                                 din <= 'd0;
                                 adder_w <= adder_w;
                                 adder_r <= adder_r;
                            end
                        end
                        else
                        begin
                            wr_en_f2 <= 1'b1;
                            count_r <= count_r + 'd1;
                            count_w <= 'd0;
                            rd_en_f0 <= 1'b0;
                            web <= 1'b0;
                            din <= 'd0;
                            adder_w <= adder_w;
                            adder_r <= adder_r + 'd1;
                        end
                    end
                    
                write:
                    begin
                        if(adder_w == 'd51199)
                        begin
                            wr_en_f2 <= 1'b0;
                            count_r <= 'd0;
                            count_w <= 'd1;////////////////////////////////////0
                            rd_en_f0 <= 1'b0;
                            web <= 1'b0;
                            din <= 'd0;
                            state <= idel;
                            adder_w <= 'd0;
                            adder_r <= adder_r;   
                            change <= ~change;
                        end
                       /* else if(count_w == 'd319)
                        begin
                            wr_en_f1 <= 1'b0;
                            count_r <= 'd0;
                            count_w <= count_w + 'd1;
                            rd_en_f0 <= 1'b1;
                            web <= 1'b1;
                            din <= dout_f0;
                            adder_w <= adder_w;
                            adder_r <= adder_r;
                        end*/
                        else if(count_w == 'd320)//159      319
                        begin
                            wr_en_f2 <= 1'b0;
                            count_r <= 'd0;
                            count_w <= 'd0;
                            rd_en_f0 <= 1'b0;
                            web <= 1'b0;
                            din <= 'd0;
                            state <= idel;
                            //adder_w <= adder_w;
                            adder_w <= adder_w;////////////////////////////
                            adder_r <= adder_r;
                        end
                        else
                        begin
                             wr_en_f2 <= 1'b0;
                             count_r <= 'd0;
                             count_w <= count_w + 'd1;
                             rd_en_f0 <= 1'b1;
                             web <= 1'b1;
                             din <= dout_f0;
                             adder_w <= adder_w + 'd1;
                             adder_r <= adder_r;
                        end
                    end
                 
                 default:
                 begin
                    state <= idel;
                 end
           endcase
        end
    end
   //assign adder = (state == write) ? ( (change == 1'b0) ? (adder_w + 'd51200) : (adder_w + 'd102400) ) : ( (state == read) ? ( (change == 1'b0) ? (adder_r + 'd102400) : (adder_r + 'd51200) ) : 'd0 );
    always@(posedge clk or negedge rst_n)
    begin
        if(rst_n == 'd0)
        begin
            adder <= 'd0;
        end
        else if(change == 1'b0)
        begin
            if(state == write)
            adder <= adder_w + 'd51200;
            else
            adder <= adder_r + 'd102400;
        end
        else if(change == 1'b1)
        begin
            if(state == write)
            adder <= adder_w + 'd102400;
            else
            adder <= adder_r + 'd51200;
        end
    end
    
    //reg wr_en_f1;//对wr_en延时一拍;
    always@(posedge clk or negedge rst_n)
    begin
        if(rst_n == 'd0)
        wr_en_f1 <= 1'b0;
        else
        wr_en_f1 <= wr_en_f2;
    end
endmodule
