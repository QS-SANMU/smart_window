`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/06 16:26:33
// Design Name: 
// Module Name: GPRS_rx
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


module GPRS_rx(
  clk,
	 rst_n,
	 rx_data,
	 po_data,
	 rx_down
    );
      input clk;
	  input rst_n;
	  input rx_data; //传输数据
	  output reg [7:0]po_data;
	  output reg rx_down;
reg temp1,temp2;
wire nege;
wire pose;
reg rx_en;  //开始接收的使能信号
reg clk_rx; //波特率时钟
reg [3:0]bit_cnt; //波特率计数
reg [12:0] cnt;   
reg [12:0] count;   
reg en_count;   
reg [2:0]state;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	 begin
	     temp1 <= 0;
		  temp2 <= 0;
	 end
	 else
	 begin
	     temp1 <= rx_data;
		  temp2 <= temp1;
	 end
end
assign nege = (~temp1) & temp2;
assign pose =  temp1 &(~temp2);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	 begin
	     rx_en <= 0;
		  en_count <= 0;
		  state <= 0;
	 end
	 else 
	     case(state)
		  0:begin 
             if(nege)
				 begin
				     state <= 1;
					  rx_en <= 1;
					  en_count <= 1;
				 end
				 else
				 begin
				     en_count <= 0;
					  state <= 0;
					  rx_en <= 0;
         	 end	
          end 				 
		  1:begin
		       if(count == 5000)
				 begin
				     state <= 2;
					  en_count <= 0;
				 end
				 else if(pose)
				 begin
                 rx_en <= 0;
                 state <= 0;
             end					  
		    end
		   2:begin
			      if(bit_cnt == 10 )
					begin
					    rx_en <= 0;
						 state <= 0;
					end
					else
					rx_en <= rx_en;
			  end
			  endcase
end


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	 begin
	     count <= 0;
	 end
	 else if(en_count)
	     if(count == 5000)
		  count <= 0;
		  else 
		  count <= count + 1'b1;
	 else count <= 0;	   
end


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	     cnt <= 0;
	 else if (rx_en)
	     if(cnt == 5207)
	         cnt <= 0;
	     else
	         cnt <= cnt + 1'b1;
	 else 
	     cnt <= 0;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	 begin
	     clk_rx <= 0;
	 end
	 else if(cnt == 2603)
	     clk_rx <= 1;
	 else 
	     clk_rx <= 0;
end


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	 begin
	     bit_cnt <= 0;
		  rx_down <= 0;
		  end
	 else if(bit_cnt == 10)
	 begin
	     bit_cnt <= 0;
		  rx_down <= 1;
		  end
	 else if(clk_rx)
	 begin
	     bit_cnt <= bit_cnt + 1'b1;
		  rx_down <= 0;
		  end
	 else 
	 begin
	     bit_cnt <= bit_cnt;
		  rx_down <= 0;
		  end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
	 po_data <= 0;
	 else if(clk_rx)
	 case(bit_cnt)
	 'd0: ;
	 'd1: po_data[0] <= rx_data;
	 'd2: po_data[1] <= rx_data;
	 'd3: po_data[2] <= rx_data;
	 'd4: po_data[3] <= rx_data;
	 'd5: po_data[4] <= rx_data;
	 'd6: po_data[5] <= rx_data;
	 'd7: po_data[6] <= rx_data;
	 'd8: po_data[7] <= rx_data;
	 'd9: po_data <= po_data;
	 default:;
	 endcase
end

endmodule

