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
    input  [7:0]     clk_div,   //ʱ�ӷ�Ƶϵ��  
	 input            reset,//��λ�ź�
    input            T_flag,    //���������־ 
    input            W_R_flag,  //1ʱд���� 0ʱ������	
	 
    input  [7:0]     config_data_len,//�����������ݳ���bits   ����ͽ���ʱ����  
	 input  [31:0]    W5500_head,  //w5500��ƫ�Ƶ�ַ +   ����ͷ
	 input  [47:0]    W5500_config_data,//w5500�Ŀ�����������
	 input            buffer_flag,//1: ���� buffer������  0�����ͱ������
	 input  [15:0]    Spi_Len,   //��Ҫ���������bits��
    output [13:0]    Tx_addr,   //��ȡ�������ݵĵ�ַ
    input            Tx_data,   //��������bit
	 output [47:0]    W5500_RX_data,//���յ�w5500�ķ�������
    //output [12:0]    Rx_addr,   //�洢�������ݵĵ�ַ
   // output           Rx_data,   //��������bit 
    output           Tx_edone,  //���η���������ɱ�־ ����Ч
    output           Rx_edone,  //���ν���������ɱ�־ ����Ч
	 output           Spi_Ce,    //spiͨ��Ƭѡ�ź�    ����Ч
    output           Spi_Clk,   //spiͨ��ʱ���ź�
    output           Spi_Mosi,  //spiͨ�ŷ�������
    input            Spi_Miso   //spiͨ�Ž�������
    );
    reg           Spi_Ce_r    =  1 ;  //spiͨ��Ƭѡ�ź�    ����Ч
    reg           Spi_Clk_r   =  0  ; //spiͨ��ʱ���ź�
    reg           Spi_Mosi_r  =  0 ;       //spiͨ�ŷ�������   
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
	 
	 
(*KEEP = "TRUE"*)	 reg  [47:0]    W5500_RX_data_r;//���յ�w5500�ķ�������
(*KEEP = "TRUE"*)	 reg  [47:0]    W5500_RX_data_1r;//���յ�w5500�ķ������� 
	 
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
		   if(reset==0)//��λ����Ч
			  begin
			    state_reg		               <=	   s_idle;
				 Spi_Ce_r                     <=    1;//Ƭѡ�ź����ͷ�������
				 count1_r                     <=    0;
				 count2_r                     <=    0;
				 count3_r                     <=    0;				 
				 Tx_addr_r                    <=    0;
			    count_bits_r                 <=    0;	
			  end
			 else
			  begin
				case(state_reg)
					s_idle:begin// ����״̬ ������ݴ�������
												if(T_flag_ed  == 0  && T_flag  ==  1)	// ��Ҫ����ͽ�������
												//if(1)
												begin
												  Spi_Ce_r     <=     0;//Ƭѡ�ź�����׼����������
												  count1_r     <=     0;
												  count3_r     <=     0;// ����bits��������
												  state_reg		<=     s_wait;
												end
