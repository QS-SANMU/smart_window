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
/////////////////��̫������ �� W5500���ò���////////////////////////////////////////////////////////////// ///////////////////////////// ///////////////////////////// 
//��head   ƫ�Ƶ�ַ  +   ���� 
 //  parameter [31:0] local_gateway          =  {8'hC0,8'hA8,8'h01,8'h01};//Ĭ������  192.168.1.1
    parameter [31:0] local_gateway          =  {8'hC0,8'hA8,8'h10,8'hfe};//Ĭ������  192.168.16.254
   parameter [23:0] local_gateway_head     =  {16'h0001,8'h04};  	
   parameter [31:0] local_subr             =  {8'hFF,8'hFF,8'hFF,8'h00};//�������� 255.255.255.0
   parameter [23:0] local_subr_head        =  {16'h0005,8'h04};
   parameter [47:0] local_MAC              =  {8'h00,8'h08,8'hDC,8'h01,8'h02,8'h03};//���� MAC 
   parameter [23:0] local_MAC_head         =  {16'h0009,8'h04};
  // parameter [31:0] local_IP               =  {8'hC0,8'hA8,8'h01,8'hc7};//���� IP 192.168.1.199
   parameter [31:0] local_IP               =  {8'hC0,8'hA8,8'h10,8'hc7};//���� IP 192.168.16.199
   parameter [23:0] local_IP_head          =  {16'h000F,8'h04}; 
	
	/////socket 0   0X0
	parameter [15:0] local_port             =  {8'h13,8'h88};//���ض˿�  5000 
   parameter [23:0] local_port_head        =  {16'h0004,8'h0C};
   parameter [47:0] romate_MAC             =  {8'h64,8'h5D,8'h86,8'h85,8'h28,8'h98};//Ŀ�� MAC 6C.3B.E5.3E.2F.E7
   parameter [23:0] romate_MAC_head        =  {16'h0006,8'h0C};
  // parameter [31:0] romate_IP              =  {8'hC0,8'hA8,8'h01,8'h68};//Ŀ��  IP 192.168.1.104
   parameter [31:0] romate_IP              =  {8'hC0,8'hA8,8'h10,8'h64};//Ŀ��  IP 192.168.16.100
//   parameter [31:0] romate_IP              =  {8'hC0,8'hA8,8'h0B,8'hFE};//Ŀ��  IP 192.168.11.254
 //  parameter [31:0] romate_IP              =  {8'hC0,8'hA8,8'h0B,8'h01};//Ŀ��  IP 192.168.11.254
   
   parameter [23:0] romate_IP_head         =  {16'h000C,8'h0C};
   parameter [15:0] romate_port            =  {8'h1a,8'h0a};//Ŀ��˿�  6666 
 //parameter [15:0] romate_port            =  {8'h1F,8'h90};//Ŀ��˿�  8080 
   parameter [23:0] romate_port_head       =  {16'h0010,8'h0C};
   parameter [7:0]  RX_buffer_size         =  8'h04;//���ջ���Ĵ�С  4kB 
   parameter [23:0] RX_buffer_head         =  {16'h001E,8'h0C};
   parameter [7:0]  TX_buffer_size         =  8'h04;//���仺��Ĵ�С  4kB 
   parameter [23:0] TX_buffer_head         =  {16'h001F,8'h0C};
   parameter [7:0]  socket_mode            =  8'h21;//socket 0 �Ĺ���ģʽ Tcp
   parameter [23:0] socket_mode_head       =  {16'h0000,8'h0C};
	parameter [23:0] socket_config_head     =  {16'h0001,8'h0C};//socket 0 �����üĴ���  ������Ҫ�������̶�   open��0x01 listen:0x02  
	                                                            //connect:0x04  discon��0x08 close��0x10  send��0x20 send keep��0x22 recv��0x22
	parameter [23:0] socket_IR_head         =  {16'h0002,8'h08};// �жϼĴ��� ֻ��
	parameter [23:0] socket_SR_head         =  {16'h0003,8'h08};// ״̬�Ĵ��� ֻ��
	
                                          // ״̬�Ĵ����е�״ֵ̬
 	parameter [7:0]  SR_socket_closed       =    8'h00;//�ر�״̬ dicon��close������Чʱ �� ��ʱ�ж�														
 	parameter [7:0]  SR_socket_init         =    8'h13;//open ������Ч
 	parameter [7:0]  SR_socket_established  =    8'h17;//��������  

	reg              established_flag       =  0;//���ӳ��ν�����־
	reg       [15:0] Sn_Tx_wr   ;// ���ͻ�����д��ַ
	reg        [15:0] Sn_Rx_rd ;//���ܻ���������ַ
	
	/////////////////test////////////////////////////////////
	reg [7:0]  write_times  = 0;
	reg [15:0] count_times  = 0;	
