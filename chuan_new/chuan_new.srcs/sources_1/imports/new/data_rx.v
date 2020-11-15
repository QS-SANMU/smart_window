`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 13:58:24
// Design Name: 
// Module Name: data_rx
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

module data_rx(
	input clk,
	input rst,
	input rx_done,
	input [7:0] data_in,
	input [3:0] state,
	output reg rx_cmd_1_yes,
	output reg rx_cmd_2_yes,
	output reg rx_cmd_3_yes,
	output reg rx_cmd_1_no,
	output reg rx_cmd_2_no,
	output reg rx_cmd_3_no
    );
	
	
	reg [95:0] data_cmd_1;
	reg [95:0] data_cmd_2;
	reg [127:0] data_cmd_3;
	
	always@(posedge clk or negedge rst)
	if(!rst)
		begin
			data_cmd_1 <= 96'd0;
			data_cmd_2 <= 96'd0;
			data_cmd_3 <= 128'd0;
			rx_cmd_1_yes <= 1'b0;
			rx_cmd_2_yes <= 1'b0;
			rx_cmd_3_yes <= 1'b0;
			rx_cmd_1_no <= 1'b0;
			rx_cmd_2_no <= 1'b0;
			rx_cmd_3_no <= 1'b0;
		end
	else	
		case(state)
			4'd1 :
					begin
						if(rx_done)
							data_cmd_1 <= {data_cmd_1[87:0],data_in};
						if(data_cmd_1[95:88] == 8'hEF && data_cmd_1[23:16] == 8'h00)
							rx_cmd_1_yes <= 1'b1;
						else if(data_cmd_1[95:88] == 8'hEF && data_cmd_1[23:16] != 8'h00)
							rx_cmd_1_no <= 1'b1;
					end
			4'd5 : 
					begin
						if(rx_done)
							data_cmd_2 <= {data_cmd_2[87:0],data_in};
						if(data_cmd_2[95:88] == 8'hEF && data_cmd_2[23:16] == 8'h00)
							rx_cmd_2_yes <= 1'b1;
						else if(data_cmd_2[95:88] == 8'hEF && data_cmd_2[23:16] != 8'h00)
							rx_cmd_2_no <= 1'b1;	
					end
			4'd8 : 
					begin
						if(rx_done)
							data_cmd_3 <= {data_cmd_3[119:0],data_in};
						if(data_cmd_3[127:120] == 8'hEF && data_cmd_3[55:48] == 8'h00)
							rx_cmd_3_yes <= 1'b1;
						else if(data_cmd_3[127:120] == 8'hEF && data_cmd_3[55:48] != 8'h00)
							rx_cmd_3_no <= 1'b1;	
					end
			default :
					begin
						data_cmd_1 <= 96'd0;
						data_cmd_2 <= 96'd0;
						data_cmd_3 <= 128'd0;
						rx_cmd_1_yes <= 1'b0;
						rx_cmd_2_yes <= 1'b0;
						rx_cmd_3_yes <= 1'b0;
						rx_cmd_1_no <= 1'b0;
						rx_cmd_2_no <= 1'b0;
						rx_cmd_3_no <= 1'b0;
					end
		endcase


endmodule
