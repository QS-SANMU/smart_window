`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 16:36:19
// Design Name: 
// Module Name: bps_tx
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


module bps_tx(
    input clk,
    input rst,
    input tx_en,

    output reg tx_sel_data,
    output reg [3:0] tx_num
    );

    parameter bps_cnt_end = 'd867;
    parameter bps_cnt_mid = 'd433;

    reg flag;

    always@(posedge clk or negedge rst)
    if(!rst)
        flag <= 0;
    else if(tx_num == 'd10)
        flag <= 0;
    else if(tx_en)
        flag <= 1;
    else
        flag <= flag;


    reg [12:0] cnt;

    always@(posedge clk or negedge rst)
    if(!rst)
        cnt <= 'd0;
    else if(flag && (cnt == bps_cnt_end))
        cnt <= 'd0;
    else
        cnt <= cnt + 1'b1;
    
    always@(posedge clk or negedge rst)
    if(!rst)
        tx_sel_data <= 0;
    else if(flag && (cnt == bps_cnt_mid))
        tx_sel_data <= 1;
    else
        tx_sel_data <= 0;

    always@(posedge clk or negedge rst)
    if(!rst)
        tx_num <= 'd0;
    else if(tx_num == 'd10)
        tx_num <= 'd0;
    else if(flag && tx_sel_data)
        tx_num <= tx_num + 1'b1;
    else
        tx_num <= tx_num;


endmodule

