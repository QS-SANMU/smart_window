`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/09 20:15:59
// Design Name: 
// Module Name: smart_window_top
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


module smart_window_top(

///////////////////////////////////////////全局时钟，复位

    input sys_clk,
    input rst_n,
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
    output [4:0]wind_speed,
    
///////////////////////////////////////////////////////////窗帘信号

    output  [1:0]out1, //窗帘1信号//
    output  [1:0]out2,//窗帘2信号 //
    
//////////////////////////////////////////////////////串口屏与温湿度

    inout data,//
    input serial_data_rx,//
    output serial_data_tx,//
    
////////////////////////////////////////////////////////判断摔倒模块*/

    /*input pclk,//dvp时钟
    input href,//dvp行信号
    input vsync,//dvp帧信号
    input [7:0]d,//像素点
    inout sda1,//sccb
    output scl1,//sccb
    output dvp_reset,//dvp复位
    output pwdn,//dvp使能
    output xclk,//dvp接收的时钟
    output [3:0]red,//像素
    output [3:0]green,//像素
    output [3:0]blue,//像素
    output h_t,//行同步
    output c_t,//场
    output fall,//摔倒
 /*   output [3:0]curtain_cmds,
    output  [2:0]curtain_1,
    output  [2:0]curtain_2,
     output key1_p,//窗帘1  打开 
    output  key2_p,//窗帘2  打开
    output key1_n,////窗帘1  关闭 
    output  key2_n,//窗帘2  关闭
    output  key_state1_p,
output key_state2_p,
output  key_state1_n,
output  key_state2_n
*/
    output  [3:0] led2,
    output cmd_end
    );
    //
   // wire [4:0]wind_speed;
///////////////////////////////////////时钟   
    wire clk100;
    wire clk50;
    wire clk25;
    wire clk24;
    
/////////////////////////////////////指纹结果  led=01表示指纹错误   led=10指纹正确
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
  
  // wire fire;
   //wire CO;
   //wire CH4;
   //wire rain;
  
  // assign fire = 0;
  // assign CO = 0;
  // assign CH4 = 0;
  // assign rain = 0;
   
   gsm_top u1(
    .clk(clk50),
    .rst_n(rst_n),
    .GSM_cmds(GSM_cmds),
    .gsm_tx(gsm_tx),
    .tele_cancel(tele_cancel),
    .GPRS_rx(GPRS_rx),
    .GPRS_cmd(GPRS_cmd)
    );
   
 
    
    JQ8900_TOP u2(
    .clk(clk50),
    .rst_n(rst_n),
    .rs232_tx(rs232_tx),
    .cmds(JQ8900_cmds_tx),            //输入指令 包含两个个部分。LD3320和传感器
    .send_en_1(send_en_1),
    .send_en_2(send_en_2),
    .cmd_end(cmd_end)
    );
    
     LD3320_top u3(
    .clk(clk50),
    .rst_n(rst_n),
    .rs232_rx(rs232_rx),
    .LD3320_cmds(LD3320_cmds),
    .send_en_1(send_en_1),
    .cmd_end(cmd_end)
      );
      
      
      
      JQ8900_cmds_tx u4(
      .clk(clk50),
      .rst_n(rst_n),
      .LD3320_cmds(LD3320_cmds),
      .senser_cmds(senser_cmds),
      .JQ8900_cmds_tx(JQ8900_cmds_tx)

    );
    
   
    senser_cmds u5(
    .clk(clk50),
    .rst_n(rst_n),
    .fire(!fire),
    .fall(fall),
    .CO(!CO),
    .CH4(!CH4),
    .rain(!rain),
    .wind(window_down),
    .finger(led),
    .senser_cmds(senser_cmds),
    .send_en_2(send_en_2)
    );
        
  pwm u6(
  .clk(clk50),
  .rst_n(rst_n),
  .pwm_L(pwm_L),
  .pwm_R(pwm_R),
  .window_cmds(window_cmds),
  .window_cmds1(window_cmds1),
  .LD3320_cmds(LD3320_cmds),
   .senser_cmds(senser_cmds)
    );

         
            
 W5500_control u7(
        .clk_in(clk100),
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
    .clk(clk100),
    .rst_n(rst_n),
    .rx_data(W5500_RX_data),
    .tx_data(w5500_din),
    .send_data_valid(send_data_valid),
    .en(en),
    .w5500_rx_flag(w5500_rx_flag)
    ); 
    
    
robot u9(
  .clk(clk100),
  .rst_n(rst_n),
  .down(down),
  .pwm(robot_pwm),
  .dingous(dingous)
    ); 
 
  
finger u10(
	.clk(clk50),
    .rst(rst_n),
	.data_in(data_in),	
	.led(led),
	.data_out(data_out)
	);  


RTC u11(
    .clk(clk50),
    .rst_n(rst_n),
    .sda(sda),
    .scl(scl),
    .dtube_cs_n(dtube_cs_n),
    .dtube_data(dtube_data)	
    );
   
wind_speed  u12(
    .clk(clk50),
    .rst_n(rst_n),
    .scl(scl_speed),
    .sda(sda_speed),
    .window_down(window_down),
    .wind_speed(wind_speed)
    );
   
 motor u13(
    .clk(clk100),
	.rst_n(rst_n),
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
    .clk(clk100),
    .rst_n(rst_n),
    .pwm(pwm_door),
    .open(led)
    );
    
curtain u15(
    .clk(clk50),
    .rst_n(rst_n),
    .curtain_cmd(curtain_cmds),
    .curtain_cmds1(curtain_cmds1),
    .LD3320_cmds(LD3320_cmds),
    .key1_p(key1_p),
    .key2_p(key2_p),
    .key1_n(key1_n),
    .key2_n(key2_n)
    );
    
main_control u16(
    .clk(clk50),
    .rst_n(rst_n),
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
    .clk_25M(clk25), 
    .clk_50M(clk50),
    .rst_n(rst_n),
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
    
    
/*top_with_smoothtool u18(//帧差
    .clk(sys_clk),
    .rst_0(rst_n),
    .pclk(pclk),//cam
    .href(href),//cam
    .vsync(vsync),//cam
    .d(d),//cam
    .sda(sda1),//sccb
    .scl(scl1),//sccb
    .dvp_reset(dvp_reset),
    //output xclk,
    .pwdn(pwdn),
    .xclk(xclk),
    
    .red(red),
    .green(green),
    .blue(blue),
    .c_t(c_t),
    .h_t(h_t),
   // .led(led),
    .fall(fall),
    .led2(led2)
   // .clk_100m(clk100),
   // .clk_50m(clk50),
   // .clk_vga(clk25)
        );

    

 clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(clk100),    // output clk_out1
    .clk_out2(clk50),     // output clk_out2
    .clk_out3(clk25),     // output clk_out3
   // .clk_out4(xclk),     // output clk_out4
    // Status and control signals
    .reset(!rst_n), // input reset
    .locked(),       // output locked
   // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1
// INST_TAG_END ------ End INSTANTIATION Template ---------*/
  
endmodule