/////////////////////////////////////////////////////////////////////////////////// ///////////////////////////// ///////////////////////////// 
    reg              W5500_RST_r  =   1;//��λ�ź�  �͵�ƽ��Ч
	 reg   [17:0]    wait_count_r =   0;//�ȴ�������
	 reg   [7:0]     count_01_r   =   0;
	 reg             buffer_flag  =   0;//1: ���� buffer������  0�����ͱ������
/////////////////spi_contonl////////////////////////////////////////////// ///////////////////////////// ///////////////////////////// /////////// 
    reg   [7:0]     clk_div; //ʱ�ӷ�Ƶϵ��  
    reg             T_flag  = 0 ;  //���������־ 
    reg             W_R_flag = 1;  //1ʱд���� 0ʱ������	 
    reg   [15:0]    Spi_Len;   //��Ҫ���������bits��
    wire            Tx_edone_w; //���η���������ɱ�־ ����Ч
	 reg             Tx_edone_ed =  0;
    wire            Rx_edone_w;  //���ν���������ɱ�־ ����Ч
	 reg             Rx_edone_ed =  0;
    reg  [7:0]      config_data_len = 32;//�����������ݳ���bits   ����ͽ���ʱ����  
	 reg  [31:0]     W5500_head  =  local_gateway_head ;  //w5500��ƫ�Ƶ�ַ + ����ͷ
	 reg  [47:0]     W5500_config_data = 48'h5555555555;//w5500�Ŀ�����������
(*KEEP = "TRUE"*)	 wire  [47:0]    W5500_RX_data;//���յ�w5500�ķ�������
         
/////////////////Tx_buffer//////////////////////////////////////////////////// ///////////////////////////// ///////////////////////////// ///////////////////////////// ///// 
	 reg   [9:0]       addra;//���ͻ���д��ַ
	 reg   [15:0]      Tx_buffer_data;//���ͻ���д����
	 reg               ena;//���ͻ���д��Ч
    wire   [13:0]     addrb;   //��ȡ�������ݵĵ�ַ
   wire              Tx_data_w;   //��������bit
    reg    [9:0]      buffer_count_r  =0;
//    reg              ping_pong_flag    =  1;// 1: дping ��pong 0:дpong �� ping
    reg              buffer_tx_flag    =  0;
	 reg              buffer_tx_flag_ed =  0;
	 
	 
  
	 
	 
	 wire   [9:0]     Tx_addra_pong;//���ͻ���д��ַ
	 wire   [15:0]    Tx_data_pong;//���ͻ���д����
	 wire             Tx_wea_pong;//���ͻ���д��Ч
    wire  [13:0]     Tx_addrb_pong ;   //��ȡ�������ݵĵ�ַ
    wire             Tx_dout_pong ;   //��������bit
/////////////////Tx_buffer//////////////////////////////////////////////////// ///////////////////////////// ///////////////////////////// ///////////////////////////// /////  
	localparam	[7:0]  	s_rst           		    =	8'b0000_0000,//�ϵ�Ӳ����λ W5500	
	                     s_config_W5500             =	8'b0000_0001,//��ʼ�� ����W5500   subnet gateway  local_IP
	                     s_read_W5500               =	8'b0000_0010,
	                     s_config_Socket            =	8'b0000_0100,//��ʼ�� ����socket 0
						 s_receive_data             =   8'b0000_1000,
								s_send_data                =	8'b0010_0000,//�������Ӻ������� ͬʱ����жϱ�־ �����ӶϿ���  s_config_Socket
	                     s_end                    	=	8'b1000_0000;
   reg	[7:0]			   state_reg			         =	s_rst ; 
 (*KEEP = "TRUE"*)  reg	[7:0]			   config_state               =  0;
   reg                  check_send_data_flag       =  0; 
  reg  [15:0]      once_test    =  0;
  reg  [15:0]      time_count_r = 0;//buffer��Ƶ������
  reg  [7:0]       send_times_r  = 0;
