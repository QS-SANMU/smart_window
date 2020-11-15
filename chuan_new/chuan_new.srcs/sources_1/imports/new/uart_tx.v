`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 16:36:48
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input clk,
    input rst,
    input [3:0] tx_num,
    input tx_sel_data,
    input [7:0] data_in,
	output reg tx_done,
    output reg data_tx
    );

    always@(posedge clk or negedge rst)
    if(!rst)
		begin
			tx_done <= 1'b0;
			data_tx <= 1'b1;
		end
    else if(tx_sel_data)
        case(tx_num)
            0 : 
				begin
					data_tx <= 1'b0;
					tx_done <= 1'b0;
				end
            1 : data_tx <= data_in[0];
            2 : data_tx <= data_in[1];
            3 : data_tx <= data_in[2];
            4 : data_tx <= data_in[3];
            5 : data_tx <= data_in[4];
            6 : data_tx <= data_in[5];
            7 : data_tx <= data_in[6];
            8 : data_tx <= data_in[7];
            9 : 
				begin
					tx_done <= 1'b1;
					data_tx <= 1'b1;
				end
            default :
				begin
					data_tx <= 1'b1;
					tx_done <= 1'b0;
				end
        endcase



endmodule

