`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 16:32:18
// Design Name: 
// Module Name: tx_contr_cmd_1
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
module tx_contr_cmd_1(
	input clk,
	input rst,
	input tx_start,
	input tx_done,
	output reg tx_en,
	output reg [7:0] data_out
    );
	
	localparam cmd = 96'hEF01FFFFFFFF010003010005;
	
	reg work_on;
	reg work_off;
	reg [4:0] state;
	reg t1,t2;
	wire tx_done_flag;
	
	
	always@(posedge clk or negedge rst)
	if(!rst)
		begin
			t1 <= 1'b0;
			t2 <= 1'b0;
		end
	else
		begin
			t1 <= tx_done;
			t2 <= t1;
		end
		
	assign tx_done_flag = (~t2)&(t1);

	
	// 工作标志
	always@(posedge clk or negedge rst)     
	if(!rst)
		work_on <= 1'b0;
	else if(tx_start)
		work_on <= 1'b1;
	else if(work_off)
		work_on <= 1'b0;
	else
		work_on <= work_on;
	

	
	
	always@(posedge clk or negedge rst)
	if(!rst)
		begin
			state <= 5'd0;
			data_out <= 8'd0;
			work_off <= 1'b0;
			tx_en <= 1'b0;
		end
	else if(work_on)
		case(state)
			5'd0 : 
				begin
					state <= 5'd1;
					data_out <= 8'd0;
					work_off <= 1'b0;
					tx_en <= 1'b0;
				end
			5'd1 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[95:88];
					state <= 5'd2;
				end
			5'd2 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 5'd3;
					else	
						state <= state;
				end
			5'd3 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[87:80];
					state <= 5'd4;
				end
			5'd4 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 5'd5;
					else	
						state <= state;
				end
			5'd5 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[79:72];
					state <= 5'd6;
				end
			5'd6 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 5'd7;
					else	
						state <= state;
				end
			5'd7 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[71:64];
					state <= 5'd8;
				end
			
			
			5'd8 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 5'd9;
					else	
						state <= state;
				end
			5'd9 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[63:56];
					state <= 5'd10;
				end
			5'd10 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 5'd11;
					else	
						state <= state;
				end
			5'd11 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[55:48];
					state <= 5'd12;
				end
			5'd12 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 5'd13;
					else	
						state <= state;
				end
			5'd13 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[47:40];
					state <= 5'd14;
				end
			5'd14 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 5'd15;
					else	
						state <= state;
				end
			5'd15 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[39:32];
					state <= 5'd16;
				end
			5'd16 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 5'd17;
					else	
						state <= state;
				end
			5'd17 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[31:24];
					state <= 5'd18;
				end
			5'd18 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 5'd19;
					else	
						state <= state;
				end
			5'd19 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[23:16];
					state <= 5'd20;
				end
			5'd20 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 5'd21;
					else	
						state <= state;
				end
			5'd21 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[15:8];
					state <= 5'd22;
				end
			5'd22 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 5'd23;
					else	
						state <= state;
				end
			5'd23 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[7:0];
					state <= 5'd24;
				end
			5'd24 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						begin
							state <= 5'd0;
							work_off <= 1'b1;
						end
					else	
						state <= state;
				end
			
		endcase
	else 
		begin
			state <= 5'd0;
			data_out <= 8'd0;
			work_off <= 1'b0;
			tx_en <= 1'b0;
		end
	
	


endmodule

