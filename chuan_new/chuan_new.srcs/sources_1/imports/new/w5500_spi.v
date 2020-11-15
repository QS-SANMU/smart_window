`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/08 14:15:21
// Design Name: 
// Module Name: w5500_spi
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


module W5500_SPI(    
    input            clk_in,
    input  [7:0]     clk_div,   //时钟分频系数  
	 input            reset,//复位信号
    input            T_flag,    //启动传输标志 
    input            W_R_flag,  //1时写操作 0时读操作	
	 
    input  [7:0]     config_data_len,//控制命令数据长度bits   发射和接收时共享  
	 input  [31:0]    W5500_head,  //w5500的偏移地址 +   控制头
	 input  [47:0]    W5500_config_data,//w5500的控制命令数据
	 input            buffer_flag,//1: 发送 buffer的数据  0：发送别的数据
	 input  [15:0]    Spi_Len,   //需要传输的数据bits数
    output [13:0]    Tx_addr,   //读取发送数据的地址
    input            Tx_data,   //发送数据bit
	 output [47:0]    W5500_RX_data,//接收的w5500的返回数据
    //output [12:0]    Rx_addr,   //存储接收数据的地址
   // output           Rx_data,   //接收数据bit 
    output           Tx_edone,  //本次发送数据完成标志 高有效
    output           Rx_edone,  //本次接收数据完成标志 高有效
	 output           Spi_Ce,    //spi通信片选信号    低有效
    output           Spi_Clk,   //spi通信时钟信号
    output           Spi_Mosi,  //spi通信发送数据
    input            Spi_Miso   //spi通信接收数据
    );
    reg           Spi_Ce_r    =  1 ;  //spi通信片选信号    低有效
    reg           Spi_Clk_r   =  0  ; //spi通信时钟信号
    reg           Spi_Mosi_r  =  0 ;       //spi通信发送数据   
	 reg   [13:0]  Tx_addr_r   =  0;
	 //reg   [12:0]  Rx_addr_r   =  0;	 
	// reg           Rx_data_r  ;
	 
	 reg           T_flag_ed    =  0;
	 reg           Tx_edone_r   =  0;
	 reg           Rx_edone_r   =  0;	 
	 reg   [7:0]	count1_r      =  0;
	 reg   [7:0]	count2_r      =  0;	 
 	 reg   [15:0]	count3_r      =  0;   
	 reg   [7:0]	count_bits_r   =  0;
	 
	 
(*KEEP = "TRUE"*)	 reg  [47:0]    W5500_RX_data_r;//接收的w5500的返回数据
(*KEEP = "TRUE"*)	 reg  [47:0]    W5500_RX_data_1r;//接收的w5500的返回数据 
	 
	 reg  [47:0]     W5500_config_data_r;
	localparam	[7:0]  	s_idle           		     	=	8'b0000_0000,	
	                     s_wait                    	=	8'b0000_0001,
								s_Tx_head                  =	8'b0001_0000,
	                     s_Tx_data                  =	8'b0000_0010,
								s_Tx_data_buffer           =	8'b0010_0000,
	                     s_Rx_data                  =	8'b0000_0100,
	                     s_end                    	=	8'b0000_1000;					
								
   reg	[7:0]		   	state_reg			         =	s_idle ; 



	always	@	(posedge	clk_in)
			begin
			  T_flag_ed  <=  T_flag ;
		   if(reset==0)//复位低有效
			  begin
			    state_reg		               <=	   s_idle;
				 Spi_Ce_r                     <=    1;//片选信号拉低发送数据
				 count1_r                     <=    0;
				 count2_r                     <=    0;
				 count3_r                     <=    0;				 
				 Tx_addr_r                    <=    0;
			    count_bits_r                 <=    0;	
			  end
			 else
			  begin
				case(state_reg)
					s_idle:begin// 空闲状态 检测数据传输命令
												if(T_flag_ed  == 0  && T_flag  ==  1)	// 需要传输和接收数据
												//if(1)
												begin
												  Spi_Ce_r     <=     0;//片选信号拉低准备发送数据
												  count1_r     <=     0;
												  count3_r     <=     0;// 发送bits数计数器
												  state_reg		<=     s_wait;
												end
//												else
//												begin
//												  state_reg		<=	    s_idle ;
//												  Spi_Ce_r     <=     1;
//												end
							   end
					s_wait:begin// 片选拉低后等待若干时钟 
					                       count1_r     <=    count1_r  +  1;
												if(count1_r == 20)	
												begin
												  count1_r     <=     0;
												  count2_r     <=     0;// 时钟计数器
												  count3_r     <=     24;// 发送bits数计数器
												  Tx_addr_r    <=     0;
												  Spi_Clk_r    <=     0;
				                                  count_bits_r <=     0;	
												  Spi_Ce_r     <=     0;//片选信号拉低准备发送数据
												  state_reg	   <=     s_Tx_head;
												end
							   end
					s_Tx_head:begin//// 发送16位偏移地址  和  8 位控制命令   
					                      if(count2_r <=  9)  //在一个时钟周期内完成读取数据和传输
					                        count2_r  <=  count2_r  +  1;
											 	else
												   count2_r  <=  0  ;
												case(count2_r)
												0:  Spi_Mosi_r   <=     W5500_head[count3_r-1];  
												4:  Spi_Clk_r    <=     1;        
												8:  count3_r     <=     count3_r   -   8'd1;    //发送完                                  												
												9: begin 
												   Spi_Clk_r     <=     0; 
                                       count_bits_r  <=     count_bits_r +  1;													
													 if(count3_r == 0 )//发送命令则继续发送数据 完成
													   begin
														 count1_r     <=    9 ;
														count2_r      <=     0  ;
														count3_r      <=     config_data_len;
														if(W_R_flag)
														begin
														 if(buffer_flag)
														  begin
														   state_reg	  <=     s_Tx_data_buffer;//发送buffer中的数据
															count3_r      <=     0;
														  end
														 else
														    state_reg	  <=     s_Tx_data;													   
														end

														 else
														  state_reg	  <=     s_Rx_data;
														end														 	
													end
													
											  endcase
							   end
					s_Tx_data:begin//// 发送16位偏移地址  和  8 位控制命令 
									 if(count1_r == 0) //等待 10 个时钟
										 begin
					                      if(count2_r <=  9)  //在一个时钟周期内完成读取数据和传输
					                        count2_r  <=  count2_r  +  1;
											 	else
												   count2_r  <=  0  ;
													
												case(count2_r)
												0:  Spi_Mosi_r   <=     W5500_config_data[count3_r-1];  
												4:  Spi_Clk_r    <=     1;        
												8:  count3_r     <=     count3_r   -   8'd1;    //发送完                                  												
												9: begin 
												   Spi_Clk_r     <=     0; 
                                       count_bits_r  <=     count_bits_r +  1;														
													 if(count3_r == 0 )//发送命令则继续发送数据 完成
													   begin													  
														state_reg	  <=     s_end;
														count2_r      <=     0  ;
														Tx_edone_r    <=     1;
														
														end														 	
													end
											  endcase
										end
									    else
										   begin
					                   count1_r     <=    count1_r  -  1;
										   end
							   end
					s_Tx_data_buffer:begin  // 发送buffer缓冲的数据
					                      if(count2_r <=  9)  //在一个时钟周期内完成读取数据和传输
					                        count2_r  <=  count2_r  +  1;
												else
												   count2_r  <=  0  ;
												case(count2_r)
												0:  Tx_addr_r    <=     count3_r[13:0]+1; 
												2:  Spi_Mosi_r   <=     Tx_data;  
												4:  Spi_Clk_r    <=     1;        
												8:  count3_r     <=     count3_r   +   8'd1;    //发送完                                  												
												9: begin 
												   Spi_Clk_r     <=     0; 														
													 if(count3_r == Spi_Len+1  )//发送命令则继续发送数据 完成
													   begin
														count2_r      <=     0  ;
														Tx_edone_r    <=     1;
													   state_reg	  <=     s_end;
														count3_r      <=    0;
														end														 	
													end
													
											  endcase
							    end							
								
								
								
					 s_Rx_data:begin// 读数据 
					               if(count1_r == 0) //等待 10 个时钟
										 begin
					                      if(count2_r <=  9)  //在一个时钟周期内完成读取数据和传输
					                        count2_r  <=  count2_r  +  1;
												else
												   count2_r  <=  0  ;
					                      
												case(count2_r)
												0:Spi_Clk_r                   <=     1; 
                                    3: begin
     												W5500_RX_data_r[count3_r-1]  <=     Spi_Miso;												
													end
												4: Spi_Clk_r    <=     0; 
												8: count3_r     <=     count3_r   -   1;  //接收完                                 												
												9: begin
													 if(count3_r ==  0 )//读取数据结束
													   begin
													   state_reg	  <=     s_end;
														count2_r      <=     0  ;
														Rx_edone_r    <=     1;
														end
													end
											  endcase
										end
									    else
										   begin
					                   count1_r     <=    count1_r  -  1;
										   end
							       end
					 s_end:begin// 本次传输数据结束
					               W5500_RX_data_1r <=   W5500_RX_data_r;
 					               count1_r        <=     count1_r  +  1 ;
										 if(count1_r == 10 )	//等待时钟后片选信号拉高 
											begin                               
                                  Spi_Ce_r     <=     1;
											 count1_r     <=     0; 
											 Rx_edone_r   <=     0;
                                  Tx_edone_r   <=     0;
											 state_reg	  <=	   s_idle;
										   end
							       end
 					   default:		state_reg	  <=	   s_idle;		
					endcase
					
					
				end
				
				
			end  
		
			//tet
	 assign           Spi_Ce    =   Spi_Ce_r ;   //spi通信片选信号    低有效
    assign           Spi_Clk   =   Spi_Clk_r  ; //spi通信时钟信号
    assign           Spi_Mosi  =   Spi_Mosi_r;  //spi通信发送数据 

    assign           Tx_addr   =  Tx_addr_r ;
 //  assign           Rx_addr   =  Rx_addr_r ;
 //   assign           Rx_data   =  Rx_data_r  ;
    assign           Tx_edone  =  Tx_edone_r ;
    assign           Rx_edone  =  Rx_edone_r ;	 

    assign           W5500_RX_data  =  W5500_RX_data_1r;      


endmodule

