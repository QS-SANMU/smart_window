`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/07 00:33:10
// Design Name: 
// Module Name: Hex_BCD
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

 module Hex_BCD(
    input   [7:0]	humidity_int,
	input	[7:0]	humidity_float,
	input	[7:0]	temperature_int,
	input	[7:0]	temperature_float,
	output	[3:0]	humidity_decade,	//ʪ��ʮλ
	output	[3:0]	humidity_one,		//ʪ�ȸ�λ
	output	[3:0]	humidity_decimal,	//ʪ��С��
	output	[3:0]	temperature_decade,	//�¶�ʮλ
	output	[3:0]	temperature_one,	//�¶ȸ�λ
	output	[3:0]	temperature_decimal //�¶�С��
    );
	
	//humidity_int
	B_BCD humidity_int_inst (
		.binary(humidity_int), 
		.hundreds(), 
		.tens(humidity_decade), 
		.ones(humidity_one)
		);
		
	//humidity_float
	B_BCD humidity_float_inst (
		.binary(humidity_float), 
		.hundreds(), 
		.tens(), 
		.ones(humidity_decimal)
		);
		
	//temperature_int
	B_BCD temperature_int_inst (
		.binary(temperature_int), 
		.hundreds(), 
		.tens(temperature_decade), 
		.ones(temperature_one)
		);
		
	//temperature_float
	B_BCD temperature_float_inst (
		.binary(temperature_float), 
		.hundreds(), 
		.tens(), 
		.ones(temperature_decimal)
		);
endmodule
