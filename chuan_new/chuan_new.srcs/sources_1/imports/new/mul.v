`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/06 20:18:19
// Design Name: 
// Module Name: mul
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


module reduce(
    input pclk,
    input rst_mix,
    input complete,
    input [11:0]grey,
   // output  wea,      // input wire [0 : 0] wea
    output reg [11:0]dina,    // input wire [11 : 0] dina
    //output  web,      // input wire [0 : 0] web
    //output reg [11:0]dinb,    // input wire [11 : 0] dinb
    output reg [16:0]adder,
    output reg [3:0]led,
    output reg [3:0]led2
    );
       reg [31:0]pix_r;
       reg [31:0]pix_l;
       reg l_o;
       reg over;
        always@(posedge pclk or negedge rst_mix)
        begin
            if(rst_mix == 1'b0)
            begin
                pix_l <= 'd0;
                l_o <= 1'b0;
            end
            else if(complete == 1'b1)
            begin
                //if(pix_r == 'd479 && pix_l == 'd635)//
                //begin//
                    //pix_l <= 'd0;//
                    //l_o <= 1'b0;//
                //end
                if(pix_l == 'd639)
                begin
                    pix_l <= 'd0;
                    l_o <= 1'b1;
                end
                else
                begin
                    pix_l <= pix_l+'d1;
                    l_o <= 1'b0;
                end
            end
            else
            begin
                pix_l <= pix_l;
                l_o <= 1'b0;
            end
        end
        
        always@(posedge pclk or negedge rst_mix)
        begin
            if(rst_mix == 1'b0)
            begin
                pix_r <= 'd0;
                over <= 1'b0;
                //led2 <= 1'b0;
            end
            else if(pix_r == 'd479 && pix_l == 'd639&&complete == 1'b1)//639
            begin
                pix_r <= 'd0;
                over <= 1'b1;
                //led2 <= led2 + 'd1;
            end
            else if(pix_l == 'd639&&complete == 1'b1)
            begin
                pix_r <= pix_r + 'd1;//多加了一次   使pix_r变成639的complete之后那个complete为0且pclk上升的时期加一次，下一个complete为1时加了一次。
                over <= 1'b0;
                //led2 <= led2;
            end
            else
            begin
                pix_r <= pix_r;
                over <= 1'b0;
                //led2 <= led2;
            end
        end
        /*reg h_1;
        reg h_2;
        wire h_c;
        always@(posedge pclk or negedge rst_mix)
        begin
            if(rst_mix==1'b0)
            begin
                h_1<=1'b0;
                h_2<=1'b0;
            end
            else
            begin
                h_1<=href;
                h_2<=h_1;
            end
        end
        assign h_c=h_2&~h_1;//d*/
        
       // reg v_1;
       // reg v_2;
       // wire up_v;
       /* always@(posedge pclk or negedge rst_mix)
        begin
            if(rst_mix == 1'b0)
            begin
                v_1 <= 1'b0;
                v_2 <= 1'b0;
            end
            else
            begin
                v_1 <= vsync;
                v_2 <= v_1;
            end
        end
        assign up_v = v_2 & ~v_1;//切换ram*/
    
    reg count_l;//列缩小两倍
    reg [1:0]count_r;//行缩小三倍
    always@(posedge pclk or negedge rst_mix)
    begin
        if(rst_mix == 1'b0)
        count_l <= 1'b0;
        else if (complete==1'b1 && count_l == 1'b1)
        count_l <= 1'b0;
        else if(l_o == 1'b1||over == 1'b1)
        count_l <= 1'b0;
        else if(complete == 1'b1)
        count_l <= count_l + 1'b1;
    end
    
    always@(posedge pclk or negedge rst_mix)
    begin
        if(rst_mix == 1'b0)
        count_r <= 2'b0;
        else if(l_o == 1'b1 && count_r == 2'b10)
        count_r <= 2'b0;
        else if(over == 1'b1)
        count_r <= 2'b0;
        else if(l_o == 1'b1)
        count_r <= count_r + 2'b01;
    end
    
    always@(posedge pclk or negedge rst_mix)
    begin
        if(rst_mix == 1'b0)
        begin
        adder <= 17'd51199;//51199
        dina <= 12'b0;
       // dinb <= 12'b0;
        led <= 3'b0;
        led2 <= 4'b0;
        end
        else if(over == 1'b1)///////////
        begin
        led <= led + 'd1;
        adder <= 17'd51199;//51199
        dina <= 'd0;
       // dinb <= 'd0;
        led2 <= led2;
        end
        else if(complete == 1'b1 && count_l == 1'b1 && count_r == 2'b0)
        begin
            if(adder == 'd51199)//51199
            begin
                adder <= 17'd0;
                dina <= grey;
                //dinb <= grey;
                led2 <= led2 + 'd1;
            end
            else
            begin
                adder <= adder + 17'd1;
                dina <= grey;
                //dinb <= grey;
                led2 <= led2;
            end
       // led <= 1'b1;
        end
       // else
       // begin
       // led <= 1'b1;
       // end
    end
    
    
    
endmodule