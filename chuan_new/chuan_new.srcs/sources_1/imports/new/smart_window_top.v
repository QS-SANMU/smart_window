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

///////////////////////////////////////////ȫ��ʱ�ӣ���λ

    input sys_clk,
    input rst_n,
////////////////////////////////////////////////GSMģ��

    input GPRS_rx,   //GPRS����ָ��  ��GSMģ��
//    output [7:0]GPRS_cmd,///����
    output  gsm_tx,  //GPRS���ͣ���GSMģ��
   
///////////////////////////////////////////////////������   
    input down,
    input dingous,
    output robot_pwm,
  
//////////////////////////////////////////////////����ʶ��
 
    input rs232_rx,     //����ʶ��ģ�鷢��ָ�//
  
////////////////////////////////////////��������

   output rs232_tx ,    //����ָ���������ģ�飻//

///////////////////////////////////////�������

   output pwm_L,
   output pwm_R,
//////////////////////////////////////////�Ŷ��
   output pwm_door, 
///////////////////////////////////////��̫�����ݷ���ʹ��
  
    output  W5500_RST,
    output   Spi_Ce,
    output Spi_Clk,
    output Spi_Mosi,
    input Spi_Miso,
   
///////////////////////////////////////////////////ָ��ʶ��
   
    input data_in,
	output data_out,
	
/////////////////////////////////////////////////////������

    input fire,
    input CO,
    input CH4,
    input rain,
	
/////////////////////////////////////////////////////RTCʵʱʱ��

	output scl,
    inout sda,
	output [3:0] dtube_cs_n,
	output [6:0] dtube_data,

/////////////////////////////////////////////////////////���ٴ�����
	output scl_speed,
    inout sda_speed,
    output window_down,
    output [4:0]wind_speed,
    
///////////////////////////////////////////////////////////�����ź�

    output  [1:0]out1, //����1�ź�//
    output  [1:0]out2,//����2�ź� //
    
//////////////////////////////////////////////////////����������ʪ��

    inout data,//
    input serial_data_rx,//
    output serial_data_tx,//
    
////////////////////////////////////////////////////////�ж�ˤ��ģ��*/

    /*input pclk,//dvpʱ��
    input href,//dvp���ź�
    input vsync,//dvp֡�ź�
    input [7:0]d,//���ص�
    inout sda1,//sccb
    output scl1,//sccb
    output dvp_reset,//dvp��λ
    output pwdn,//dvpʹ��
    output xclk,//dvp���յ�ʱ��
    output [3:0]red,//����
    output [3:0]green,//����
    output [3:0]blue,//����
    output h_t,//��ͬ��
    output c_t,//��
    output fall,//ˤ��
 /*   output [3:0]curtain_cmds,
    output  [2:0]curtain_1,
    output  [2:0]curtain_2,
     output key1_p,//����1  �� 
    output  key2_p,//����2  ��
    output key1_n,////����1  �ر� 
    output  key2_n,//����2  �ر�
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
///////////////////////////////////////ʱ��   
    wire clk100;
    wire clk50;
    wire clk25;
    wire clk24;
    
/////////////////////////////////////ָ�ƽ��  led=01��ʾָ�ƴ���   led=10ָ����ȷ
    wire  [1:0] led;
  
////////////////////////////////////////////////��������
    wire send_en_1;
    wire send_en_2;
    
    //wire cmd_end;
    
/////////////////////////////////////////////////�Ҷϵ绰
    wire tele_cancel;
    
/////////////////////////////////////�����ź�
    wire key1_p;//����1  �� 
    wire key2_p;//����2  ��
    wire key1_n;////����1  �ر� 
    wire key2_n;//����2  �ر�*/

///////////////////////////////////////W5500��̫��ģ��
    wire [47:0]W5500_RX_data;
    wire w5500_rx_flag;
    wire en;
    wire send_data_valid;
    wire [15:0]w5500_din;
     
//////////////////////////////////////////����
     wire [3:0]LD3320_cmds;
     wire [4:0]JQ8900_cmds_tx;
     wire [3:0]senser_cmds;
     wire [3:0]window_cmds;
     wire [3:0]GSM_cmds;//1234 ��绰  56 �����ţ�GPRS  
     wire [3:0]curtain_cmds;
     wire [7:0]GPRS_cmd;
          
////////////////////////////////////////������     
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
    .cmds(JQ8900_cmds_tx),            //����ָ�� �������������֡�LD3320�ʹ�����
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
    
    
/*top_with_smoothtool u18(//֡��
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
