`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 16:34:51
// Design Name: 
// Module Name: tx_contr_cmd_3
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
module tx_contr_cmd_3(
	input clk,
	input rst,
	input tx_start,
	input tx_done,
	output reg tx_en,
	output reg [7:0] data_out
    );
	
	localparam cmd = 136'hEF01FFFFFFFF01000804010000012C003B;
	
	reg work_on;
	reg work_off;
	reg [5:0] state;
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
			state <= 6'd0;
			data_out <= 8'd0;
			work_off <= 1'b0;
			tx_en <= 1'b0;
		end
	else if(work_on)
		case(state)
			6'd0 : 
				begin
					state <= 6'd1;
					data_out <= 8'd0;
					work_off <= 1'b0;
					tx_en <= 1'b0;
				end
			6'd1 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[135:128];
					state <= 6'd2;
				end
			6'd2 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd3;
					else	
						state <= state;
				end
			6'd3 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[127:120];
					state <= 6'd4;
				end
			6'd4 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd5;
					else	
						state <= state;
				end
			6'd5 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[119:112];
					state <= 6'd6;
				end
			6'd6 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd7;
					else	
						state <= state;
				end
			6'd7 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[111:104];
					state <= 6'd8;
				end
			
			
			6'd8 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd9;
					else	
						state <= state;
				end
			6'd9 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[103:96];
					state <= 6'd10;
				end
			6'd10 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd11;
					else	
						state <= state;
				end
			6'd11 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[95:88];
					state <= 6'd12;
				end
			6'd12 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd13;
					else	
						state <= state;
				end
			6'd13 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[87:80];
					state <= 6'd14;
				end
			6'd14 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd15;
					else	
						state <= state;
				end
			6'd15 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[79:72];
					state <= 6'd16;
				end
			6'd16 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd17;
					else	
						state <= state;
				end
			6'd17 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[71:64];
					state <= 6'd18;
				end
			6'd18 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd19;
					else	
						state <= state;
				end
			6'd19 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[63:56];
					state <= 6'd20;
				end
			6'd20 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd21;
					else	
						state <= state;
				end
			6'd21 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[55:48];
					state <= 6'd22;
				end
			6'd22 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd23;
					else	
						state <= state;
				end
			6'd23 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[47:40];
					state <= 6'd24;
				end
			6'd24 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd25;
					else	
						state <= state;
				end
			6'd25 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[39:32];
					state <= 6'd26;
				end
			6'd26 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd27;
					else	
						state <= state;
				end
			6'd27 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[31:24];
					state <= 6'd28;
				end
			6'd28 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd29;
					else	
						state <= state;
				end
			6'd29 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[23:16];
					state <= 6'd30;
				end
			6'd30 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd31;
					else	
						state <= state;
				end
			6'd31 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[15:8];
					state <= 6'd32;
				end
			6'd32 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						state <= 6'd33;
					else	
						state <= state;
				end
			
			6'd33 :
				begin
					tx_en <= 1'b1;
					data_out <= cmd[7:0];
					state <= 6'd34;
				end
			6'd34 : 
				begin
					tx_en <= 1'b0;
					if(tx_done_flag)
						begin
							state <= 6'd0;
							work_off <= 1'b1;
						end
					else	
						state <= state;
				end
			
		endcase
	else 
		begin
			state <= 6'd0;
			data_out <= 8'd0;
			work_off <= 1'b0;
			tx_en <= 1'b0;
		end
	
	


endmodule


