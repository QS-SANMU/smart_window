`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/14 19:51:51
// Design Name: 
// Module Name: top_all
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


module top_all(
input clk,
input rst_0,
input pclk,//cam
input href,//cam
input vsync,//cam
input [7:0]d,//cam
inout sda,//sccb
output scl,//sccb
output dvp_reset,
//output xclk,
output pwdn,
output xclk,

output [3:0]red,
output [3:0]green,
output [3:0]blue,
output c_t,
output h_t,
output reg led,
output  [3:0]led1,
output  [3:0]led2
    );
    
        wire clk_100m;
        wire clk_vga;
        wire clk_50m;
        clk_wiz_0 c2 (
        .clk_100m(clk_100m),
        .clk_vga(clk_vga),
        .clk_in1(clk),
        .clk_50m(clk_50m),
        .xclk(xclk)
        );
        
        wire [3:0]save;
        wire [3:0]dina;
        wire [17:0]adder;
        wire [3:0]douta;
        wire con;
        wire wea;
        wire [3:0]grey;
        wire complete;
        wire nothing;
        assign wea = 1'b1;
            
         wire [31:0]f0_count;
         wire [3:0]dout_f0;
         wire rd_en_fifo0;
            
         wire [3:0]dout_f1;
         wire ram_r_b;
         wire vga_finished;
         wire wr_en_f1;
         wire web;
         wire [17:0]adderb;
         wire [3:0]din;
            
         wire [3:0]doutb;
         wire read_begin;
         wire [3:0]dout_vga;
         
         wire rst_new;
         shake s1(
             .clk(clk_50m),
             .an(rst_0),
             .an_new(rst_new)
             );
          
          wire dvp_reset_flag;
          ov5640_charge o1(
                .clk(clk_50m),
                .rst_mix(rst_new),
                .dvp_reset(dvp_reset),
                .pwdn(pwdn),
                .dvp_reset_flag(dvp_reset_flag)//��ʱ���Կ�ʼsccb����
                );
          
          wire done;
          rom_and_sccb r1(
                    .clk(clk_50m),
                    .rst_mix(rst_new),
                    //input [7:0]com_add,
                    //output reg [5:0]rom_add,
                    .dvp_reset(dvp_reset_flag),
                    .sda(sda),
                    .done(done),
                    .scl(scl)
                        );
          
          wire [11:0]rgb;
          wire rgb_flag;
          dvp_5640 d1(
                            .pclk(pclk),     
                            //input clk,
                            .href(href),        //�첽�źţ���ֹ����̬;
                            .vsync(vsync),    //�첽�źţ���ֹ����̬;
                            .rst_mix(rst_new),
                            .d(d),
                            .dvp_reset(dvp_reset_flag),
                            .done(done),
                            //output reg dvp_reset,
                            .rgb(rgb),
                            .led(led2),
                            .rgb_flag(rgb_flag)//һ��rgb�����ռ���ı�־
                            //output reg vsync_flag,//һ֡�ռ���ı�־
                            //output reg dvp_reset_flag
                            //output [3:0]led
                            //output reg dtf_en
                                );
                                
         grey_new        g1(
                                    .pclk(pclk),
                                    .rst_0(rst_new),
                                    .rgb_flag(rgb_flag),//������ͷƴ��ʱ���˽ӿ�����ָʾ�Ƿ�һ�������Ѿ�ƴ�Ӻ�
                                    .rgb_565(rgb),
                                    .grey(grey),
                                    .complete(complete)
                                      );
                                      
           reduce r2(
                                           .pclk(pclk),
                                           .rst_mix(rst_new),
                                           .complete(complete),
                                           .grey(grey),
                                             // input href,
                                             // input vsync,//�ߵ�ƽ��pixel
                                           .dina(dina),    // input wire [11 : 0] dina
                                              //output reg [11:0]dinb,    // input wire [11 : 0] dinb
                                           .adder(adder),
                                              //output reg [3:0]led,
                                              //output reg [3:0]led2,
                                            .con(con),
                                            .nothing(nothing)
                                          );
                                          
                                              wire clk_differ;
                                              wire clear; 
                                              differ d2(
                                              .pclk(pclk),//����ͷ��ʱ��
                                              .rst_0(rst_new),
                                              //input [1:0]count_r,//ָʾ�Ҷ�������һ����Ч;
                                              //input l_o,//һ�н����ı�־
                                              .complete(complete),//һ�������غ��˵ı�־
                                              .dina(dina),//reduce �洢������
                                              .douta(douta),//ram������ʱ�����
                                              .con(con),//��һ֡�洢��ı�־
                                              .save(save),
                                             // .r(r),
                                              //.c(c),
                                              .nothing(nothing),
                                              .clk_differ(clk_differ),
                                              .clear(clear)
                                                  );
                                                  
                                             wire change;
                                                     dvp_to_fifo0 d3(
                                                     .pclk(pclk),//����ͷʱ��
                                                     .clk_differ(clk_differ),//дʱ��(clk_differ)////////////////////////////////////
                                                     //input rd_finish,//һ�ζ���ı��
                                                     .rst_0(rst_new),//(��λ)
                                                     .rd_clk(clk_100m),//ram clk  100m
                                                     .con(con),//ram�ȴ�һ֡
                                                     .data(save),//differ/////////////////////////////////////////////////////
                                                     .rd_en_fifo0(rd_en_fifo0),//��ʹ��
                                                     .dout_f0(dout_f0),//����ram
                                                     .change(change),
                                                     .f0_count(f0_count),//����fifo���м���differ
                                                     .clear(clear)
                                                     );      
                                                     
                                               wire pixel_finashed;
                                               control_center c1(
                                                         .clk(clk_100m),//100m
                                                         .rst_0(rst_new),
                                                         .f0_count(f0_count),//fifo0 �� data ����320�Ŷ�
                                                         .dout_f0(dout_f0),//fifo0�����
                                                         .dout_f1(dout_f1),//fifo1�����
                                                         .ram_r_b(ram_r_b),//��ram���ź�
                                                         .vga_finished(vga_finished),//vga����һ֡���ź�
                                                         //input [3:0]dout,//ram�����
                                                         .con(con),
                                                         .rd_en_f0(rd_en_fifo0),//fifo0�Ķ��ź�
                                                         .wr_en_f1(wr_en_f1),//fifo1��д�ź�
                                                         .web(web),
                                                         .adder(adderb),
                                                         .din(din),
                                                         .change(change),
                                                         .pixel_finashed(pixel_finashed)
                                                         );
                                                         
                                                         wire clk_delay;
                                                 wire rd_en_f1;
                                                             fifo_to_vga f2(
                                                             .con(con),
                                                             .clk_wr(clk_100m),
                                                             .clk_rd(clk_delay),//clk_vga
                                                             //input rd_en,
                                                             .wr_en_f1(wr_en_f1),
                                                             .data(doutb),
                                                             .rst_0(rst_new),
                                                             .vga_finished(vga_finished),
                                                             .read_begin(read_begin),//rd_en
                                                             .ram_r_b(ram_r_b),
                                                             .dout(dout_vga)
                                                             );
                                                             
                                                  vga_fix v1(//vga
                                                                 .clk_delay(clk_delay),//////////////
                                                                 .clk_vga(clk_vga),
                                                                 .rst_mix(rst_new),
                                                                 .dout(dout_vga),//fifo
                                                                 //input vga_begin,//sdram�����Ŀ���vga�Ƿ������ź�;
                                                                 //input vsync,
                                                                 .con(con),
                                                                 .red(red),
                                                                 .green(green),
                                                                 .blue(blue),
                                                                 .c_t(c_t),//��ͬ��
                                                                 .h_t(h_t),//��ͬ��
                                                                 .read_begin(read_begin),
                                                                 //output reg clk_vga
                                                                 //output reg clk_vga//,
                                                                 .vga_finashed(vga_finished),
                                                                 .pixel_finashed(pixel_finashed)
                                                                 );
                                                                 
                                                    ram0 r5
                                                                           (
                                                                              .clka(pclk),
                                                                              .wea(wea),
                                                                              .addra(adder),
                                                                              .dina(dina),
                                                                              .douta(douta),
                                                                              .clkb(clk_100m),
                                                                              .web(web),
                                                                              .addrb(adderb),
                                                                              .dinb(din),
                                                                              .doutb(doutb)
                                                                            );
                                            
endmodule
