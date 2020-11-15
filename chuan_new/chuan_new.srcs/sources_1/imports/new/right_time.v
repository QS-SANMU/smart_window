`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/05 14:40:26
// Design Name: 
// Module Name: right_time
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


module right_time(
 clk,
	rst_n,
	sda,
	scl,
    right_time
    );
	input clk;
	input rst_n;
	
	output [15:0]right_time;
	
	 reg [3:0]out_hout_lo;
	 reg [3:0]out_hout_hi;
	 reg [3:0]out_sec_lo;
	 reg [3:0]out_sec_hi;
	 reg [3:0]out_min_lo;
	 reg [3:0]out_min_hi;
	output scl;
	inout sda;	
    reg [12:0]addr;
	wire [7:0]o_data;
    wire done;
	wire sda_out;
	wire sda_in;
	wire con_sda;
	
	wire clk1;
	
	reg wr_en,re_en;
	reg [7:0]wr_data;
	parameter WRITE_SEC='d18,WRITE_MIN='d19,WRITE_HOUR='d20,READ_HOUR='d21,READ_MIN='d22,READ_SEC='d23,IDLE='d24;

	

	assign sda=con_sda?sda_out:1'bz;
	assign sda_in=con_sda?1'b1:sda;
	assign right_time={out_hout_hi,out_hout_lo,out_min_hi,out_min_lo};

	reg [5:0]STATE;

	
	reg done_r,done_rr;
	always@(posedge clk or negedge rst_n)
	begin
	    if(rst_n==0)
		begin
		    done_r<=0;
			done_rr<=0;
		end
		else
		begin
		    done_r<=done;
			done_rr<=done_r;
		end
	end
	
	always@(posedge clk or negedge rst_n)
	begin
	    if(rst_n==0)
		begin
    		STATE<=WRITE_SEC;
			wr_en<=1;
			addr<='h01;
			re_en<=0;
			addr<=0;
			wr_data<=0;
		end
		else
		begin
		    case(STATE)
			WRITE_SEC:begin
			STATE<=WRITE_MIN;
			addr<='h00;
			wr_en<=1;
			wr_data<={1'b0,3'b0,4'b0};
			end
			WRITE_MIN:begin
			wr_en<=0;
			    if(done_rr)
			    begin
				wr_en<=1;
				addr<='h01;
				wr_data<={4'd2,4'd5};
				STATE<=WRITE_HOUR;
				end
			end
			WRITE_HOUR:begin
			wr_en<=0;
			    if(done_rr)
			    begin
				wr_en<=1;
				addr<='h02;
				wr_data<={4'd0,4'd1};
				STATE<=IDLE;
				end
			end
			IDLE:begin
			wr_en<=0;
			    if(done_rr)
			    begin
				re_en<=1;
				addr<='h02;
				STATE<=READ_HOUR;
				end
			end
			READ_HOUR:begin
			re_en<=0;
			    if(done_rr)
			    begin
				re_en<=1;
				addr<='h01;
				out_hout_hi<=o_data[7:4];
				out_hout_lo<=o_data[3:0];
				STATE<=READ_MIN;
				end
			end
			READ_MIN:begin
			re_en<=0;
			    if(done_rr)
			    begin
				re_en<=1;
				addr<='h00;
				out_min_hi<=o_data[7:4];
				out_min_lo<=o_data[3:0];
				STATE<=READ_SEC;
				end
			end
			READ_SEC:begin
			re_en<=0;
			    if(done_rr)
			    begin
				re_en<=1;
				addr<='h02;
				out_sec_hi<=o_data[7:4];
				out_sec_lo<=o_data[3:0];
				STATE<=READ_HOUR;
				end
			end
			default:STATE<=READ_HOUR;
			endcase
		end
	end
			
			
				


	
	IIC_CON u0(
	.clk(clk),
	.rst_n(rst_n),
	.scl(scl),
	.addr_se_reg(addr),
	.addr_se_me(7'b1101000),
	.wr_en(wr_en),
	.re_en(re_en),
	.num_reg_add('b1),
	.num_sent_data('b1),
	.num_rece_data('b1),
	.sda_data_out(wr_data),
	.data_out(o_data),
	.sda_o(sda_out),
	.sda_i(sda_in),
	.con_sda(con_sda),
	.done(done)
    );


endmodule
