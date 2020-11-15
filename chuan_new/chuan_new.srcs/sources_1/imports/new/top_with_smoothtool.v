module top_with_smoothtool(
input clk,
input rst_0,
input pclk,//cam
input href,//cam
input vsync,//cam
input [7:0]d,//cam
inout sda1,//sccb
output scl1,//sccb
output dvp_reset,
//output xclk,
output pwdn,
output xclk,

output [3:0]red,
output [3:0]green,
output [3:0]blue,
//input clk_100m,
//input clk_vga,
//input clk_50m,
output c_t,
output h_t,
//output reg led,
output  [3:0]led1,
output  [3:0]led2,
output fall,




////////////////////////////////////////////////GSM模块

    input GPRS_rx,   //GPRS接收指令  连GSM模块
//    output [7:0]GPRS_cmd,///命令
    output  gsm_tx,  //GPRS发送，连GSM模块
   
///////////////////////////////////////////////////机器人   
    input down,
    input dingous,
    output robot_pwm,
  
//////////////////////////////////////////////////语音识别
 
    input rs232_rx,     //语音识别模块发送指令；//
  
////////////////////////////////////////语音播报

   output rs232_tx ,    //发送指令到语音播放模块；//

///////////////////////////////////////窗户舵机

   output pwm_L,
   output pwm_R,
//////////////////////////////////////////门舵机
   output pwm_door, 
///////////////////////////////////////以太网数据发送使能
  
    output  W5500_RST,
    output   Spi_Ce,
    output Spi_Clk,
    output Spi_Mosi,
    input Spi_Miso,
   
///////////////////////////////////////////////////指纹识别
   
    input data_in,
	output data_out,
	
/////////////////////////////////////////////////////传感器

    input fire,
    input CO,
    input CH4,
    input rain,
	
/////////////////////////////////////////////////////RTC实时时钟

	output scl,
    inout sda,
	output [3:0] dtube_cs_n,
	output [6:0] dtube_data,

/////////////////////////////////////////////////////////风速传感器
	output scl_speed,
    inout sda_speed,
    output window_down,
   // output [4:0]wind_speed,
    
///////////////////////////////////////////////////////////窗帘信号

    output  [1:0]out1, //窗帘1信号//
    output  [1:0]out2,//窗帘2信号 //
    
//////////////////////////////////////////////////////串口屏与温湿度

    inout data,//
    input serial_data_rx,//
    output serial_data_tx,//
    output [4:0]wind_speed
    );
        //wire [4:0]wind_speed;
        wire clk_50m;
        wire clk_100m;
        wire clk_vga;
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
         
         
         
          wire cmd_end;
          
          wire  [1:0] led;
            
          ////////////////////////////////////////////////语音播报
              wire send_en_1;
              wire send_en_2;
              
              //wire cmd_end;
              
          /////////////////////////////////////////////////挂断电话
              wire tele_cancel;
              
          /////////////////////////////////////窗帘信号
              wire key1_p;//窗帘1  打开 
              wire key2_p;//窗帘2  打开
              wire key1_n;////窗帘1  关闭 
              wire key2_n;//窗帘2  关闭*/
          
          ///////////////////////////////////////W5500以太网模块
              wire [47:0]W5500_RX_data;
              wire w5500_rx_flag;
              wire en;
              wire send_data_valid;
              wire [15:0]w5500_din;
               
          //////////////////////////////////////////命令
               wire [3:0]LD3320_cmds;
               wire [4:0]JQ8900_cmds_tx;
               wire [3:0]senser_cmds;
               wire [3:0]window_cmds;
               wire [3:0]GSM_cmds;//1234 打电话  56 发短信，GPRS  
               wire [3:0]curtain_cmds;
               wire [7:0]GPRS_cmd;
                    
          ////////////////////////////////////////串口屏     
              wire [3:0] call;
              wire  [3:0]window_L;
              wire  [3:0]window_R;
              wire  [2:0]curtain_1;
              wire  [2:0]curtain_2;
              
             wire [3:0]curtain_cmds1;
             wire [3:0]window_cmds1;
         clk_wiz_0(
         .clk_100m(clk_100m),
         .clk_vga(clk_vga),
         .clk_50m(clk_50m),
         .xclk(xclk),
         .clk_in1(clk)
         );
         
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
                .dvp_reset_flag(dvp_reset_flag)//此时可以开始sccb操作
                );
          
          wire done;
          rom_and_sccb r1(
                    .clk(clk_50m),
                    .rst_mix(rst_new),
                    //input [7:0]com_add,
                    //output reg [5:0]rom_add,
                    .dvp_reset(dvp_reset_flag),
                    .sda(sda1),
                    .done(done),
                    .scl(scl1)
                        );
          
          wire [11:0]rgb;
          wire rgb_flag;
          dvp_5640 d1(
                            .pclk(pclk),     
                            //input clk,
                            .href(href),        //异步信号，防止亚稳态;
                            .vsync(vsync),    //异步信号，防止亚稳态;
                            .rst_mix(rst_new),
                            .d(d),
                            .dvp_reset(dvp_reset_flag),
                            .done(done),
                            //output reg dvp_reset,
                            .rgb(rgb),
                            .led(led2),
                            .rgb_flag(rgb_flag)//一个rgb像素收集完的标志
                            //output reg vsync_flag,//一帧收集完的标志
                            //output reg dvp_reset_flag
                            //output [3:0]led
                            //output reg dtf_en
                                );
                                
         grey_new        g1(
                                    .pclk(pclk),
                                    .rst_0(rst_new),
                                    .rgb_flag(rgb_flag),//与摄像头拼接时，此接口用于指示是否一个像素已经拼接好
                                    .rgb_565(rgb),
                                    .grey(grey),
                                    .complete(complete)
                                      );
                            
                            wire [3:0]grey_a;          
           middel a1(//average
           .rst_0(rst_new),
           .grey(grey),
           .complete(complete),
           .grey_a(grey_a)
           );
           
           reduce r2(
                                           .pclk(pclk),
                                           .rst_mix(rst_new),
                                           .complete(complete),
                                           .grey(grey_a),///////////////////////////////////////////////////////,
                                             // input href,
                                             // input vsync,//高电平有pixel
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
                                              .pclk(pclk),//摄像头的时钟
                                              .rst_0(rst_new),
                                              //input [1:0]count_r,//指示灰度像素哪一行有效;
                                              //input l_o,//一行结束的标志
                                              .complete(complete),//一个灰像素好了的标志
                                              .dina(dina),//reduce 存储的像素
                                              .douta(douta),//ram读优先时的输出
                                              .con(con),//第一帧存储完的标志
                                              .save(save),
                                             // .r(r),
                                              //.c(c),
                                              .nothing(nothing),
                                              .clk_differ(clk_differ),
                                              .clear(clear)
                                                  );
                                                  
                                             wire change;
                                                     dvp_to_fifo0 d3(
                                                     .pclk(pclk),//摄像头时钟
                                                     .clk_differ(clk_differ),//写时钟(clk_differ)////////////////////////////////////
                                                     //input rd_finish,//一次读完的标记
                                                     .rst_0(rst_new),//(复位)
                                                     .rd_clk(clk_100m),//ram clk  100m
                                                     .con(con),//ram先存一帧
                                                     .data(save),//differ/////////////////////////////////////////////////////
                                                     .rd_en_fifo0(rd_en_fifo0),//读使能
                                                     .dout_f0(dout_f0),//传给ram
                                                     .change(change),
                                                     .f0_count(f0_count),//计数fifo里有几个differ
                                                     .clear(clear)
                                                     );      
                                                     
                                                     
                                               control_center c1(
                                                         .clk(clk_100m),//100m
                                                         .rst_0(rst_new),
                                                         .f0_count(f0_count),//fifo0 的 data 超过320才读
                                                         .dout_f0(dout_f0),//fifo0的输出
                                                         .dout_f1(dout_f1),//fifo1的输出
                                                         .ram_r_b(ram_r_b),//读ram的信号
                                                         .vga_finished(vga_finished),//vga读完一帧的信号
                                                         //input [3:0]dout,//ram的输出
                                                         .con(con),
                                                         .rd_en_f0(rd_en_fifo0),//fifo0的读信号
                                                         .wr_en_f1(wr_en_f1),//fifo1的写信号
                                                         .web(web),
                                                         .adder(adderb),
                                                         .din(din),
                                                         .change(change)
                                                         );
                                                 wire clk_delay;
                                                 wire rd_en_f1;
                                                             fifo_to_vga f2(
                                                             .con(con),
                                                             .clk_wr(clk_100m),
                                                             .clk_rd(clk_delay),
                                                             //input rd_en,
                                                             .wr_en_f1(wr_en_f1),
                                                             .data(doutb),
                                                             .rst_0(rst_new),
                                                             .vga_finished(vga_finished),
                                                             .read_begin(read_begin),//rd_en
                                                             .ram_r_b(ram_r_b),
                                                             .dout(dout_vga)
                                                             );
                                                             
                                                             wire [31:0]gravity0;
                                                             wire [31:0]gravity1;
                                                             smooth_tool s2(
                                                             .clk_delay(clk_delay),
                                                             .clk_25m(clk_vga),
                                                             .rst_mix(rst_new),
                                                             .dout(dout_vga),//fifo
                                                             .con(con),
                                                             .red(red),
                                                             .green(green),
                                                             .blue(blue),
                                                             .c_t(c_t),//场同步
                                                             .h_t(h_t),//行同步
                                                             .read_begin(read_begin),
                                                             .vga_finashed(vga_finished),
                                                             //.led(led1),
                                                             .gravity0(gravity0),
                                                             .gravity1(gravity1),
                                                             .fall(led1[3])
                                                             );
                                                 /* vga v1(
                                                                 .clk_vga(clk_vga),
                                                                 .rst_mix(rst_new),
                                                                 .dout(dout_vga),//fifo
                                                                 //input vga_begin,//sdram发来的控制vga是否工作的信号;
                                                                 //input vsync,
                                                                 .con(con),
                                                                 .red(red),
                                                                 .green(green),
                                                                 .blue(blue),
                                                                 .c_t(c_t),//场同步
                                                                 .h_t(h_t),//行同步
                                                                 .read_begin(read_begin),
                                                                 //output reg clk_vga
                                                                 //output reg clk_vga//,
                                                                 .vga_finashed(vga_finished)
                                                                 );*/
                                                                 
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
                                                                            
                                                     
                                                     /*always@(posedge clk_vga or negedge rst_new)
                                                     begin
                                                        if(rst_new == 1'b0)
                                                        begin
                                                            led1 <= 4'b0;
                                                        end
                                                        else if(fall == 1'b1)
                                                        begin
                                                            led1 <= 4'b1111;
                                                        end
                                                        else
                                                        begin
                                                            led1 <= led1;
                                                        end
                                                     end*/
                                                     
                                                      gsm_top u1(
                                                        .clk(clk_50m),
                                                        .rst_n(rst_new),
                                                        .GSM_cmds(GSM_cmds),
                                                        .gsm_tx(gsm_tx),
                                                        .tele_cancel(tele_cancel),
                                                        .GPRS_rx(GPRS_rx),
                                                        .GPRS_cmd(GPRS_cmd)
                                                        );
                                                       
                                                     
                                                        
                                                        JQ8900_TOP u2(
                                                        .clk(clk_50m),
                                                        .rst_n(rst_new),
                                                        .rs232_tx(rs232_tx),
                                                        .cmds(JQ8900_cmds_tx),            //输入指令 包含两个个部分。LD3320和传感器
                                                        .send_en_1(send_en_1),
                                                        .send_en_2(send_en_2),
                                                        .cmd_end(cmd_end)
                                                        );
                                                        
                                                         LD3320_top u3(
                                                        .clk(clk_50m),
                                                        .rst_n(rst_new),
                                                        .rs232_rx(rs232_rx),
                                                        .LD3320_cmds(LD3320_cmds),
                                                        .send_en_1(send_en_1),
                                                        .cmd_end(cmd_end)
                                                          );
                                                          
                                                          
                                                          
                                                          JQ8900_cmds_tx u4(
                                                          .clk(clk_50m),
                                                          .rst_n(rst_new),
                                                          .LD3320_cmds(LD3320_cmds),
                                                          .senser_cmds(senser_cmds),
                                                          .JQ8900_cmds_tx(JQ8900_cmds_tx)
                                                    
                                                        );
                                                        
                                                       
                                                        senser_cmds u5(
                                                        .clk(clk_50m),
                                                        .rst_n(rst_new),
                                                        .fire(!fire),
                                                        .fall(led1[3]),
                                                        .CO(!CO),
                                                        .CH4(!CH4),
                                                        .rain(!rain),
                                                        .wind(window_down),
                                                        .finger(led),
                                                        .senser_cmds(senser_cmds),
                                                        .send_en_2(send_en_2)
                                                        );
                                                            
                                                      pwm u6(
                                                      .clk(clk_50m),
                                                      .rst_n(rst_new),
                                                      .pwm_L(pwm_L),
                                                      .pwm_R(pwm_R),
                                                      .window_cmds(window_cmds),
                                                      .window_cmds1(window_cmds1),
                                                      .LD3320_cmds(LD3320_cmds),
                                                       .senser_cmds(senser_cmds)
                                                        );
                                                    
                                                             
                                                                
                                                     W5500_control u7(
                                                            .clk_in(clk_100m),
                                                            .send_data(w5500_din),
                                                            .send_data_valid(send_data_valid),
                                                            .W5500_RST(W5500_RST),
                                                            .Spi_Ce(Spi_Ce),
                                                            .Spi_Clk(Spi_Clk),
                                                            .Spi_Mosi(Spi_Mosi),
                                                            .Spi_Miso(Spi_Miso),
                                                             .W5500_RX_command(W5500_RX_data),
                                                            .en(en),
                                                            .w5500_rx_flag(w5500_rx_flag)
                                                        ); 
                                                    
                                                    dialog u8(
                                                        .clk(clk_100m),
                                                        .rst_n(rst_new),
                                                        .rx_data(W5500_RX_data),
                                                        .tx_data(w5500_din),
                                                        .send_data_valid(send_data_valid),
                                                        .en(en),
                                                        .w5500_rx_flag(w5500_rx_flag)
                                                        ); 
                                                        
                                                        
                                                    robot u9(
                                                      .clk(clk_100m),
                                                      .rst_n(rst_new),
                                                      .down(down),
                                                      .pwm(robot_pwm),
                                                      .dingous(dingous)
                                                        ); 
                                                     
                                                      
                                                    finger u10(
                                                        .clk(clk_50m),
                                                        .rst(rst_new),
                                                        .data_in(data_in),    
                                                        .led(led),
                                                        .data_out(data_out)
                                                        );  
                                                    
                                                    
                                                    RTC u11(
                                                        .clk(clk_50m),
                                                        .rst_n(rst_new),
                                                        .sda(sda),
                                                        .scl(scl),
                                                        .dtube_cs_n(dtube_cs_n),
                                                        .dtube_data(dtube_data)    
                                                        );
                                                       
                                                    wind_speed  u12(
                                                        .clk(clk_50m),
                                                        .rst_n(rst_new),
                                                        .scl(scl_speed),
                                                        .sda(sda_speed),
                                                        .window_down(window_down),
                                                        .wind_speed(wind_speed)
                                                        );
                                                       
                                                     motor u13(
                                                        .clk(clk_100m),
                                                        .rst_n(rst_new),
                                                        .key1_p(key1_p),
                                                        .key2_p(key2_p),
                                                        .key1_n(key1_n),
                                                        .key2_n(key2_n),
                                                        .out1(out1),
                                                        .out2(out2)
                                                        //.key_state1_n(key_state1_n),
                                                        //.key_state1_p(key_state1_p),
                                                        //.key_state2_p(key_state2_p),
                                                        //.key_state2_n(key_state2_n)
                                                        
                                                        );
                                                        
                                                    door u14(
                                                        .clk(clk_100m),
                                                        .rst_n(rst_new),
                                                        .pwm(pwm_door),
                                                        .open(led)
                                                        );
                                                        
                                                    curtain u15(
                                                        .clk(clk_50m),
                                                        .rst_n(rst_new),
                                                        .curtain_cmd(curtain_cmds),
                                                        .curtain_cmds1(curtain_cmds1),
                                                        .LD3320_cmds(LD3320_cmds),
                                                        .key1_p(key1_p),
                                                        .key2_p(key2_p),
                                                        .key1_n(key1_n),
                                                        .key2_n(key2_n)
                                                        );
                                                        
                                                    main_control u16(
                                                        .clk(clk_50m),
                                                        .rst_n(rst_new),
                                                        .massage(),
                                                        .call(call),
                                                        .window_L(window_L),
                                                        .window_R(window_R),
                                                        .curtain_1(curtain_1),
                                                        .curtain_2(curtain_2),
                                                        .GSM_cmds(GSM_cmds),
                                                        .window_cmds(window_cmds),
                                                        .window_cmds1(window_cmds1),
                                                        .curtain_cmds(curtain_cmds),
                                                        .curtain_cmds1(curtain_cmds1),
                                                        .tele_cancel(tele_cancel)
                                                        );
                                                    
                                                    uart_dis_top u17(
                                                        .clk_25M(clk_vga), 
                                                        .clk_50M(clk_50m),
                                                        .rst_n(rst_new),
                                                        .data(data),
                                                        .serial_data_tx(serial_data_tx),
                                                        .serial_data_rx(serial_data_rx),
                                                        .massage(),
                                                        .call(call),
                                                        .window_L(window_L),
                                                        .window_R(window_R),
                                                        .curtain_1(curtain_1),
                                                        .curtain_2(curtain_2)
                                                        );
                                                        
                                                        
endmodule