`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/07 00:32:33
// Design Name: 
// Module Name: top_DTH11
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


module top_DHT11(
 input clk_25M,
 input clk_50M,
    input rst_n,
    inout data,
    output [3:0]  temperature_decade,
    output [3:0]  humidity_decade,
    output [3:0]  humidity_one,
    output [3:0]  temperature_one,
    output [7:0]humidity_int,
    output [7:0]temperature_int
    );
    
    wire humidity_float;
    wire temperature_float;
    Hex_BCD U_Hex_BCD (
		.humidity_int(humidity_int), 
		.humidity_float(humidity_float), 
		.temperature_int(temperature_int), 
		.temperature_float(temperature_float), 
		.humidity_decade(humidity_decade), 
		.humidity_one(humidity_one), 
		.humidity_decimal(), 
		.temperature_decade(temperature_decade),    //humidity_decade,	//10   RH
		.temperature_one(temperature_one),          //humidity_one,		//1
		.temperature_decimal()                      //humidity_decimal,	//0.1
		);                                          //temperature_decade,	//10 oc
		                                            //temperature_one,	//1
	DHT11_mod U_DHT11_mod (                         //temperature_decimal //0.1
		.clk(clk_25M), 
		.rst_n(rst_n), 
		.data(data), 
		.data_rdy(), 
		.humidity_int(humidity_int), 
		.humidity_float(humidity_float), 
		.temperature_int(temperature_int), 
		.temperature_float(temperature_float)
		);
		
		 
endmodule
