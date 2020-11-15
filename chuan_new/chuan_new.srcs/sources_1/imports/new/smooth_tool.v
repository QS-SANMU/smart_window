`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/20 16:11:31
// Design Name: 
// Module Name: smooth_tool
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


module smooth_tool(
input clk_25m,
input rst_mix,
input [3:0]dout,//fifo
input con,
output [3:0] red,
output [3:0] green,
output [3:0] blue,
output c_t,//场同步
output h_t,//行同步
output read_begin,
output vga_finashed,
output clk_delay,
output [3:0]led,
output [31:0]gravity0,
output [31:0]gravity1,
output fall
    );
    wire start;
    wire etch;
    
    catch c1(
    .clk_25m(clk_25m),
    .clk_delay(clk_delay),
    .rst_mix(rst_mix),
    .dout(dout),//fifo
    .con(con),
    .read_begin(read_begin),//shiftram 开始存入
    .vga_finashed(vga_finashed),//一帧读完
    .start(start),//此刻vga应该开始工作
    .etch(etch)//结果
    );
    
    wire start1;
    wire exp;
    etching e1(//expand
    .clk_25m(clk_25m),
    .rst_mix(rst_mix),
    .con(con),
    .etch(etch),//fifo
    .start(start),
    .start1(start1),
    .exp(exp)//腐蚀结果
    );
    
    wire exp1;
    wire start2;
    expand2 e3(
     .clk_25m(clk_25m),
     .rst_mix(rst_mix),
     .con(con),
     .etch(etch),//fifo
     .start1(start1),
     .start2(start2),
     .exp(exp1)//膨胀结果
    );
    
    vga1 v1(
    .con(con),
    .clk_vga(clk_25m),
    .rst_mix(rst_mix),
    .etch(exp1),//fifo
    .start(start2),
    //input vga_begin,//sdram发来的控制vga是否工作的信号;
    //input vsync,
    .red(red),
    .green(green),
    .blue(blue),
    .c_t(c_t),//场同步
    .h_t(h_t),//行同步
    //.led(led),
    .gravity0(gravity0),
    .gravity1(gravity1),
    .fall(fall)
    );
endmodule
