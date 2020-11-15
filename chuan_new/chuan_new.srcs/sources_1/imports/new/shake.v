`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/14 19:41:15
// Design Name: 
// Module Name: shake
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


module shake(
input clk,
input an,
output reg an_new
    );//用状态机
	reg an_1;
	reg an_2;
	wire pan_down;  //判断下降沿
	wire pan_up;//判断上升沿
	reg [18:0]count;
	always@(posedge clk)
	begin
		an_1<=an;
		an_2<=an_1;
	end
	
	assign pan_down=(~an_1)&an_2;
	assign pan_up=an_1&(~an_2);
	
	always@(posedge clk)  //计数器  500000
	begin
		if(pan_down==1'b0&&pan_up==1'b0)
		begin
			if(count=='d500000-'d1)
			count<=count;
			else
			count<=count+19'd1;
		end
		else
		count<='d0;
	end
	
	reg [3:0]state;
	reg [3:0]state_1;
	always@(posedge clk)
	begin
		state<=state_1;
	end
	
	always@(*)
	begin
		//state_1=4'b0000;
		case(state)
		'd0:
		begin
			//an_new<=1'b0;        //
			if(pan_down==1'b1)
			state_1='d1;
			else
			state_1='d0;
		end
		
		'd1:
		begin
			if(count=='d500000-'d1)//500000
			begin
			//an_new<=1'b0;   //
			state_1='d2;
			end
			else
			begin
			//an_new<=an_new;//
			state_1='d1;
			end
		end
		
		'd2:
		begin
			//an_new<=1'b0;//
			
			if(pan_up==1'b1)
			state_1='d3;
			else
			state_1='d2;
		end
		
		'd3:
		begin
			if(count=='d500000-'d1)
			begin
			//an_new<=1'b1;//
			state_1='d4;
			end
			else
			begin
			//an_new<=an_new;//
			state_1='d3;
			end
		end
		
		'd4:
		begin
			//an_new<=1'b1;//
			if(pan_down==1'b1)
			state_1='d5;
			else
			state_1='d4;
		end
		
		'd5:
		begin
			if(count=='d500000-'d1)
			begin
			//an_new<=1'b1;//
			state_1='d6;
			end
			else
			begin
			state_1='d5;
			end
		end
		
		'd6:
		begin
			//an_new<=1'b1;//
			if(pan_up==1'b1)
			state_1='d7;
			else
			state_1='d6;
		end
		
		'd7:
		begin
			if(count=='d500000-'d1)
			begin
			//an_new<=1'b0;//
			state_1='d0;
			end
			else
			begin
			state_1='d7;
			end
		end
		
		
		default:
		begin
			//an_new<=1'd0;
			state_1=4'b0000;
		end
		
		endcase
	end
	
	always@(posedge clk)
	begin
		case(state)
		'd0:
		begin
			an_new<=1'b0;        
		end
		
		'd1:
		begin
			if(count=='d500000-'d1)
			begin
			an_new<=1'b0;
			end
			else
			begin
			an_new<=an_new;
			end
		end
		
		'd2:
		begin
			an_new<=1'b0;//
		end
		
		'd3:
		begin
			if(count=='d500000-'d1)
			begin
			an_new<=1'b1;
			end
			else
			begin
			an_new<=an_new;
			end
		end
		
		'd4:
		begin
			an_new<=1'b1;
		end
		
		'd5:
		begin
			if(count=='d500000-'d1)
			begin
			an_new<=1'b1;
			end
		end
		
		'd6:
		begin
			an_new<=1'b1;
		end
		
		'd7:
		begin
			if(count=='d500000-'d1)
			begin
			an_new<=1'b0;
			end
		end
		
		
		default:
		begin
			an_new<=1'd0;
		end
		
		endcase
	end


endmodule
