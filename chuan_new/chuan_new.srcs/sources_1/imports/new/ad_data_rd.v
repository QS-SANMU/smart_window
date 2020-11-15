`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/05 14:47:45
// Design Name: 
// Module Name: ad_data_rd
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


module ad_data_rd(
	clk,
	rst_n,
	SCL,
	SDA,
	AD_DATA,
	tx_start
	);
	input clk;
	input rst_n;
	output SCL;
	output [7:0] AD_DATA;
	inout SDA;
	output tx_start;
//-----设置SDA-----//
reg SDA_R;
reg SDA_Link;
//-----配置SCL-----//
//时钟信号为50MHz,采样频率为1KHz,则 1/1000=1ms=20ns*50000 
reg [29:0] cnt_delay;
reg SCL_R;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			cnt_delay<=0;
		end
	else if(cnt_delay=='d50000)
		begin
			cnt_delay<=0;
		end
	else
		begin
			cnt_delay<=cnt_delay+1;
		end
end
//SCL_STATE
wire SCL_POS;
wire SCL_HIG;
wire SCL_NEG;
wire SCL_LOW;
assign SCL_POS = (cnt_delay==30'd49999)?1:0;
assign SCL_HIG = (cnt_delay==30'd12499)?1:0;
assign SCL_NEG = (cnt_delay==30'd24999)?1:0;
assign SCL_LOW = (cnt_delay==30'd37499)?1:0;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			SCL_R<=0;
		end
	else if(SCL_POS)
		begin
			SCL_R<=1;
		end
	else if(SCL_NEG)
		begin
			SCL_R<=0;
		end
end
assign SCL = SCL_R;
//PCF8591读写地址与读写指令
parameter PCF_WR = 8'h90;
parameter PCF_RD = 8'h91;
parameter PCF_CT = 8'h03;
//状态机
reg [11:0] state;
parameter 	IDLE 	 = 12'b000000000001;
parameter 	START1 = 12'd000000000010;
parameter 	ADD_WR = 12'd000000000100;
parameter 	ACK1   = 12'd000000001000;
parameter 	CT_WR  = 12'b000000010000;
parameter 	ACK2 	 = 12'b000000100000;
parameter 	START2 = 12'b000001000000;
parameter 	ADD_RD = 12'b000010000000;
parameter 	ACK3	 = 12'b000100000000;
parameter 	DATA 	 = 12'b001000000000;
parameter 	ACK4	 = 12'b010000000000;
parameter 	STOP 	 = 12'b100000000000;
reg [3:0] num;
reg [7:0] db_r;//在IIC上传送的数据寄存器
reg [7:0] read_data;
reg tx_start_r;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			state<=IDLE;
			SDA_R<=1'b1;
			SDA_Link<=1'b0;
			num<=4'd0;
			db_r<=0;
			read_data<=0;
			tx_start_r<=0;
		end
	else
		begin
			case(state)
				IDLE:begin
						SDA_R<=1'b1;
						SDA_Link<=1'b1;
						state<=START1;
						num<=4'd0;
						tx_start_r<=0;
					end
				START1:begin
						if(SCL_HIG)
							begin
								SDA_R<=1'b0;
								SDA_Link<=1'b1;
								state<=ADD_WR;
								db_r<=PCF_WR;
							end
						else
							begin
								state<=START1;
							end
					end
				ADD_WR:begin
						if(SCL_LOW)
							begin
								if(num==4'd8)
									begin
										num<=0;
										SDA_Link<=1'b0;
										SDA_R<=1'b1;
										state<=ACK1;
									end
								else
									begin
										state<=ADD_WR;
										num<=num+1'b1;
										case(num)
											4'd0:begin SDA_R<=db_r[7];end
											4'd1:begin SDA_R<=db_r[6];end
											4'd2:begin SDA_R<=db_r[5];end
											4'd3:begin SDA_R<=db_r[4];end
											4'd4:begin SDA_R<=db_r[3];end
											4'd5:begin SDA_R<=db_r[2];end
											4'd6:begin SDA_R<=db_r[1];end
											4'd7:begin SDA_R<=db_r[0];end
										endcase
									end
							end
						else
							begin
								state<=ADD_WR;
							end
					end
				ACK1:begin
						if(SCL_NEG)
							begin
								state<=CT_WR;
								db_r<=PCF_CT;	
							end
						else
							begin
								state<=ACK1;
							end
					end
				CT_WR:begin
						if(SCL_LOW)
							begin
								if(num==4'd8)
									begin
										num<=0;
										SDA_Link<=1'b0;
										SDA_R<=1'b1;
										state<=ACK2;
									end
								else
									begin
										SDA_Link<=1'b1;
										state<=CT_WR;
										num<=num+1'b1;
										case(num)
											4'd0:begin SDA_R<=db_r[7];end
											4'd1:begin SDA_R<=db_r[6];end
											4'd2:begin SDA_R<=db_r[5];end
											4'd3:begin SDA_R<=db_r[4];end
											4'd4:begin SDA_R<=db_r[3];end
											4'd5:begin SDA_R<=db_r[2];end
											4'd6:begin SDA_R<=db_r[1];end
											4'd7:begin SDA_R<=db_r[0];end
										endcase
									end
							end
						else
							begin
								state<=CT_WR;
							end
					end
				ACK2:begin
						if(SCL_NEG)
							begin
								state<=START2;
								db_r<=PCF_RD;	
							end
						else
							begin
								state<=ACK2;
							end
					end
				START2:begin
						if(SCL_LOW)
							begin
								SDA_R<=1'b1;
								SDA_Link<=1'b1;
								state<=START2;
							end
						else if(SCL_HIG)
							begin
								SDA_R<=1'b0;
								state<=ADD_RD;
							end
						else
							begin
								state<=START2;
							end
					end
				ADD_RD:begin
						if(SCL_LOW)
							begin
								if(num==4'd8)
									begin
										num<=0;
										SDA_Link<=1'b0;
										SDA_R<=1'b1;
										state<=ACK3;
									end
								else
									begin
										state<=ADD_RD;
										num<=num+1'b1;
										case(num)
											4'd0:begin SDA_R<=db_r[7];end
											4'd1:begin SDA_R<=db_r[6];end
											4'd2:begin SDA_R<=db_r[5];end
											4'd3:begin SDA_R<=db_r[4];end
											4'd4:begin SDA_R<=db_r[3];end
											4'd5:begin SDA_R<=db_r[2];end
											4'd6:begin SDA_R<=db_r[1];end
											4'd7:begin SDA_R<=db_r[0];end
										endcase
									end
							end
						else
							begin
								state<=ADD_RD;
							end
					end
				ACK3:begin
						if(SCL_NEG)
							begin
								state<=DATA;
							end
						else
							begin
								state<=ACK3;
							end
					end
				DATA:begin
						if(num<=4'd7)
							begin
								state<=DATA;
								if(SCL_HIG)
									begin	  
										num<=num+1'b1;	
										case(num)
											4'd0: read_data[7] <= SDA;
											4'd1: read_data[6] <= SDA;  
											4'd2: read_data[5] <= SDA; 
											4'd3: read_data[4] <= SDA; 
											4'd4: read_data[3] <= SDA; 
											4'd5: read_data[2] <= SDA; 
											4'd6: read_data[1] <= SDA; 
											4'd7: read_data[0] <= SDA; 
										endcase
									end
							end
						else if((SCL_LOW)&&(num==4'd8))
							begin
								num<=4'd0;			//num计数清零
								state<=ACK4;
							end
						else
							begin
								state <= DATA;
							end
					end
				ACK4: begin
					if(SCL_NEG)begin
						state <= STOP;
						end
					else
						begin
							state <= ACK4;
						end
					end
				STOP:begin
						if(SCL_LOW)
							begin
								SDA_Link<=1'b1;
								SDA_R<=1'b0;
								state<=STOP;
							end
						else if(SCL_HIG)
							begin
								SDA_R<=1'b1;	//scl为高时，sda产生上升沿（结束信号）
								tx_start_r<=1;
								state<=IDLE;
							end
						else 
							begin
								state<=STOP;
							end
					end
				endcase
		end
end
reg tx_start_r_r;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			tx_start_r_r<=0;
		end
	else
		begin
			tx_start_r_r<=tx_start_r;
		end
end
assign tx_start = tx_start_r & ~tx_start_r_r;
assign SDA = SDA_Link?SDA_R:1'bz;
assign AD_DATA = read_data;
endmodule

