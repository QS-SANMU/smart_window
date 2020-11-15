`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/09 18:13:52
// Design Name: 
// Module Name: JQ8900_CMDS
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


module JQ8900_cmds(clk,rst_n,uart_state,tx_done,cmds,data,cmd_end
    );

  input clk;
  input rst_n;
  input uart_state;
  input tx_done;
  input [4:0]cmds;
  
 /*
 00001  我是小花
 00010窗户已打开
 00011窗户已关闭
 00100窗帘已打开
 00101窗帘已关闭
 00110风速较大，已自动关窗
 00111下雨自动关窗
 01000空气质量差
 01001 CO超标
 01010火焰异常
 01011有人摔倒
 01100睡觉时间
 01101吃药时间
 01110指纹错误
 01111指纹正确
 */
  output reg  [7:0]data;
  output reg cmd_end;
  reg [3:0]tx_cnt;
  reg tx_done_tmp0;
  reg tx_done_tmp1;
  wire pdge;
  
  always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			begin
			tx_done_tmp0<=0;
			tx_done_tmp1<=0;
			end
          else 
			begin
			tx_done_tmp0<=tx_done;
			tx_done_tmp1<=tx_done_tmp0;
			end
	end
assign pdge=((!tx_done_tmp1)&tx_done_tmp0);
  
 always@(posedge clk or negedge rst_n)
begin
  if(!rst_n)
   begin
   data<=8'd0; 
   tx_cnt<=4'd0;
   cmd_end<=0;
   end
  else if(uart_state)
	begin
		//cmd_end<=0;
	case(cmds)
		5'd1:begin
				case(tx_cnt)
						4'd0:begin
						        cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						        cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						        cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						        cmd_end <= 1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						        cmd_end <= 1'b0;
								data<=8'h01;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hB4;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1;
								end
							end
					
				endcase
			end			
		5'd2:begin
				case(tx_cnt)
						4'd0:begin
						        cmd_end<=1'b0; 
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						        cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						        cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						        cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						        cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hB5;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end			
		5'd3:begin
				case(tx_cnt)
						4'd0:begin
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin
						cmd_end<=1'b0; 
								data<=8'h03;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hB6;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end			
		5'd4:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h04;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
						cmd_end<=1'b0;
								data<=8'hB7;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1;
								end
							end
				endcase
			end		
			
	   5'd5:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h05;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hB8;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1;
								end
							end
				endcase
			end		
        5'd6:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h06;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hB9;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end		
		5'd7:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hBA;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end		
		5'd8:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h08;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hBB;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end		
		5'd9:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h09;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hBC;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end		
		5'd10:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h0A;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hBD;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end		
		5'd11:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h0B;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hBE;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end		
		5'd12:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h0C;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hBF;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end		
			
	   5'd13:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h0D;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hC0;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end		
	5'd14:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h0E;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hC1;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end		
		5'd15:begin
				case(tx_cnt)
						4'd0:begin 
						cmd_end<=1'b0;
								data<=8'hAA;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd1:begin 
						cmd_end<=1'b0;
								data<=8'h07;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						4'd2:begin 
						cmd_end<=1'b0;
								data<=8'h02;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd3:begin 
						cmd_end<=1'b0;
								data<=8'h00;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd4:begin 
						cmd_end<=1'b0;
								data<=8'h0F;
								if(pdge)
								tx_cnt<=tx_cnt+1;
							end
						
						4'd5:begin 
								data<=8'hC2;
								if(pdge)
								begin
								tx_cnt<=4'd0;
								cmd_end<=1'b1;
								end
							end
				endcase
			end			
		default: begin 
		data<=8'd0; 
		cmd_end <= 1'b0;
		end
	endcase
	end
  else
	begin
	  data<=8'd0; 
	  tx_cnt<=4'd0;
       cmd_end<=0;
	end
end
	  
	  
endmodule
