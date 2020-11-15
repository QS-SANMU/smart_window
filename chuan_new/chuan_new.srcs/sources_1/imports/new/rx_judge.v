`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/06 23:34:18
// Design Name: 
// Module Name: rx_judge
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
module rx_judge(
    clk,
	rst_n,
	parallel_data_rx,
	rx_down,
	call,
	window_L,
	window_R,
	curtain_1,
	curtain_2,
	massage);
	input clk;            //ϵͳʱ���ź�
	input rst_n;          //��λ
	input [7:0]parallel_data_rx;    //���յ��ĵ��ֽڲ�������
	input rx_down;           //һ���ֽڽ�������ź�
	output reg[1:0]massage;
	output reg[3:0]call;
	output reg[3:0]window_L;
	output reg[3:0]window_R;
	output reg[2:0]curtain_1;
	output reg[2:0]curtain_2;
	
	reg [3:0]current_state;     //״̬����̬���̬���塣
	parameter
	 S0=4'b0000,S1=4'b0001,S2=4'b0010,S3=4'b0011,S4=4'b0100,S5=4'b0101,S6=4'b0110,S7=4'b0111,S8=4'b1000;     //״̬��״̬����

	 reg [3:0]k1;
	 reg [3:0]w1;
	 
	//״̬ת��ģ��
    always@(posedge clk or negedge rst_n )
	begin
	if(!rst_n)
	    begin
	    current_state<=S0;
	    w1 <= 4'd0;
		k1 <= 4'd0;
	    end
	else if(rx_down==1'b1)
	begin
	    case(current_state)
	    S0:begin
	    	if(parallel_data_rx=='hA5)
	    		begin
	    	    current_state<=S1;
	    		end
	    	else
	    		begin		 
	    		current_state<=S0;
	    		end
	       end
	    S1:begin
	    	if(parallel_data_rx=='h5A)
	    		begin
	    	    current_state<=S2;
	    		end
	    	else
	    		begin
	    		current_state<=S0;
	    		end
	       end
	    S2:begin
	    	if(parallel_data_rx=='h06)
	    		begin
	    	    current_state<=S3;
	    		end
	    	else
	    		begin	
	    		current_state<=S0;
	    		end
	       end
	    S3:begin
	    	if(parallel_data_rx=='h83)
	    		begin	
	    	    current_state<=S4;
	    		end
	    	else
	    		begin
	    		current_state<=S0;
	    		end
	       end   
	    S4:begin
	    	if(parallel_data_rx=='h00)
	    	    current_state<=S5;
	    	else
	    		begin
	    		current_state<=S0;
	    		end
	       end
	    S5:begin
	    	    if(parallel_data_rx=='h10)    //10��ַλ��绰  20�󴰻� 30�Ҵ��� 40���� 50���� 60 ��������绰 70���͹㳡����Լ
	    	    	begin
	    	        current_state<=S6;
	    	    	k1  <= 4'b0001;
	    	    	end
	    	    else if(parallel_data_rx=='h20)   //��
	    	    	begin
	    	    	k1 <= 4'b0010; 
	    	    	current_state<=S6;
	    	    	end
	    	    else if(parallel_data_rx=='h30)   //�Ҵ�
	    	    	begin
	    	    	k1 <= 4'b0011;
	    	    	current_state<=S6;
	    	    	end
	    		else if(parallel_data_rx=='h40)   //����
	    	    	begin
	    	    	k1 <= 4'b0100; 
	    	    	current_state<=S6;
	    	    	end
	    		else if(parallel_data_rx=='h50)   //����
	    	    	begin
	    	    	k1 <= 4'b0101; 
	    	    	current_state<=S6;
	    	    	end
	    		else if(parallel_data_rx=='h60)   //���Ⲧ��
	    	    	begin
	    	    	k1 <= 4'b0110; 
	    	    	current_state<=S6;
	    	    	end
				else if(parallel_data_rx=='h70)   //�㳡��
	    	    	begin
	    	    	k1 <= 4'b0110; 
	    	    	current_state<=S6;
	    	    	end
				else if(parallel_data_rx=='h80)     //һ����
	    	    	begin
	    	    	k1 <= 4'b0110; 
	    	    	current_state<=S6;
	    	    	end
				else if(parallel_data_rx=='h90)   //һ���ر�
	    	    	begin
	    	    	k1 <= 4'b0110; 
	    	    	current_state<=S6;
	    	    	end
	    	    else
	    	        current_state <= S0;
	       end
	    S6:begin
	    	if(parallel_data_rx=='h01)       
	    		begin
	    	    current_state<=S7;
	    		end
	    	else
	    		begin
	    		current_state<=S0;
	    		end
	       end
        S7:begin
	    	if(parallel_data_rx=='h00)
	    		begin
	    	    current_state<=S8;
	    		end
			else if(parallel_data_rx=='h5c)
	    		begin
	    	    current_state<=S8;
	    		end
			else if(parallel_data_rx=='h82)
	    		begin
	    	    current_state<=S8;
	    		end
			else if(parallel_data_rx=='h35)
	    		begin
	    	    current_state<=S8;
	    		end	
			else if(parallel_data_rx=='h88)
	    		begin
	    	    current_state<=S8;
	    		end
	    	else
	    		begin
	    		
	    		current_state<=S0;
	    		end
	       end
	    
	    S8:begin
		    if(parallel_data_rx=='h00)
	        	begin
                w1 <= 4'b0000;			
	        	 current_state<=S0;
	        	end
	    	else if(parallel_data_rx=='h01)
	    		begin
                w1 <= 4'b0001;			
	    	    current_state<=S0;
	    		end
	    	else if(parallel_data_rx=='h02)
	    		begin
	    		w1 <= 4'b0010;
	    		current_state<=S0;
	    		end
	    	else if(parallel_data_rx=='h03)
	    		begin
	    		w1 <= 4'b0011;
	    		current_state<=S0;
	    		end
	    	else if(parallel_data_rx=='h04)
	    		begin
	    		w1<= 4'b0100;
	    		current_state<=S0;
	    		end
	    	else if(parallel_data_rx=='h05)
	    		begin
	    		w1 <= 4'b0101;
	    		current_state<=S0;
	    		end
	    	else if(parallel_data_rx=='h06)
	    		begin
	    		w1 <= 4'b0110;
	    		current_state<=S0;
	    		end
	    	else if(parallel_data_rx=='h07)
	    		begin
	    		w1 <= 4'b0111;
	    		current_state<=S0;
	    		end
	    	else if(parallel_data_rx=='h08)
	    		begin
	    		w1 <= 4'b1000;
	    		current_state<=S0;
	    		end
			else if(parallel_data_rx=='h09)
	    		begin
	    		w1 <= 4'b1001;
	    		current_state<=S0;
	    		end
			else if(parallel_data_rx=='hF8)    //18729164024
	    		begin
	    		w1 <= 4'b1010;     //10
	    		current_state<=S0;
				end
			else if(parallel_data_rx=='h59)   //13119160921
	    		begin
	    		w1 <= 4'b1011;    //11
	    		current_state<=S0;         
	    		end
			else if(parallel_data_rx=='h0D)   //16713725197
	    		begin
	    		w1 <= 4'b1100;  //12
	    		current_state<=S0;
	    		end
			else if(parallel_data_rx=='h8C)   //15160477836
	    		begin
	    		w1 <= 4'b1101;  //13
	    		current_state<=S0;
	    		end
			else
		       begin
		       current_state<=current_state;
               
		       end
	    end   
	    default:begin
	    	    current_state<=current_state;
	
	    	    end
	    endcase
	end
	end
	
wire [7:0]choice;
assign choice = {k1,w1};
	
always@(posedge clk or negedge rst_n)
begin
   if(!rst_n)
      begin
        
		call <= 'd0;
		window_L <= 'd10;
		window_R <= 'd10;
		curtain_1 <= 'd7;
		curtain_2 <= 'd7;
		massage <= 'd0;
	  end
	else 
	  begin
	     case(choice)
		8'd17:call <= 'd1;   //�������
		8'd18:call <= 'd2;   //����Ů��
		8'd19:call <= 'd3;   //�����ϱ
		8'd20:call <= 'd4;   //��������
		8'd21:call <= 'd5;   //120
		8'd22:call <= 'd6;   //119
		8'd23:call <= 'd7;   //120
		8'd24:call <= 'd8;   //�Ҷϵ绰
		8'd32,8'd128:window_L <= 'd0;    //�󴰻��ر�
		8'd33:window_L <= 'd1;     
		8'd34:window_L <= 'd2;
		8'd35:window_L <= 'd3;
		8'd36:window_L <= 'd4;
		8'd37:window_L <= 'd5;
		8'd38:window_L <= 'd6;
		8'd39:window_L <= 'd7;
		8'd40:window_L <= 'd8;
		8'd41,8'd137:window_L <= 'd9;   //�󴰻���135��	
		8'd48,8'd128:window_R <= 'd0;    //�Ҵ����ر�
		8'd49:window_R <= 'd1;
		8'd50:window_R <= 'd2;
		8'd51:window_R <= 'd3;
		8'd52:window_R <= 'd4;
		8'd53:window_R <= 'd5;
		8'd54:window_R <= 'd6;
		8'd55:window_R <= 'd7;
		8'd56:window_R <= 'd8;
		8'd57,8'd128:window_R <= 'd9;   //�Ҵ�����135��
		8'd64,8'd130:curtain_1 <= 'd0;   //����������ȫ�򿪣�ɹ̫����       
		8'd65:curtain_1 <= 'd1;
		8'd66:curtain_1 <= 'd2;
		8'd67:curtain_1 <= 'd3;
		8'd68:curtain_1 <= 'd4;
		8'd69,8'd146:curtain_1 <= 'd5;    //����������ȫ�رգ�˯����
		8'd80,8'd129:curtain_2 <= 'd0;    //���Ҵ�����ȫ��
		8'd81:curtain_2 <= 'd1;
		8'd82:curtain_2 <= 'd2;
		8'd83:curtain_2 <= 'd3;
		8'd84:curtain_2 <= 'd4;
		8'd85,8'd145:curtain_2 <= 'd5;   //���Ҵ�����ȫ�ر�
		8'd106:call <= 'd9;       //18729164024
		8'd107:call <= 'd10;      //13119160921
		8'd108:call <= 'd11;      //16713725197
		8'd109:call <= 'd12;      //15160477836
		8'd112:massage <= 'd1;    //�㳡����Լ
		default :;
		endcase
		
	  end
end

endmodule
