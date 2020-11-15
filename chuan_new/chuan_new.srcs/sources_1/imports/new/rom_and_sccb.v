`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/14 19:44:13
// Design Name: 
// Module Name: rom_and_sccb
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/14 19:44:13
// Design Name: 
// Module Name: rom_and_sccb
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


module rom_and_sccb(
input clk,
input rst_mix,
//input [7:0]com_add,
//output reg [5:0]rom_add,
input dvp_reset,
inout sda,
output reg done,
output reg scl
    );
	wire [7:0]com_add;
	reg [10:0]led_count;
	reg [9:0]rom_add;
	//reg [8:0]rom_add_1;
	reg [9:0]rom_add_d;
	reg [11:0]count; //400khz;
	reg control_sda;
	reg sda_data;
	reg ack;
	reg scl_end;
	reg read;
	assign sda=(control_sda==1'b1)?sda_data:'dz;
	always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix==1'b0)
		rom_add_d<='d0;
		//else if(read==1'b1)
		//rom_add_d<=rom_add_1;
		else
		rom_add_d<=rom_add;
	end
	always@(posedge clk or negedge rst_mix)  //create scl;
	begin
		if(rst_mix==1'b0)
		begin
		count<='d0;
		scl<=1'b1;
		end
		else if(dvp_reset==1'b0)
		begin
		scl<=1'b1;
		count<='d0;
		end
		else if(scl_end==1'b1)
		begin
			scl<=1'b1;
			count<='d0;
		end
		else
		begin
			if(count=='d124)
			begin
				scl<=~scl;
				count<='d0;
			end
			else
			begin
				scl<=scl;
				count<=count+'d1;
			end
		end
	end
	
	wire rsta;
	reg rsta_1;
	assign rsta = rsta_1;
	
	reg iic_high;//scl高电平center
	reg iic_low;//...低电平...
	always@(*)//MUX  产生脉冲信号
	begin
		if(count=='d67&&scl==1'b1)
		begin
			iic_high<=1'b1;
			iic_low<=1'b0;
		end
		else if(count=='d67&&scl==1'b0)//20
		begin
			iic_high<=1'b0;
			iic_low<=1'b1;
		end
		else 
		begin
			iic_high<=1'b0;
			iic_low<=1'b0;
		end
	end
	reg flag;
	reg [15:0]count_1ms;
	always@(posedge clk or negedge rst_mix)  //计数1ms,系统复位时间
	begin
		if(rst_mix==1'b0)
		begin
		count_1ms<=1'b0;
		end
		else if(flag==1'b1)
		begin
			if(count_1ms=='d49999)
			begin
			count_1ms<=count_1ms;
			end
			else
			begin
			count_1ms<=count_1ms+'d1;
			end
		end
		else
		count_1ms<=count_1ms;
	end
	
	reg [7:0]com_add_data;	
	reg [5:0]state;//状态机控制iic,以及控制ROM数据的输出
	reg flag_rom;
	reg flag_rom_1;
	reg [3:0]sent_count;
	reg [7:0]rece_data;
	reg [3:0]rece_count;
	always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix==1'b0)
		begin
			done<=1'b0;
			//led<='d0;
			read<=1'b0;
			state<='d0;
			sda_data<=1'b1;
			flag_rom<=1'b0;
			flag_rom_1<=1'b0;
			control_sda<=1'b1;
			sent_count<='d0;
			scl_end<=1'b1;
			ack<=1'b1;
			rece_count<='d0;
			rece_data<='d0;
			flag<=1'b0;
			rsta_1<=1'b0;
		end
		else if(dvp_reset==1'b0)
		begin
			done<=1'b0;
			read<=1'b0;
			state<='d0;
			sda_data<=1'b1;
			flag_rom<=1'b0;
			control_sda<=1'b1;
			sent_count<='d0;
			scl_end<=1'b1;
			rece_count<='d0;
			rece_data<='d0;
			flag<=1'b0;
			rsta_1<=1'b0;
		end
		else
		begin
			rsta_1<=1'b1;
			case(state)
			'd0:
			begin
				read<=1'b0;
				if(iic_high==1'b1)
				begin
					sda_data<=1'b0;//起始位
					state<='d1;
					flag_rom<=1'b0;     //宽度20ns
					com_add_data<=8'h78;
				end
				else
				begin
					sda_data<=1'b1;
					state<='d0;
					flag_rom<=1'b0;
					scl_end<=1'b0;
				end
			end
			
			'd1:
			begin
				if(iic_low==1'b1)
				begin
					com_add_data<={com_add_data[6:0],1'b0};
					sda_data<=com_add_data[7];
					sent_count<=sent_count+'d1;
				end
				else if(iic_high==1'b1)
				begin
					if(sent_count=='d8)
					begin
						state<='d2;
						sent_count<='d0;
					end
				end
			end
			
			'd2:
			begin
				if(iic_high==1'b1)
				begin
					ack<=sda;
					state<='d3;
					flag_rom<=1'b1;
					//control_sda<=1'b1;
				end
				else if(iic_low==1'b1)
				begin
					control_sda<=1'b0;
					ack<=1'b1;
				end
				else
				begin
					flag_rom<=1'b0;
					ack<=1'b1;
				end
			end
			
			'd3:
			begin
				ack<=1'b1;
				com_add_data<=com_add;
				flag_rom<=1'b0;
				state<='d4;
			end
			
			'd4:
			begin
				flag_rom<=1'b0;
				if(iic_low==1'b1)
				begin
					control_sda<=1'b1;
					state<='d4;
					sent_count<=sent_count+'d1;
					sda_data<=com_add_data[7];
					com_add_data<={com_add_data[6:0],1'b0};
				end
				else if(iic_high==1'b1)
				begin
					if(sent_count=='d8)
					begin
						state<='d5;
						sent_count<='d0;
						//control_sda<=1'b0;
					end
				end
			end
			
			'd5:  //应答
			begin
				if(iic_high==1'b1)
				begin
					flag_rom<=1'b1;
					ack<=sda;
					//control_sda<=1'b1;
					state<='d6;
				end
				else if(iic_low==1'b1)
				begin
					ack<=1'b1;
					control_sda<=1'b0;
				end
				else
				begin
					flag_rom<=1'b0;
					ack<=1'b1;
				end
			end
			
			'd6:
			begin
				ack<=1'b1;
				com_add_data<=com_add;
				flag_rom<=1'b0;
				state<='d7;
			end
			
			'd7:
			begin
				flag_rom<=1'b0;
				if(iic_low==1'b1)
				begin
					control_sda<=1'b1;
					state<='d7;
					sent_count<=sent_count+'d1;
					sda_data<=com_add_data[7];
					com_add_data<={com_add_data[6:0],1'b0};
				end
				else if(iic_high==1'b1)
				begin
					if(sent_count=='d8)
					begin
						state<='d8;
						sent_count<='d0;
						//control_sda<=1'b0;//之前的错误在这。scl还是高位时control_sda拉低了,即改变了sda的值.
					end
				end
			end
			
			'd8:  //应答
			begin
				if(iic_high==1'b1)
				begin
					flag_rom<=1'b1;
					ack<=sda;
					//control_sda<=1'b1;
					state<='d9;
				end
				else if(iic_low==1'b1)
				begin
					ack<=1'b1;
					control_sda<=1'b0;
				end
				else
				begin
					flag_rom<=1'b0;
					ack<=1'b1;
				end
			end
			
			'd9:
			begin
				ack<=1'b1;
				com_add_data<=com_add;
				flag_rom<=1'b0;
				state<='d10;
			end
			
			'd10:
			begin
				flag_rom<=1'b0;
				if(iic_low==1'b1)
				begin
					control_sda<=1'b1;
					state<='d10;
					sent_count<=sent_count+'d1;
					sda_data<=com_add_data[7];
					com_add_data<={com_add_data[6:0],1'b0};
				end
				else if(iic_high==1'b1)
				begin
					if(sent_count=='d8)
					begin
						state<='d11;
						sent_count<='d0;
						//control_sda<=1'b0;//之前的错误在这。scl还是高位时control_sda拉低了,即改变了sda的值.
					end
				end
			end
			
			'd11:
			begin
				if(iic_high==1'b1)
				begin
					ack<=sda;
					state<='d12;
					//control_sda<=1'b1;
					//sda_data<=1'b0;
				end
				else if(iic_low==1'b1)
				begin
					control_sda<=1'b0;
					ack<=1'b1;
				end
			end
			
			'd12:
			begin
				ack<=1'b1;
				if(iic_high==1'b1)
				begin
					sda_data<=1'b1;
					scl_end<=1'b1;
					if(rom_add=='d951)//951
					begin
					state<='d12;
					done<=1'b1;
					rsta_1<=1'b0;
					end
					/*else if(rom_add=='d6)
					begin
						if(delay_count=='d250000)
						begin
							delay_begin<=1'b0;
							state<='d0;
						end
						else
						begin
							delay_begin<=1'b1;
							state<='d12;
						end
					end*/
					else
					begin
					state<='d0;
					//read<=1'b0;
					end
				end
				else if(iic_low==1'b1)
				begin
					sda_data<=1'b0;
					control_sda<=1'b1;
				end
			end
			
			default:
			begin
				state<='d10;
				flag_rom<=1'b0;
				control_sda<=1'b1;
			end
			
			endcase
		end
	end
	
	always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix==1'b0)
		rom_add<=10'b0;
		else if(dvp_reset==1'b0)
		rom_add<=10'd0;
		else if(flag_rom==1'b1)
		begin
			if(rom_add==10'd951)//951
			rom_add<=rom_add;
			else
			rom_add<=rom_add+10'd1;
		end
		else
		begin
		rom_add<=rom_add;
		end
	end
	
	always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix==1'b0)
			led_count<='d0;
		else if(ack==1'b0)
			led_count<=led_count+'d1;
		else
			led_count<=led_count;
	end
	
	blk_mem_gen_1 r1(
	//.ena(rsta),
	.clka(clk),
	.addra(rom_add_d),
	.douta(com_add)
	);
	
endmodule
