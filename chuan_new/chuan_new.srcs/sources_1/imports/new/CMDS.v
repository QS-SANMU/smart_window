`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/09 18:27:58
// Design Name: 
// Module Name: CMDS
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


module LD3320_cmds(clk,rst_n,rx_done,data,cmds,cmd_end
    );
	input clk;
	input rst_n;
	input rx_done;
	input [7:0]data;
	input cmd_end;
	output reg [3:0]cmds;
//	output reg send_en;
	
	reg [7:0]tmp_data;
	reg tmp0_rx_done;
	reg tmp1_rx_done;
	reg tmp2_rx_done;
//	reg [27:0]cnt;
	
always@(posedge clk or negedge rst_n)
	begin 
		if(!rst_n)
			begin
			tmp0_rx_done<=0;
			tmp1_rx_done<=0;
			tmp2_rx_done<=0;
			end
		else 
			begin
			tmp0_rx_done<=rx_done;
			tmp1_rx_done<=tmp0_rx_done;
			tmp2_rx_done<=tmp1_rx_done;
			end
	end
	
always@(posedge clk or negedge rst_n)
	begin 
		if(!rst_n)
			tmp_data<=8'd0;
		else if(tmp1_rx_done)
			tmp_data<=data;
		else if(cmd_end)
		  tmp_data<=8'd0;
		else
			tmp_data<=tmp_data;
	end



always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			cmds<=4'b0000;
	   //else if(cmd_end == 1'b1)
	      //cmds <= 'd0;
		else if(tmp2_rx_done)
			begin
				case(tmp_data)
					"1":cmds<=4'b0001;
					"2":cmds<=4'b0010;
					"3":cmds<=4'b0011;
					"4":cmds<=4'b0100;
					"5":cmds<=4'b0101;
					"6":cmds<=4'b0110;//0100
					"7":cmds<=4'b0111;//0101
					default:cmds<=4'b0000;
				endcase
			end
		else
			cmds<=cmds;
	end
	

			

endmodule