////////////////////////////////////////W5500��ʼ��������////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	always	@(posedge	clk_in)
			begin
//			1.�ϵ縴λw5500
//       2.����w5500
//			3.���ù�����socket0
//			4.���socket0�������Ƿ���ɣ���ɺ����׼������׶Σ�����׼���ú󣬿�ʼ�������ݣ����������Ƿ���ɣ������Ƿ�������ݣ����socket1�������Ƿ����
          Tx_edone_ed <=  Tx_edone_w;
			 Rx_edone_ed <=  Rx_edone_w;
			 buffer_tx_flag_ed <=  buffer_tx_flag;
			if(buffer_tx_flag_ed == 0 && buffer_tx_flag == 1)
				 begin
				  check_send_data_flag  <=  1;//W5500��Ҫ��������
				 end
          case(state_reg)
					s_rst:begin// 
								wait_count_r   <=   wait_count_r   +   1;
								established_flag <=   0;
								if(wait_count_r  ==   10000)//�ϵ�200 ΢�� 10000  �� ��λ�ź�
								    W5500_RST_r  <=   0;
								if(wait_count_r  ==   110000)//��λ2 ms �� 110000 ��λ�ź�����								
									begin
									W5500_RST_r    <=  1;
									state_reg		<=	 s_config_W5500 ;
									config_state   <=  0;
									wait_count_r   <=  0;
									buffer_flag    <= 1'b0;
                           end	
							  end
					s_config_W5500:begin//	����w5500ģ��				
											case(config_state)
												0:  begin//Ĭ������
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  local_gateway_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  32;//�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[31:0] <=  local_gateway;//w5500�Ŀ�����������
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 1;
															wait_count_r  <= 0;
															end
                                        end												
												1:  begin//��������
												   if(wait_count_r   <= 1000)
													  wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  local_subr_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  32;//�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[31:0] <=  local_subr;//w5500�Ŀ�����������
														  T_flag     <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 2;
															wait_count_r  <= 0;
															end
														end
												2:  begin//����MAC
												   if(wait_count_r   <= 1000)
													  wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  local_MAC_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  48;//�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[47:0] <=  local_MAC;//w5500�Ŀ�����������
														  T_flag     <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 3;
															wait_count_r  <= 0;
														end
														end										
												3:  begin//����IP
											     	if(wait_count_r   <= 1000)
													  wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  local_IP_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  32;//�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[31:0] <=  local_IP;//w5500�Ŀ�����������
														  T_flag            <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin									
														   //state_reg		<=	 s_read_W5500;//s_config_Socket;//s_config_W5500;// 
									                  config_state   <=  4;
															wait_count_r   <=  0;
															end
                                        end
												 4: begin//��ȡ �ж�д���Ƿ�ɹ� 
												     wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                         W5500_head        <=  24'h000900;  //w5500��ƫ�Ƶ�ַ+����ͷ 24'h000900
														  config_data_len   <=  48;//�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data <=  local_MAC;//w5500�Ŀ�����������
														  T_flag            <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//�½���
														  begin
														    if(W5500_RX_data[47:0] == local_MAC)//д��ɹ�
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
	              s_config_Socket:begin//	����Socket 0			
											case(config_state)
												0:  begin//���� ģʽ  Tcp
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_mode_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  8;               //�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[7:0] <=  socket_mode;//w5500�Ŀ�����������
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 1;
															wait_count_r  <= 0;
															end
                                        end	
													1:  begin//���ض˿�
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  local_port_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  16;               //�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[15:0] <=  local_port;//w5500�Ŀ�����������
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 2;
															wait_count_r  <= 0;
															end
                                        end
													2:  begin//�� SOCKET
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_config_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  8;                  //�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[7:0] <=  8'h01;         // ��socket
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 10;//�ȴ��� ��ȡ
															wait_count_r  <= 0;
															end
                                        end
	
 												3:  begin//Ŀ��IP
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  romate_IP_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  32;               //�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[31:0] <=  romate_IP;//w5500�Ŀ�����������
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														  // state_reg	  <= s_read_W5500;
														   config_state  <= 4;
															wait_count_r  <= 0;
															end
                                        end	
 												4:  begin//���仺������С 4KB
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  TX_buffer_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  8;               //�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[7:0] <=  TX_buffer_size;//w5500�Ŀ�����������
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 5;
															wait_count_r  <= 0;
															end
                                        end		
  												5:  begin//Ŀ��˿�
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  romate_port_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  16;               //�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[15:0] <=  romate_port;//w5500�Ŀ�����������
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 6;
															wait_count_r  <= 0;
															end
                                        end
	 	
 												6:  begin//�� ������
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_config_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  8;                  //�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[7:0] <=  8'h22;         // ��socket
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 7;
															wait_count_r  <= 0;
															end
                                        end													 
 												7:  begin//Ŀ��MAC
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  romate_MAC_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  48;               //�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[47:0] <=  romate_MAC;//w5500�Ŀ�����������
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 9;
															wait_count_r  <= 0;
															end
                                        end	
 												8:  begin//��ȡsocket 0��״̬�Ĵ��� �鿴״̬	
                                             wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                         W5500_head        <=  socket_SR_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  8;//�����������ݳ���bits   ����ͽ���ʱ����  
														  T_flag            <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//�½���
														  begin
														   if(W5500_RX_data[7:0] == SR_socket_init)//socket�ɹ���
															 begin
															   config_state  <= 3;
															   wait_count_r  <= 0;
															 end
														   if(W5500_RX_data[7:0] == SR_socket_established)//socket  �������ӳɹ� ����ͨ��
															 begin
															  state_reg		 <= s_send_data ;//�������Ӻ������� 
														     config_state  <= 0;
															  wait_count_r  <= 0;
															  end
														   if(W5500_RX_data[7:0] == 8'h00)//socket  ��ʱ
															 begin
														     state_reg		 <= s_config_W5500 ;
														     config_state  <= 0;
															  wait_count_r  <= 0;
														    end
														   if(W5500_RX_data[7:0] == 8'h1C)//socket  �Է��ر�����  �������������
															 begin
															  state_reg		 <= s_config_W5500 ;
														     config_state  <= 0;
															  wait_count_r  <= 0;
														    end															 
														 end 
                                        end
 												9: begin//open ��Ч�� ����Ϊ�ͻ��� 	
											       	if(wait_count_r   <= 1000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_config_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  8;                  //�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[7:0] <=  8'h04;         // ��socket �ͻ���
														  T_flag            <=  1'b1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 10;//������ɺ� ��ȡ״̬ ���Ƿ�ɹ�
															wait_count_r  <= 0;
															end
                                        end												 
 												10: begin//�鿴״̬�Ĵ���ǰ�ȴ�ʱ�� 	
											       	if(wait_count_r   <= 100000)
													    wait_count_r   <=   wait_count_r   +   1;
                                          else
														  begin
														   config_state  <=  8;//������ɺ� ��ȡ״̬ ���Ƿ�ɹ�
															wait_count_r  <= 0;
															end
                                        end														 
											  endcase
							        end	
									
									
									
				s_receive_data:begin  //�������Ӻ󣬴��ڽ���״̬
				
				
									 case(config_state)

								0:  begin//��ȡ������дָ��
                                        if(wait_count_r  == 150)
														  T_flag       <=  0;
                                            else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                                      W5500_head        <=  {16'h002A,8'h08};//& 24'hFFFFFC;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  16;//�����������ݳ���bits   ����ͽ���ʱ���� 
														  T_flag            <=  1;
														  end

														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//�½���
														  begin
														  // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														 //  Sn_Rx_wr       <=  W5500_RX_data[15:0];
															config_state   <=  1;
															wait_count_r   <=  0;
															end
											      end											
								1:  begin//��ȡ��������ָ��
                                        if(wait_count_r  == 150)
														  T_flag       <=  0;
                                          else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                                        W5500_head        <=  {16'h0028,8'h08};//& 24'hFFFFFC;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  16;//�����������ݳ���bits   ����ͽ���ʱ���� 
														  T_flag            <=  1;
														  end

														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//�½���
														  begin
														  // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														  // Sn_Tx_wr       <=  W5500_RX_data[15:0];
														  Sn_Rx_rd       <=  W5500_RX_data[15:0];
															config_state   <=  2;
															wait_count_r   <=  0;
															end
											      end	
								    2:  begin	//��ȡ���н��ջ�������С                                      
    											    	if(wait_count_r  == 150)
														  T_flag       <=  0;
                                                         else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                                         if(wait_count_r  == 100)
                                                             begin
														          W_R_flag          <=  0;//read
														           W5500_head        <=  {16'h0026,8'h08};//& 24'hFFFFFC;  //w5500��ƫ�Ƶ�ַ+����ͷ
														           config_data_len   <=  16;//�����������ݳ���bits   ����ͽ���ʱ���� 
														           T_flag            <=  1;
														     end
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//�½���
														  begin
														      established_flag <=   1;
														        // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														 if(W5500_RX_data[15:0] >= 16'd4)//����2�ֽ������ ������
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
												  
										3: begin//��socket0 ��Rx buffer������  
    										  if(wait_count_r  == 150)
														  T_flag       <=  0;
                                                 else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                              if(wait_count_r  == 100)
                                                      begin
														  W_R_flag          <=  0;//read
	                                                        W5500_head        <=  {Sn_Rx_rd,8'h18};   
						//								  Spi_Len           <=  8192;//512 *  16
	                                                      Spi_Len           <=  32;//��2�ֽ�����
														  T_flag            <=  1'b1;
							//							  buffer_flag       <=  1'b1;//��buffer�ж����ݱ�־
													   end
											 if(Rx_edone_ed == 1 && Rx_edone_w == 0)//�½���
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
                                      4:  begin//д ��������ָ�룬����֮�� ��Ҫ���¸üĴ�����ֵ
                                         if(wait_count_r  == 150)
														  T_flag       <=  0;
                                          else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                                       W5500_head        <=  {16'h0028,8'h0C};//& 24'hFFFFFC;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  16;//�����������ݳ���bits   ����ͽ���ʱ���� 
														  W5500_config_data[15:0] <=  Sn_Rx_rd;
														  T_flag            <=  1;
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														   begin
															config_state   <=  5;
														//	state_reg      <=  s_receive_data;
															wait_count_r   <=  0;
															end
											      end		
										 5:  begin//��������������� 
                                                 if(wait_count_r  == 150)
														    T_flag         <=  0;
														else
													       wait_count_r   <=   wait_count_r   +   1;
                                                  if(wait_count_r  == 100)
                                                 begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_config_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  8;                  //�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[7:0] <=  8'h40;         // recv
														  T_flag            <=  1'b1;
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 0;
															wait_count_r  <= 0;
															state_reg      <=  s_send_data;
															 receive_flag<=0;
															end
                                        end				
                          
                          endcase
                         end
				
               s_send_data:begin//���� ״̬ ���жϱ�־��ʾ�Ͽ��������½�������״̬
									   case(config_state)//��ȡ���з��ͻ���Ĵ��� ���������ֵһ�� �����ڷ���  ��һ��ʣ���д��Ŀռ�
									   
										0:  begin//��ȡ������дָ��
                                        if(wait_count_r  == 150)
														  T_flag       <=  0;
                                            else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                                      W5500_head        <=  {16'h0024,8'h08};//& 24'hFFFFFC;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  16;//�����������ݳ���bits   ����ͽ���ʱ���� 
														  T_flag            <=  1;
														  end

														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//�½���
														  begin
														  // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														   Sn_Tx_wr       <=  W5500_RX_data[15:0];  // ��ȡ���ķ���дָ��
															config_state   <=  1;
															wait_count_r   <=  0;
															end
											      end											
										1:  begin//��ȡ��������ָ��
                                        if(wait_count_r  == 150)
														  T_flag       <=  0;
                                          else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                                      W5500_head        <=  {16'h0022,8'h08};//& 24'hFFFFFC;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  16;//�����������ݳ���bits   ����ͽ���ʱ���� 
														  T_flag            <=  1;
														  end

														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//�½���
														  begin
														  // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														  // Sn_Tx_wr       <=  W5500_RX_data[15:0];
															config_state   <=  2;
															wait_count_r   <=  0;
															end
											      end
												2:  begin	//��ȡ���л����� ��С                                      
    											    	if(wait_count_r  == 150)
														  T_flag       <=  0;
                                          else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                         W5500_head        <=  {16'h0020,8'h08};//& 24'hFFFFFC;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  16;//�����������ݳ���bits   ����ͽ���ʱ���� 
														  T_flag            <=  1;
														  end
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//�½���
														  begin
														  established_flag <=   1;
														  // state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
														  if(W5500_RX_data[15:0] >= 16'h0400)//���� 0400 1024�ֽ������ �����򻺳�����������
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
                                3:  begin//�ж��Ƿ���Ҫ��������
															if(check_send_data_flag  ==  1 )//&& send_times_r<=3)//�����Ҫ��������
															   begin
															   send_times_r   <=  send_times_r   +  1;
															   config_state   <=  4;
															   wait_count_r   <=  0;
															   check_send_data_flag  <= 0;
																end	
																
																
															////////////////////////////////////////////////////////////////////////////////////////////////////�ܿ������ݷ��Ͳ���ȥ������ô���
															else 
																begin	
																config_state<= 0;
																state_reg <= s_receive_data;
																end
                                    end

		
								4:  begin//��socket0 ��Tx bufferд����  д��������
    											  if(wait_count_r  == 150)
														  T_flag       <=  0;
                                                 else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  {Sn_Tx_wr,8'h14};   
						//								  Spi_Len           <=  8192;//512 *  16
	                                                       Spi_Len           <=  384;//��16λ����
														  T_flag            <=  1'b1;
														  buffer_flag       <=  1'b1;//��buffer�ж����ݱ�־
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														    config_state  <= 5;
														    wait_count_r  <= 0;
                                              buffer_flag   <= 1'b0;
				//									 Sn_Tx_wr      <=  Sn_Tx_wr  +  1024;
					                                          Sn_Tx_wr      <=  Sn_Tx_wr  +  48;
															end
                                        end	  
                                     
												5:  begin//д����дָ��  д�뻺��� ��Ҫ���¸üĴ�����ֵ
                                            if(wait_count_r  == 150)
														  T_flag       <=  0;
                                          else														  
													    wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                                  begin
														  W_R_flag          <=  1;//write
	                                                       W5500_head        <=  {16'h0024,8'h0C};//& 24'hFFFFFC;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  16;//�����������ݳ���bits   ����ͽ���ʱ���� 
														  W5500_config_data[15:0] <=  Sn_Tx_wr;
														  T_flag            <=  1;
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														   begin
															config_state   <=  6;
															wait_count_r   <=  0;
															end
											      end													 
												 6:  begin//������������ 
                                                 if(wait_count_r  == 150)
														    T_flag         <=  0;
														else
													       wait_count_r   <=   wait_count_r   +   1;
                                                  if(wait_count_r  == 100)
                                                 begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  socket_config_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  8;                  //�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data[7:0] <=  8'h20;         // send
														  T_flag            <=  1'b1;
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
														  begin
														   config_state  <= 7;
															wait_count_r  <= 0;
															end
                                        end	
												 
 												7:  begin//��ȡsocket 0���жϼĴ��� �鿴״̬	
                                         wait_count_r   <=   wait_count_r   +   1;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  0;//read
	                                         W5500_head        <=  socket_IR_head;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  8;//�����������ݳ���bits   ����ͽ���ʱ����  
														  T_flag            <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//�½���
														  begin
														   if(W5500_RX_data[4] == 1'b1)//send ok 
															 begin
															   config_state  <= 0;
															   state_reg     <= s_receive_data;
															   wait_count_r  <= 0;
															 end
//															if(W5500_RX_data[0] == 1'b0)//����ʧ��
//													    	 begin
//															 	state_reg		<=	 s_config_Socket ;
//															   config_state   <= 8;
//															   wait_count_r   <= 0;
//															 end
//															if(W5500_RX_data[3] == 1'b1)//��ʱ
//													    	 begin
//															   config_state  <= 7;
//															   wait_count_r  <= 0;
//															 end
															if(W5500_RX_data[1] == 1'b1)//�Է��ж�
													    	 begin
															   config_state   <= 8;
															   wait_count_r   <= 0;
															 end
														    end															 
														 end 
											  8:  begin//�� socket 0���жϼĴ��� ������������  ����ĳһλ ������д�ж�
											         wait_count_r   <=   wait_count_r   +   1;
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
                                          if(wait_count_r  == 100)
                                            begin
														  W_R_flag          <=  1;//write
	                                         W5500_head        <=  {16'h0002,8'h0C};  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  8;//�����������ݳ���bits   ����ͽ���ʱ���� 
	                                         W5500_config_data[7:0] <=  8'h1F;//w5500�Ŀ�����������														  
														  T_flag            <=  1;
														  end
														  if(Tx_edone_ed == 1 && Tx_edone_w == 0)//�½���
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
	                                         W5500_head        <=  24'h000C08;//& 24'hFFFFFC;  //w5500��ƫ�Ƶ�ַ+����ͷ
														  config_data_len   <=  32;//�����������ݳ���bits   ����ͽ���ʱ����  
	                                         W5500_config_data <=  local_gateway;//w5500�Ŀ�����������
														  T_flag            <=  1;
														  end
                                           if(wait_count_r  == 150)
														    T_flag       <=  0;
														  if(Rx_edone_ed == 1 && Rx_edone_w == 0)//�½���
														  begin
														   state_reg		<=	 s_config_Socket;//s_config_W5500 ;//s_read_W5500
															config_state   <=  3;
															wait_count_r   <=  0;
															end 
                              end										
                 default:		 state_reg		<=	     s_rst  ;		
			     endcase
          end
////////////////////////////////////////SPI�ӿ�����////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	 W5500_SPI W5500_SPI (
                   .clk_in                      (     clk_in                  ),	
                   .clk_div                     (     clk_div                 ),//ʱ�ӷ�Ƶϵ�� 
                   .reset                       (     W5500_RST_r             ),//��λ�ź�
                   .T_flag                      (     T_flag                  ),//���������־
                   .W_R_flag                    (     W_R_flag                ),//1ʱд���� 0ʱ������
					.config_data_len             (     config_data_len         ),//config_data_len [7:0]�����������ݳ���bits   ����ͽ���ʱ���� 
					.W5500_head                  (     W5500_head              ),//[31:0]  w5500��ƫ�Ƶ�ַ  +  ����ͷ
					.W5500_config_data           (     W5500_config_data       ),//[47:0]//w5500�Ŀ����������� W5500_config_data
					.buffer_flag                 (     buffer_flag             ),//1: ���� buffer������  0�����ͱ������
                   .Spi_Len                     (     Spi_Len                 ),//[15:0]    Spi_Len,   //��Ҫ���������bits��
                   .Tx_addr                     (     addrb           ),//[13:0]    Tx_addr,   //��ȡ�������ݵĵ�ַ
					.Tx_data                     (     Tx_data_w               ),//��������bit
					.W5500_RX_data               (     W5500_RX_data           ),//[47:0]���յ�w5500�ķ�������
                   .Tx_edone                    (     Tx_edone_w              ),//Tx_edone,  //���η���������ɱ�־ ����Ч
                   .Rx_edone                    (     Rx_edone_w              ),//Rx_edone,  //���ν���������ɱ�־ ����Ч
                   .Spi_Ce                      (     Spi_Ce                  ),//Spi_Ce,    //spiͨ��Ƭѡ�ź�    ����Ч
                   .Spi_Clk                     (     Spi_Clk                 ),//Spi_Clk,   //spiͨ��ʱ���ź�
                   .Spi_Mosi                    (     Spi_Mosi                ),//Spi_Mosi,  //spiͨ�ŷ�������
                   .Spi_Miso                    (     Spi_Miso                )//Spi_Miso   //spiͨ�Ž�������
);


        	


 always@(posedge clk_in)
		if(W5500_RST_r==0)//��λ����Ч
			  begin
				buffer_count_r  <= 0 ;
        		addra <= 0 ;
				Tx_buffer_data  <= 0 ;
			  end
//		else if(established_flag)
		else
			begin
				if(send_data_valid)    //д����
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
	




//��������ӿ�//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      assign W5500_RST   =   W5500_RST_r;



endmodule