//												else
//												begin
//												  state_reg		<=	    s_idle ;
//												  Spi_Ce_r     <=     1;
//												end
							   end
					s_wait:begin// Ƭѡ���ͺ�ȴ�����ʱ�� 
					                       count1_r     <=    count1_r  +  1;
												if(count1_r == 20)	
												begin
												  count1_r     <=     0;
												  count2_r     <=     0;// ʱ�Ӽ�����
												  count3_r     <=     24;// ����bits��������
												  Tx_addr_r    <=     0;
												  Spi_Clk_r    <=     0;
				                                  count_bits_r <=     0;	
												  Spi_Ce_r     <=     0;//Ƭѡ�ź�����׼����������
												  state_reg	   <=     s_Tx_head;
												end
							   end
					s_Tx_head:begin//// ����16λƫ�Ƶ�ַ  ��  8 λ��������   
					                      if(count2_r <=  9)  //��һ��ʱ����������ɶ�ȡ���ݺʹ���
					                        count2_r  <=  count2_r  +  1;
											 	else
												   count2_r  <=  0  ;
												case(count2_r)
												0:  Spi_Mosi_r   <=     W5500_head[count3_r-1];  
												4:  Spi_Clk_r    <=     1;        
												8:  count3_r     <=     count3_r   -   8'd1;    //������                                  												
												9: begin 
												   Spi_Clk_r     <=     0; 
                                       count_bits_r  <=     count_bits_r +  1;													
													 if(count3_r == 0 )//��������������������� ���
													   begin
														 count1_r     <=    9 ;
														count2_r      <=     0  ;
														count3_r      <=     config_data_len;
														if(W_R_flag)
														begin
														 if(buffer_flag)
														  begin
														   state_reg	  <=     s_Tx_data_buffer;//����buffer�е�����
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
					s_Tx_data:begin//// ����16λƫ�Ƶ�ַ  ��  8 λ�������� 
									 if(count1_r == 0) //�ȴ� 10 ��ʱ��
										 begin
					                      if(count2_r <=  9)  //��һ��ʱ����������ɶ�ȡ���ݺʹ���
					                        count2_r  <=  count2_r  +  1;
											 	else
												   count2_r  <=  0  ;
													
												case(count2_r)
												0:  Spi_Mosi_r   <=     W5500_config_data[count3_r-1];  
												4:  Spi_Clk_r    <=     1;        
												8:  count3_r     <=     count3_r   -   8'd1;    //������                                  												
												9: begin 
												   Spi_Clk_r     <=     0; 
                                       count_bits_r  <=     count_bits_r +  1;														
													 if(count3_r == 0 )//��������������������� ���
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
					s_Tx_data_buffer:begin  // ����buffer���������
					                      if(count2_r <=  9)  //��һ��ʱ����������ɶ�ȡ���ݺʹ���
					                        count2_r  <=  count2_r  +  1;
												else
												   count2_r  <=  0  ;
												case(count2_r)
												0:  Tx_addr_r    <=     count3_r[13:0]+1; 
												2:  Spi_Mosi_r   <=     Tx_data;  
												4:  Spi_Clk_r    <=     1;        
												8:  count3_r     <=     count3_r   +   8'd1;    //������                                  												
												9: begin 
												   Spi_Clk_r     <=     0; 														
													 if(count3_r == Spi_Len+1  )//��������������������� ���
													   begin
														count2_r      <=     0  ;
														Tx_edone_r    <=     1;
													   state_reg	  <=     s_end;
														count3_r      <=    0;
														end														 	
													end
													
											  endcase
							    end							
								
								
								
					 s_Rx_data:begin// ������ 
					               if(count1_r == 0) //�ȴ� 10 ��ʱ��
										 begin
					                      if(count2_r <=  9)  //��һ��ʱ����������ɶ�ȡ���ݺʹ���
					                        count2_r  <=  count2_r  +  1;
												else
												   count2_r  <=  0  ;
					                      
												case(count2_r)
												0:Spi_Clk_r                   <=     1; 
                                    3: begin
     												W5500_RX_data_r[count3_r-1]  <=     Spi_Miso;												
													end
												4: Spi_Clk_r    <=     0; 
												8: count3_r     <=     count3_r   -   1;  //������                                 												
												9: begin
													 if(count3_r ==  0 )//��ȡ���ݽ���
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
					 s_end:begin// ���δ������ݽ���
					               W5500_RX_data_1r <=   W5500_RX_data_r;
 					               count1_r        <=     count1_r  +  1 ;
										 if(count1_r == 10 )	//�ȴ�ʱ�Ӻ�Ƭѡ�ź����� 
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
	 assign           Spi_Ce    =   Spi_Ce_r ;   //spiͨ��Ƭѡ�ź�    ����Ч
    assign           Spi_Clk   =   Spi_Clk_r  ; //spiͨ��ʱ���ź�
    assign           Spi_Mosi  =   Spi_Mosi_r;  //spiͨ�ŷ������� 

    assign           Tx_addr   =  Tx_addr_r ;
 //  assign           Rx_addr   =  Rx_addr_r ;
 //   assign           Rx_data   =  Rx_data_r  ;
    assign           Tx_edone  =  Tx_edone_r ;
    assign           Rx_edone  =  Rx_edone_r ;	 

    assign           W5500_RX_data  =  W5500_RX_data_1r;      


endmodule

