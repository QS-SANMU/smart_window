`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/18 20:09:51
// Design Name: 
// Module Name: send_en
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


module send_en(clk,rst_n,rx_done,send_en

    );
    input clk;
    input rst_n;
    input rx_done;
    
    output reg send_en;
    
    reg [29:0]cnt;
  
    
    
always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
	       cnt<=30'd0;
        else if(rx_done)
		 cnt<=30'd49_999_999;
		else if(cnt>=30'd1)
		  cnt<=cnt-1;
		 else
		  cnt<=30'd0;
    end
    
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        send_en<=0;
    else if((cnt>=30'd2)&(cnt<=30'd499999))
        send_en<=1;
     else
     send_en<=0;
    
		 
			
endmodule
