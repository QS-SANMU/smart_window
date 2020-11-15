`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/20 15:48:06
// Design Name: 
// Module Name: send_data
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


module dialog(clk,rst_n,rx_data,tx_data,send_data_valid,en,w5500_rx_flag,clr
);
	input clk;
	input rst_n;
	input w5500_rx_flag;
	input clr;
	input [47:0]rx_data;
	
	output reg [15:0]tx_data;
	
	output reg send_data_valid;
	output reg en;
	
	reg receive_flag_ed0;
	reg receive_flag_ed1;
	reg [4:0]send_cnt;
	reg tx_done;
	wire [7:0]command;
//	reg [7:0]command;
	
	reg [3:0]c_state;
	reg [3:0]n_state;

//	reg [63:0] data0=64'b0100101101010011_0100001101110011_1011111110101011_1100010111001101;//室温25
//	reg [63:0] data1=64'b0101010101010011_0001001101101101_1011111110101011_1100010111001101;//湿度36
//	reg [63:0] data2=64'b1010011100110011_0100001101110011_1011111110101011_1100010111001101;//体温36
//	reg [63:0] data3=64'b0000111111011101_0110011110001011_1011111110101011_1100010111001101;//火焰正常
//	reg [63:0] data4=64'b0011001110001011_1011011101110011_1011111110101011_1100010111001101;//烟雾正常


    reg  [383:0] data=384'b0100101101010011_0100001101110011_1011111110101011_1100010111001101_00000100_00000100_0101010101010011_0001001101101101_1011111110101011_1100010111001101_00000100_00000100_1010011100110011_0100001101110011_1011111110101011_1100010111001101_00000100_00000100_0000111111011101_0110011110001011_1011111110101011_1100010111001101_00000100_00000100_0011001110001011_1011011101110011_1011111110101011_1100010111001101;
    
  
	assign command=rx_data[7:0];


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
        send_data_valid<=0;
        tx_data<=16'd0;
        send_cnt<=5'd25;
        en=0;
        end
     else if(w5500_rx_flag)
        begin
            send_cnt<=5'd0;
            en<=0;
         end
     else if(command==8'b00110000 & send_cnt<=5'd23)
  // else if(command=="D" & send_cnt<=4'd2)
             begin
                 send_data_valid<=1;
                 tx_data<=data[383:368];
                 data<={data[367:0],data[383:368]};
                 send_cnt<=send_cnt+1;
             end
    
     else if(send_cnt==5'd24) 
              begin
                 send_data_valid<=0;
                 en=1;
              end
 end
endmodule
