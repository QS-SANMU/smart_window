`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/01 10:31:38
// Design Name: 
// Module Name: sobel
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


module sobel(
input rst_0,
input complete,
input [3:0]grey_a,
output [3:0]sobel 
    );
    
    reg start;
    always@(posedge complete or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        start <= 'd0;
        else
        start <= 1'b1;
    end
    
    wire [3:0]q1;
    wire [3:0]q2;
    
    connect_s c1(
    .d(grey_a),
    .clk(complete),
    .ce(start),
    .q1(q1),//第三列
    .q2(q2)//第一行
    );
    
    reg [3:0]s_21;
    reg [3:0]s_22;
    reg [3:0]s_23;
    always@(posedge complete or negedge rst_0)//第二列
    begin
        if(rst_0 == 1'b0)
        begin
            s_21 <= 'd0;
            s_22 <= 'd0;
            s_23 <= 'd0;
        end
        else
        begin
            s_21 <= q1;//2
            s_22 <= q2;//1
            s_23 <= grey_a;//3
        end
    end
    
    reg [3:0]s_31;
    reg [3:0]s_32;
    reg [3:0]s_33;
    always@(posedge complete or negedge rst_0)//第一列
    begin
        if(rst_0 == 1'b0)
        begin
            s_31 <= 'd0;
            s_32 <= 'd0;
            s_33 <= 'd0;
        end
        else
        begin
            s_31 <= s_21;//2
            s_32 <= s_22;//1
            s_33 <= s_23;//3
        end
    end
    
    reg signed [3:0]r_1;//第3列积和
    reg signed [3:0]r_2;//第2
    reg signed [3:0]r_3;//第1
    always@(posedge complete or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            r_1 <= 'd0;
        end
        else
        begin
            r_3 <= s_33 - s_32;
            r_2 <= 2 * s_23 - 2*s_22;
            r_1 <= grey_a - q2; 
        end
    end
    
    reg signed [3:0] l_1;
    reg signed [3:0] l_2;
    reg signed [3:0] l_3;
    always@(posedge complete or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            l_1 <= 'd0;
            l_2 <= 'd0;
            l_3 <= 'd0;
        end
        else
        begin
            l_3 <= s_33 + 2*s_31 + s_32;
            l_2 <= 'd0;
            l_1 <= (-1)*grey_a + (-2)*q1+(-1)*q2;
        end
    end
    
    reg signed [7:0]gx;
    reg signed [7:0]gy;
    always@(posedge complete or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
        gx <= 'd0;
        gy <= 'd0;
        end
        else
        begin
        gx <= r_1 + r_2 + r_3;
        gy <= l_1 + l_2 + l_3;
        end
    end
    
    reg [7:0]gx_j;
    reg [7:0]gy_j;
    always@(*)
    begin
         if(gx[7])
         gx_j <= 1 + (~gx[6:0]); 
         else
         gx_j <= gx[6:0];
    end
    
    always@(*)
    begin
             if(gy[7])
             gy_j <= 1 + (~gx[6:0]); 
            else
            gy_j <= gx[6:0];
            
    end
    assign sobel = (gx_j + gy_j) > 'd280 ? 4'hf : 4'h0;
endmodule
