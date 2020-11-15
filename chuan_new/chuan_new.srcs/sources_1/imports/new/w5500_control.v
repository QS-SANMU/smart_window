`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/08 17:52:44
// Design Name: 
// Module Name: GSM_TOP
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
module W5500_control(
     input     clk_in,
	 input   [15:0]   send_data,
     input     send_data_valid,
     
     
	 output    W5500_RST,
     output    Spi_Ce,
     output    Spi_Clk,
     output    Spi_Mosi,
     input     Spi_Miso,
     output   reg [47:0]    W5500_RX_command,
     input    en,
     output   w5500_rx_flag
   
    ); 
 
   reg en_ed;
   reg receive_flag=0;
   reg receive_flag_ed=0;

	// reg  send_data_valid_ed;
/////////////////以太网参数 和 W5500配置参数////////////////////////////////////////////////////////////// ///////////////////////////// ///////////////////////////// 
//：head   偏移地址  +   控制 
 //  parameter [31:0] local_gateway          =  {8'hC0,8'hA8,8'h01,8'h01};//默认网关  192.168.1.1
    parameter [31:0] local_gateway          =  {8'hC0,8'hA8,8'h10,8'hfe};//默认网关  192.168.16.254
   parameter [23:0] local_gateway_head     =  {16'h0001,8'h04};  	
   parameter [31:0] local_subr             =  {8'hFF,8'hFF,8'hFF,8'h00};//子网掩码 255.255.255.0
   parameter [23:0] local_subr_head        =  {16'h0005,8'h04};
   parameter [47:0] local_MAC              =  {8'h00,8'h08,8'hDC,8'h01,8'h02,8'h03};//本地 MAC 
   parameter [23:0] local_MAC_head         =  {16'h0009,8'h04};
  // parameter [31:0] local_IP               =  {8'hC0,8'hA8,8'h01,8'hc7};//本地 IP 192.168.1.199
   parameter [31:0] local_IP               =  {8'hC0,8'hA8,8'h10,8'hc7};//本地 IP 192.168.16.199
   parameter [23:0] local_IP_head          =  {16'h000F,8'h04}; 
	
	/////socket 0   0X0
	parameter [15:0] local_port             =  {8'h13,8'h88};//本地端口  5000 
   parameter [23:0] local_port_head        =  {16'h0004,8'h0C};
   parameter [47:0] romate_MAC             =  {8'h64,8'h5D,8'h86,8'h85,8'h28,8'h98};//目标 MAC 6C.3B.E5.3E.2F.E7
   parameter [23:0] romate_MAC_head        =  {16'h0006,8'h0C};
  // parameter [31:0] romate_IP              =  {8'hC0,8'hA8,8'h01,8'h68};//目标  IP 192.168.1.104
   parameter [31:0] romate_IP              =  {8'hC0,8'hA8,8'h10,8'h64};//目标  IP 192.168.16.100
//   parameter [31:0] romate_IP              =  {8'hC0,8'hA8,8'h0B,8'hFE};//目标  IP 192.168.11.254
 //  parameter [31:0] romate_IP              =  {8'hC0,8'hA8,8'h0B,8'h01};//目标  IP 192.168.11.254
   
   parameter [23:0] romate_IP_head         =  {16'h000C,8'h0C};
   parameter [15:0] romate_port            =  {8'h1a,8'h0a};//目标端口  6666 
 //parameter [15:0] romate_port            =  {8'h1F,8'h90};//目标端口  8080 
   parameter [23:0] romate_port_head       =  {16'h0010,8'h0C};
   parameter [7:0]  RX_buffer_size         =  8'h04;//接收缓存的大小  4kB 
   parameter [23:0] RX_buffer_head         =  {16'h001E,8'h0C};
   parameter [7:0]  TX_buffer_size         =  8'h04;//发射缓存的大小  4kB 
   parameter [23:0] TX_buffer_head         =  {16'h001F,8'h0C};
   parameter [7:0]  socket_mode            =  8'h21;//socket 0 的工作模式 Tcp
   parameter [23:0] socket_mode_head       =  {16'h0000,8'h0C};
	parameter [23:0] socket_config_head     =  {16'h0001,8'h0C};//socket 0 的配置寄存器  根据需要参数不固定   open：0x01 listen:0x02  
	                                                            //connect:0x04  discon：0x08 close：0x10  send：0x20 send keep：0x22 recv：0x22
	parameter [23:0] socket_IR_head         =  {16'h0002,8'h08};// 中断寄存器 只读
	parameter [23:0] socket_SR_head         =  {16'h0003,8'h08};// 状态寄存器 只读
	
                                          // 状态寄存器中的状态值
 	parameter [7:0]  SR_socket_closed       =    8'h00;//关闭状态 dicon、close命令生效时 或 超时中断														
 	parameter [7:0]  SR_socket_init         =    8'h13;//open 命令生效
 	parameter [7:0]  SR_socket_established  =    8'h17;//建立连接  

	reg              established_flag       =  0;//连接初次建立标志
	reg       [15:0] Sn_Tx_wr   ;// 发送缓冲区写地址
	reg        [15:0] Sn_Rx_rd ;//接受缓冲区读地址
	
	/////////////////test////////////////////////////////////
	reg [7:0]  write_times  = 0;
	reg [15:0] count_times  = 0;	
/////////////////////////////////////////////////////////////////////////////////// ///////////////////////////// ///////////////////////////// 
    reg              W5500_RST_r  =   1;//复位信号  低电平有效
	 reg   [17:0]    wait_count_r =   0;//等待计数器
	 reg   [7:0]     count_01_r   =   0;
	 reg             buffer_flag  =   0;//1: 发送 buffer的数据  0：发送别的数据
/////////////////spi_contonl////////////////////////////////////////////// ///////////////////////////// ///////////////////////////// /////////// 
    reg   [7:0]     clk_div; //时钟分频系数  
    reg             T_flag  = 0 ;  //启动传输标志 
    reg             W_R_flag = 1;  //1时写操作 0时读操作	 
    reg   [15:0]    Spi_Len;   //需要传输的数据bits数
    wire            Tx_edone_w; //本次发送数据完成标志 高有效
	 reg             Tx_edone_ed =  0;
    wire            Rx_edone_w;  //本次接收数据完成标志 高有效
	 reg             Rx_edone_ed =  0;
    reg  [7:0]      config_data_len = 32;//控制命令数据长度bits   发射和接收时共享  
	 reg  [31:0]     W5500_head  =  local_gateway_head ;  //w5500的偏移地址 + 控制头
	 reg  [47:0]     W5500_config_data = 48'h5555555555;//w5500的控制命令数据
(*KEEP = "TRUE"*)	 wire  [47:0]    W5500_RX_data;//接收的w5500的返回数据
         
/////////////////Tx_buffer//////////////////////////////////////////////////// ///////////////////////////// ///////////////////////////// ///////////////////////////// ///// 
	 reg   [9:0]       addra;//发送缓冲写地址
	 reg   [15:0]      Tx_buffer_data;//发送缓冲写数据
	 reg               ena;//发送缓冲写有效
    wire   [13:0]     addrb;   //读取发送数据的地址
   wire              Tx_data_w;   //发送数据bit
    reg    [9:0]      buffer_count_r  =0;
//    reg              ping_pong_flag    =  1;// 1: 写ping 读pong 0:写pong 读 ping
    reg              buffer_tx_flag    =  0;
	 reg              buffer_tx_flag_ed =  0;
	 
	 
  
	 
	 
	 wire   [9:0]     Tx_addra_pong;//发送缓冲写地址
	 wire   [15:0]    Tx_data_pong;//发送缓冲写数据
	 wire             Tx_wea_pong;//发送缓冲写有效
    wire  [13:0]     Tx_addrb_pong ;   //读取发送数据的地址
    wire             Tx_dout_pong ;   //发送数据bit
/////////////////Tx_buffer//////////////////////////////////////////////////// ///////////////////////////// ///////////////////////////// ///////////////////////////// /////  
	localparam	[7:0]  	s_rst           		    =	8'b0000_0000,//上电硬件复位 W5500	
	                     s_config_W5500             =	8'b0000_0001,//初始化 设置W5500   subnet gateway  local_IP
	                     s_read_W5500               =	8'b0000_0010,
	                     s_config_Socket            =	8'b0000_0100,//初始化 设置socket 0
						 s_receive_data             =   8'b0000_1000,
								s_send_data                =	8'b0010_0000,//建立连接后发射数据 同时检测中断标志 若连接断开则  s_config_Socket
	                     s_end                    	=	8'b1000_0000;
   reg	[7:0]			   state_reg			         =	s_rst ; 
 (*KEEP = "TRUE"*)  reg	[7:0]			   config_state               =  0;
   reg                  check_send_data_flag       =  0; 
  reg  [15:0]      once_test    =  0;
  reg  [15:0]      time_count_r = 0;//buffer分频计数器
  reg  [7:0]       send_times_r  = 0;
////////////////////////////////////////W5500初始化主程序////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	always	@(posedge	clk_in)
			begin
//			1.上电复位w5500
//       2.配置w5500
//			3.配置工作的socket0
//			4.监测socket0发射区是否完成，完成后进入准备发射阶段，数据准备好后，开始发射数据，监听发射是否完成，监听是否接收数据，监测socket1发射区是否完成
          Tx_edone_ed <=  Tx_edone_w;
			 Rx_edone_ed <=  Rx_edone_w;
			 buffer_tx_flag_ed <=  buffer_tx_flag;
			if(buffer_tx_flag_ed == 0 && buffer_tx_flag == 1)
				 begin
				  check_send_data_flag  <=  1;//W5500需要发送数据
				 end
          case(state_reg)
					s_rst:begin// 
								wait_count_r   <=   wait_count_r   +   1;
								established_flag <=   0;
								if(wait_count_r  ==   10000)//上电200 微妙 10000  后 复位信号
								    W5500_RST_r  <=   0;
								if(wait_count_r  ==   110000)//复位2 ms 后 110000 复位信号拉低								
									begin
									W5500_RST_r    <=  1;
									state_reg		<=	 s_config_W5500 ;
									config_state   <=  0;
									wait_count_r   <=  0;
									buffer_flag    <= 1'b0;
                           end	
							  end
					s_config_W5500:begin//	配置w5500模块				
											case(config_state)
												0:  begin//默认网关
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  local_gateway_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  32;//控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[31:0] <=  local_gateway;//w5500的控制命令数据
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 1;
															wait_count_r  <= 0;
															end
                                        end												
												1:  begin//子网掩码
												   if(wait_count_r   <= 1000)
													  wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  local_subr_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  32;//控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[31:0] <=  local_subr;//w5500的控制命令数据
														  T_flag     <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 2;
															wait_count_r  <= 0;
															end
														end
												2:  begin//本地MAC
												   if(wait_count_r   <= 1000)
													  wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  local_MAC_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  48;//控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[47:0] <=  local_MAC;//w5500的控制命令数据
														  T_flag     <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 3;
															wait_count_r  <= 0;
														end
														end										
												3:  begin//本地IP
											     	if(wait_count_r   <= 1000)
													  wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  local_IP_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  32;//控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[31:0] <=  local_IP;//w5500的控制命令数据
														  T_flag            <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin									
														   //state_reg		<=	 s_read_W5500;//s_config_Socket;//s_config_W5500;// 
									                  config_state   <=  4;
															wait_count_r   <=  0;
															end
                                        end
												 4: begin//读取 判断写入是否成功 
												     wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                         W5500_head        <=  24'h000900;  //w5500的偏移地址+控制头 24'h000900
														  config_data_len   <=  48;//控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data <=  local_MAC;//w5500的控制命令数据
														  T_flag            <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//下降沿
														  begin
														    if(W5500_RX_data[47:0] == local_MAC)//写入成功
															  begin
															   state_reg		<=	 s_config_Socket;//s_config_Socket;//s_config_W5500;// 
									                     config_state   <=  0;
															   wait_count_r   <=  0;
															  end
															  else 
															    begin
																  state_reg		  <=	 s_config_W5500 ;
																  config_state   <=  0;
															     wait_count_r   <=  0;
																 end
															end 
												      end
											  endcase
							        end
	              s_config_Socket:begin//	配置Socket 0			
											case(config_state)
												0:  begin//工作 模式  Tcp
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_mode_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  8;               //控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[7:0] <=  socket_mode;//w5500的控制命令数据
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 1;
															wait_count_r  <= 0;
															end
                                        end	
													1:  begin//本地端口
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  local_port_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  16;               //控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[15:0] <=  local_port;//w5500的控制命令数据
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 2;
															wait_count_r  <= 0;
															end
                                        end
													2:  begin//打开 SOCKET
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_config_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  8;                  //控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[7:0] <=  8'h01;         // 打开socket
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 10;//等待后 读取
															wait_count_r  <= 0;
															end
                                        end
	
 												3:  begin//目标IP
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  romate_IP_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  32;               //控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[31:0] <=  romate_IP;//w5500的控制命令数据
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														  // state_reg	  <= s_read_W5500;
														   config_state  <= 4;
															wait_count_r  <= 0;
															end
                                        end	
 												4:  begin//发射缓冲区大小 4KB
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  TX_buffer_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  8;               //控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[7:0] <=  TX_buffer_size;//w5500的控制命令数据
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 5;
															wait_count_r  <= 0;
															end
                                        end		
  												5:  begin//目标端口
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  romate_port_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  16;               //控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[15:0] <=  romate_port;//w5500的控制命令数据
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 6;
															wait_count_r  <= 0;
															end
                                        end
	 	
 												6:  begin//打开 心跳包
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_config_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  8;                  //控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[7:0] <=  8'h22;         // 打开socket
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 7;
															wait_count_r  <= 0;
															end
                                        end													 
 												7:  begin//目标MAC
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  romate_MAC_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  48;               //控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[47:0] <=  romate_MAC;//w5500的控制命令数据
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 9;
															wait_count_r  <= 0;
															end
                                        end	
 												8:  begin//读取socket 0的状态寄存器 查看状态	
                                             wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                         W5500_head        <=  socket_SR_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  8;//控制命令数据长度bits   发射和接收时共享  
														  T_flag            <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//下降沿
														  begin
														   if(W5500_RX_data[7:0] == SR_socket_init)//socket成功打开
															 begin
															   config_state  <= 3;
															   wait_count_r  <= 0;
															 end
														   if(W5500_RX_data[7:0] == SR_socket_established)//socket  建立连接成功 可以通信
															 begin
															  state_reg		 <= s_send_data ;//建立连接后发射数据 
														     config_state  <= 0;
															  wait_count_r  <= 0;
															  end
														   if(W5500_RX_data[7:0] == 8'h00)//socket  超时
															 begin
														     state_reg		 <= s_config_W5500 ;
														     config_state  <= 0;
															  wait_count_r  <= 0;
														    end
														   if(W5500_RX_data[7:0] == 8'h1C)//socket  对方关闭连接  则继续重新连接
															 begin
															  state_reg		 <= s_config_W5500 ;
														     config_state  <= 0;
															  wait_count_r  <= 0;
														    end															 
														 end 
                                        end
 												9: begin//open 有效后 设置为客户端 	
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_config_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  8;                  //控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[7:0] <=  8'h04;         // 打开socket 客户端
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 10;//设置完成后 读取状态 看是否成功
															wait_count_r  <= 0;
															end
                                        end												 
 												10: begin//查看状态寄存器前等待时间 	
											       	if(wait_count_r   <= 100000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          else
														  begin
														   config_state  <=  8;//设置完成后 读取状态 看是否成功
															wait_count_r  <= 0;
															end
                                        end														 
											  endcase
							        end	
									
									
									
				s_receive_data:begin  //建立连接后，处于接收状态
				
				
									 case(config_state)

								0:  begin//读取接收区写指针
                                        if(wait_count_r  == 150)
														  T_flag       <=  0;
                                            else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                                      W5500_head        <=  {16'h002A,8'h08};//& 24'hFFFFFC;  //w5500的偏移地址+控制头
														  config_data_len   <=  16;//控制命令数据长度bits   发射和接收时共享 
														  T_flag            <=  1;
														  end

														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//下降沿
														  begin
														  // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														 //  Sn_Rx_wr       <=  W5500_RX_data[15:0];
															config_state   <=  1;
															wait_count_r   <=  0;
															end
											      end											
								1:  begin//读取接收区读指针
                                        if(wait_count_r  == 150)
														  T_flag       <=  0;
                                          else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                                        W5500_head        <=  {16'h0028,8'h08};//& 24'hFFFFFC;  //w5500的偏移地址+控制头
														  config_data_len   <=  16;//控制命令数据长度bits   发射和接收时共享 
														  T_flag            <=  1;
														  end

														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//下降沿
														  begin
														  // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														  // Sn_Tx_wr       <=  W5500_RX_data[15:0];
														  Sn_Rx_rd       <=  W5500_RX_data[15:0];
															config_state   <=  2;
															wait_count_r   <=  0;
															end
											      end	
								    2:  begin	//读取空闲接收缓冲区大小                                      
    											    	if(wait_count_r  == 150)
														  T_flag       <=  0;
                                                         else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                                         if(wait_count_r  == 100)
                                                             begin
														          W_R_flag          <=  0;//read
														           W5500_head        <=  {16'h0026,8'h08};//& 24'hFFFFFC;  //w5500的偏移地址+控制头
														           config_data_len   <=  16;//控制命令数据长度bits   发射和接收时共享 
														           T_flag            <=  1;
														     end
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//下降沿
														  begin
														      established_flag <=   1;
														        // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														 if(W5500_RX_data[15:0] >= 16'd4)//大于2字节则可以 读数据
															 begin
															   config_state   <=  3;
															   wait_count_r   <=  0;
															
															  end
														else
															  begin
															  config_state   <=  0;
															  wait_count_r   <=  0;	
															  state_reg      <=  s_send_data;
															  end

															end
											      end	
												  
										3: begin//从socket0 的Rx buffer读数据  
    										  if(wait_count_r  == 150)
														  T_flag       <=  0;
                                                 else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                              if(wait_count_r  == 100)
                                                      begin
														  W_R_flag          <=  0;//read
	                                                        W5500_head        <=  {Sn_Rx_rd,8'h18};   
						//								  Spi_Len           <=  8192;//512 *  16
	                                                      Spi_Len           <=  32;//读2字节数据
														  T_flag            <=  1'b1;
							//							  buffer_flag       <=  1'b1;//从buffer中读数据标志
													   end
											 if(Rx_edone_ed == 1 && Rx_edone_w == 0)//下降沿
												       begin
														  config_state  <= 4;
													//	  state_reg      <=  s_send_data;
														  wait_count_r  <= 0;
														  W5500_RX_command<=W5500_RX_data;
                                          //    buffer_flag   <= 1'b0;
				//									 Sn_Tx_wr      <=  Sn_Tx_wr  +  1024;
					                                      Sn_Rx_rd      <=  Sn_Rx_rd  +  4;
					                                      receive_flag<=1;
														end
                                        end	  
                          //    end
                                      4:  begin//写 接受区读指针，读完之后 需要更新该寄存器的值
                                         if(wait_count_r  == 150)
														  T_flag       <=  0;
                                          else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                                       W5500_head        <=  {16'h0028,8'h0C};//& 24'hFFFFFC;  //w5500的偏移地址+控制头
														  config_data_len   <=  16;//控制命令数据长度bits   发射和接收时共享 
														  W5500_config_data[15:0] <=  Sn_Rx_rd;
														  T_flag            <=  1;
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														   begin
															config_state   <=  5;
														//	state_reg      <=  s_receive_data;
															wait_count_r   <=  0;
															end
											      end		
										 5:  begin//启动接收完成命令 
                                                 if(wait_count_r  == 150)
														    T_flag         <=  0;
														else
													       wait_count_r   <=   wait_count_r   +   1;
                                                  if(wait_count_r  == 100)
                                                 begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_config_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  8;                  //控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[7:0] <=  8'h40;         // recv
														  T_flag            <=  1'b1;
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 0;
															wait_count_r  <= 0;
															state_reg      <=  s_send_data;
															 receive_flag<=0;
															end
                                        end				
                          
                          endcase
                         end
				
               s_send_data:begin//发送 状态 当中断标志显示断开后，则重新进入配置状态
									   case(config_state)//读取空闲发送缓存寄存器 建议读两次值一样 还会在发送  看一下剩余可写入的空间
									   
										0:  begin//读取发送区写指针
                                        if(wait_count_r  == 150)
														  T_flag       <=  0;
                                            else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                                      W5500_head        <=  {16'h0024,8'h08};//& 24'hFFFFFC;  //w5500的偏移地址+控制头
														  config_data_len   <=  16;//控制命令数据长度bits   发射和接收时共享 
														  T_flag            <=  1;
														  end

														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//下降沿
														  begin
														  // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														   Sn_Tx_wr       <=  W5500_RX_data[15:0];  // 读取出的发送写指针
															config_state   <=  1;
															wait_count_r   <=  0;
															end
											      end											
										1:  begin//读取发送区读指针
                                        if(wait_count_r  == 150)
														  T_flag       <=  0;
                                          else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                                      W5500_head        <=  {16'h0022,8'h08};//& 24'hFFFFFC;  //w5500的偏移地址+控制头
														  config_data_len   <=  16;//控制命令数据长度bits   发射和接收时共享 
														  T_flag            <=  1;
														  end

														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//下降沿
														  begin
														  // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														  // Sn_Tx_wr       <=  W5500_RX_data[15:0];
															config_state   <=  2;
															wait_count_r   <=  0;
															end
											      end
												2:  begin	//读取空闲缓冲区 大小                                      
    											    	if(wait_count_r  == 150)
														  T_flag       <=  0;
                                          else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                         W5500_head        <=  {16'h0020,8'h08};//& 24'hFFFFFC;  //w5500的偏移地址+控制头
														  config_data_len   <=  16;//控制命令数据长度bits   发射和接收时共享 
														  T_flag            <=  1;
														  end
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//下降沿
														  begin
														  established_flag <=   1;
														  // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														  if(W5500_RX_data[15:0] >= 16'h0400)//大于 0400 1024字节则可以 可以向缓冲区发送数据
															 begin
															   config_state   <=  3;
															   wait_count_r   <=  0;
															  end
															else
															  begin
															  config_state   <=  5;
															  wait_count_r   <=  0;															  
															  end

															end
											      end	
                                3:  begin//判断是否需要发送数据
															if(check_send_data_flag  ==  1 )//&& send_times_r<=3)//如果需要发送数据
															   begin
															   send_times_r   <=  send_times_r   +  1;
															   config_state   <=  4;
															   wait_count_r   <=  0;
															   check_send_data_flag  <= 0;
																end	
																
																
															////////////////////////////////////////////////////////////////////////////////////////////////////很可能数据发送不出去，该怎么解决
															else 
																begin	
																config_state<= 0;
																state_reg <= s_receive_data;
																end
                                    end

		
								4:  begin//向socket0 的Tx buffer写数据  写缓冲数据
    											  if(wait_count_r  == 150)
														  T_flag       <=  0;
                                                 else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  {Sn_Tx_wr,8'h14};   
						//								  Spi_Len           <=  8192;//512 *  16
	                                                       Spi_Len           <=  384;//发16位数据
														  T_flag            <=  1'b1;
														  buffer_flag       <=  1'b1;//从buffer中读数据标志
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														    config_state  <= 5;
														    wait_count_r  <= 0;
                                              buffer_flag   <= 1'b0;
				//									 Sn_Tx_wr      <=  Sn_Tx_wr  +  1024;
					                                          Sn_Tx_wr      <=  Sn_Tx_wr  +  48;
															end
                                        end	  
                                     
												5:  begin//写发送写指针  写入缓存后 需要更新该寄存器的值
                                            if(wait_count_r  == 150)
														  T_flag       <=  0;
                                          else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                                  begin
														  W_R_flag          <=  1;//write
	                                                       W5500_head        <=  {16'h0024,8'h0C};//& 24'hFFFFFC;  //w5500的偏移地址+控制头
														  config_data_len   <=  16;//控制命令数据长度bits   发射和接收时共享 
														  W5500_config_data[15:0] <=  Sn_Tx_wr;
														  T_flag            <=  1;
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														   begin
															config_state   <=  6;
															wait_count_r   <=  0;
															end
											      end													 
												 6:  begin//启动发送命令 
                                                 if(wait_count_r  == 150)
														    T_flag         <=  0;
														else
													       wait_count_r   <=   wait_count_r   +   1;
                                                  if(wait_count_r  == 100)
                                                 begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_config_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  8;                  //控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data[7:0] <=  8'h20;         // send
														  T_flag            <=  1'b1;
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
														   config_state  <= 7;
															wait_count_r  <= 0;
															end
                                        end	
												 
 												7:  begin//读取socket 0的中断寄存器 查看状态	
                                         wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                         W5500_head        <=  socket_IR_head;  //w5500的偏移地址+控制头
														  config_data_len   <=  8;//控制命令数据长度bits   发射和接收时共享  
														  T_flag            <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//下降沿
														  begin
														   if(W5500_RX_data[4] == 1'b1)//send ok 
															 begin
															   config_state  <= 0;
															   state_reg     <= s_receive_data;
															   wait_count_r  <= 0;
															 end
//															if(W5500_RX_data[0] == 1'b0)//连接失败
//													    	 begin
//															 	state_reg		<=	 s_config_Socket ;
//															   config_state   <= 8;
//															   wait_count_r   <= 0;
//															 end
//															if(W5500_RX_data[3] == 1'b1)//超时
//													    	 begin
//															   config_state  <= 7;
//															   wait_count_r  <= 0;
//															 end
															if(W5500_RX_data[1] == 1'b1)//对方中断
													    	 begin
															   config_state   <= 8;
															   wait_count_r   <= 0;
															 end
														    end															 
														 end 
											  8:  begin//清 socket 0的中断寄存器 并切重新连接  设置某一位 而不是写中断
											         wait_count_r   <=   wait_count_r   +   1;
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  {16'h0002,8'h0C};  //w5500的偏移地址+控制头
														  config_data_len   <=  8;//控制命令数据长度bits   发射和接收时共享 
	                                         W5500_config_data[7:0] <=  8'h1F;//w5500的控制命令数据														  
														  T_flag            <=  1;
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//下降沿
														  begin
															 	state_reg		<=	 s_config_Socket ;
															   config_state   <= 8;
															   wait_count_r   <= 0;
//															   config_state   <= 6;
//															   wait_count_r   <= 0;
														    end															 
													 end                                        												 
													 
													 
												endcase
                              end

									  
					s_read_W5500:begin//							  
							           		   wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                         W5500_head        <=  24'h000C08;//& 24'hFFFFFC;  //w5500的偏移地址+控制头
														  config_data_len   <=  32;//控制命令数据长度bits   发射和接收时共享  
	                                         W5500_config_data <=  local_gateway;//w5500的控制命令数据
														  T_flag            <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//下降沿
														  begin
														   state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
															config_state   <=  3;
															wait_count_r   <=  0;
															end 
                              end										
                 default:		 state_reg		<=	     s_rst  ;		
			     endcase
          end
////////////////////////////////////////SPI接口驱动////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	 W5500_SPI W5500_SPI (
                   .clk_in                      (     clk_in                  ),	
                   .clk_div                     (     clk_div                 ),//时钟分频系数 
                   .reset                       (     W5500_RST_r             ),//复位信号
                   .T_flag                      (     T_flag                  ),//启动传输标志
                   .W_R_flag                    (     W_R_flag                ),//1时写操作 0时读操作
					.config_data_len             (     config_data_len         ),//config_data_len [7:0]控制命令数据长度bits   发射和接收时共享 
					.W5500_head                  (     W5500_head              ),//[31:0]  w5500的偏移地址  +  控制头
					.W5500_config_data           (     W5500_config_data       ),//[47:0]//w5500的控制命令数据 W5500_config_data
					.buffer_flag                 (     buffer_flag             ),//1: 发送 buffer的数据  0：发送别的数据
                   .Spi_Len                     (     Spi_Len                 ),//[15:0]    Spi_Len,   //需要传输的数据bits数
                   .Tx_addr                     (     addrb           ),//[13:0]    Tx_addr,   //读取发送数据的地址
					.Tx_data                     (     Tx_data_w               ),//发送数据bit
					.W5500_RX_data               (     W5500_RX_data           ),//[47:0]接收的w5500的返回数据
                   .Tx_edone                    (     Tx_edone_w              ),//Tx_edone,  //本次发送数据完成标志 高有效
                   .Rx_edone                    (     Rx_edone_w              ),//Rx_edone,  //本次接收数据完成标志 高有效
                   .Spi_Ce                      (     Spi_Ce                  ),//Spi_Ce,    //spi通信片选信号    低有效
                   .Spi_Clk                     (     Spi_Clk                 ),//Spi_Clk,   //spi通信时钟信号
                   .Spi_Mosi                    (     Spi_Mosi                ),//Spi_Mosi,  //spi通信发送数据
                   .Spi_Miso                    (     Spi_Miso                )//Spi_Miso   //spi通信接收数据
);


        	


 always@(posedge clk_in)
		if(W5500_RST_r==0)//复位低有效
			  begin
				buffer_count_r  <= 0 ;
        		addra <= 0 ;
				Tx_buffer_data  <= 0 ;
			  end
//		else if(established_flag)
		else
			begin
				if(send_data_valid)    //写数据
				    begin
						ena<=1'b1;
						buffer_count_r  <=  buffer_count_r  +  1;
						addra <=  buffer_count_r  ;
						Tx_buffer_data  <=  send_data;
					end
				else
					begin
						ena<=1'b0;
						buffer_count_r  <=  0;
						addra <=  0 ;
						Tx_buffer_data  <=  0;
					end
					
			end
		
	
always@(posedge clk_in)
    begin
        en_ed<=en;
        if(en_ed==0 & en==1)
            buffer_tx_flag<=1;
        if(buffer_tx_flag)
            buffer_tx_flag<=0;
    end
        			
always@(posedge clk_in )
receive_flag_ed<=receive_flag;


assign  w5500_rx_flag=receive_flag & (!receive_flag_ed); 				   
				   


w5500_send_data send_data_ram(
  .clka(clk_in),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(1'b1),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [9 : 0] addra
  .dina(Tx_buffer_data),    // input wire [15 : 0] dina
  .clkb(clk_in),    // input wire clkb
  .enb(buffer_flag),      // input wire enb
  .addrb(addrb),  // input wire [13 : 0] addrb
  .doutb(Tx_data_w)  // output wire [0 : 0] doutb
);				   
	




//对外输出接口//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      assign W5500_RST   =   W5500_RST_r;



endmodule




