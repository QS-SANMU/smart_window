`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 14:04:11
// Design Name: 
// Module Name: cmd_center
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


module cmd_center(
	input clk,
	input rst,
	input rx_cmd_1_yes,
	input rx_cmd_2_yes,
	input rx_cmd_3_yes,
	input rx_cmd_1_no,
	input rx_cmd_2_no,
	input rx_cmd_3_no,
	output reg cmd_1,
	output reg cmd_2,
	output reg cmd_3,
	output reg check_ok,
	output reg check_no,
	output reg [3:0] state
    );
	
	localparam cnt_cmd_1_end = 26'd25_000_000 - 1'b1;
	
	reg [25:0] cnt_cmd_1;
	
	
	reg cmd_1_en;
	

	always@(posedge clk or negedge rst)
	if(!rst)
		cnt_cmd_1 <= 26'd0;
	else if(state == 4'd1)
		begin
			if(cnt_cmd_1 == cnt_cmd_1_end)
				cnt_cmd_1 <= 26'd0;
			else
				cnt_cmd_1 <= cnt_cmd_1 + 1'b1;
		end
	else
		cnt_cmd_1 <= 26'd0;
	
	
	always@(posedge clk or negedge rst)
	if(!rst)
		cmd_1_en <= 1'b0;
	else if(cnt_cmd_1 == cnt_cmd_1_end)
		cmd_1_en <= 1'b1;
	else	
		cmd_1_en <= 1'b0;
	
	
	always@(posedge clk or negedge rst)
	if(!rst)
		begin
			cmd_1 <= 1'b0;
			cmd_2 <= 1'b0;
			cmd_3 <= 1'b0;
			state <= 4'd0;
			check_ok <= 1'b0;
			check_no <= 1'b0;
		end
	else
		case(state)
			4'd0 : 
					begin
						cmd_1 <= 1'b0;
						cmd_2 <= 1'b0;
						cmd_3 <= 1'b0;
						state <= 4'd1;
						check_ok <= 1'b0;
						check_no <= 1'b0;
					end
			4'd1 :
					begin
						if(rx_cmd_1_yes)
							state <= 4'd3;
						else if(rx_cmd_1_no)
							state <= 4'd0;
						else if(cmd_1_en)
							begin
								cmd_1 <= 1'b1;
								state <= 4'd2;
							end
						else
							begin
								state <= state;
								cmd_1 <= 1'b0;
							end
					end
			4'd2 :
					begin
						cmd_1 <= 1'b0;
						state <= 4'd1;
					end	
			4'd3 :
					begin
						cmd_2 <= 1'b1;
						state <= 4'd4;
					end
			4'd4 : 
					begin
						cmd_2 <= 1'b0;
						state <= 4'd5;
					end
			4'd5 :	
					begin
						if(rx_cmd_2_yes)	
							state <= 4'd6;
						else if(rx_cmd_2_no)
							state <= 4'd0;
						else
							state <= state;
					end
			4'd6 :
					begin
						cmd_3 <= 1'b1;
						state <= 4'd7;
					end
			4'd7 : 
					begin
						cmd_3 <= 1'b0;
						state <= 4'd8;
					end
			4'd8:
					begin
						if(rx_cmd_3_yes)	
							begin
								state <= 4'd0;
								check_ok <= 1'b1;
							end
						else if(rx_cmd_3_no)
							begin
								state <= 4'd0;
								check_no <= 1'b1;
							end
						else
							state <= state;
					end
			default : 
					begin
						cmd_1 <= 1'b0;
						cmd_2 <= 1'b0;
						cmd_3 <= 1'b0;
						state <= 4'd0;
						check_ok <= 1'b0;
						check_no <= 1'b0;
					end
		endcase
		


endmodule

