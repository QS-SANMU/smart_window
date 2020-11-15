`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/09 18:09:17
// Design Name: 
// Module Name: PWM
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


module pwm(clk,rst_n,pwm_L,pwm_R,window_cmds,window_cmds1,LD3320_cmds,senser_cmds
    );

	input clk;
	input rst_n;
	input [3:0]window_cmds;
	input [3:0]window_cmds1;
	input [3:0]LD3320_cmds;
	input [3:0]senser_cmds;
	output reg pwm_L;
	output reg pwm_R;
	
	reg [23:0]cnt;
	wire pwm1;
	wire pwm2;
	wire pwm3;
	wire pwm4;
	wire pwm5;
	wire pwm6;
	wire pwm7;
	wire pwm8;
	wire pwm9;
	wire pwm10;
	
	
	
	//脉冲信号计数器	
always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			cnt<=24'd0;
	    else
		      begin
                  if(cnt==24'd1900000)
			         cnt<=24'd0;
		          else
			         cnt<=cnt+1;
	           end
	end
	


	
assign pwm1=(cnt>=24'd1&cnt<=24'd50000)?1:0;     //0.5ms,0度
assign pwm2=(cnt>=24'd1&cnt<=24'd60000)?1:0;     //0.6ms,
assign pwm3=(cnt>=24'd1&cnt<=24'd70000)?1:0;     //0.7ms,
assign pwm4=(cnt>=24'd1&cnt<=24'd80000)?1:0;     //0.8ms,
assign pwm5=(cnt>=24'd1&cnt<=24'd90000)?1:0;     //0.9ms,
assign pwm6=(cnt>=24'd1&cnt<=24'd100000)?1:0;     //1.0ms,
assign pwm7=(cnt>=24'd1&cnt<=24'd110000)?1:0;     //1.1ms,
assign pwm8=(cnt>=24'd1&cnt<=24'd120000)?1:0;     //1.2ms,
assign pwm9=(cnt>=24'd1&cnt<=24'd130000)?1:0;     //1.3ms,
assign pwm10=(cnt>=24'd1&cnt<=24'd140000)?1:0;     //1.4ms,

wire [8:0]judge;
wire [8:0]judge1;
assign judge[1] = (window_cmds==4'd0 | LD3320_cmds==4'd3 | senser_cmds==4'd1 | senser_cmds==4'd2);
assign judge[0] = (window_cmds==4'd8 | LD3320_cmds==4'd2);

assign judge[2] = (window_cmds==4'd1);
assign judge[3] = (window_cmds==4'd2);
assign judge[4] = (window_cmds==4'd3);
assign judge[5] = (window_cmds==4'd4);
assign judge[6] = (window_cmds==4'd5);
assign judge[7] = (window_cmds==4'd6);
assign judge[8] = (window_cmds==4'd7);




assign judge1[1] = (window_cmds1 ==4'd0 | LD3320_cmds==4'd3| senser_cmds==4'd1 | senser_cmds==4'd2);
assign judge1[0] = (window_cmds1 ==4'd8 | LD3320_cmds==4'd2);   

assign judge1[2] = (window_cmds1==4'd1);
assign judge1[3] = (window_cmds1==4'd2);
assign judge1[4] = (window_cmds1==4'd3);
assign judge1[5] = (window_cmds1==4'd4);
assign judge1[6] = (window_cmds1==4'd5);
assign judge1[7] = (window_cmds1==4'd6);
assign judge1[8] = (window_cmds1==4'd7);


reg [8 : 0]state;
always@(posedge clk or negedge rst_n)
begin
 if(!rst_n)
    begin
     pwm_L<=pwm1;
     state <= 'd0;
	// pwm_R<=pwm1;
	 end
 else 
    case(judge)
    9'b000000010:   begin
                pwm_L<=pwm1;
                state <= 'd1;
	            //pwm_R<=pwm1;
	         end                       //关窗
    9'b000000001:   begin
                pwm_L<=pwm10;
                state <= 'd2;
	            //pwm_R<=pwm10;
	         end                         //开窗
	 9'b000000100:   begin
                pwm_L<=pwm2;
                state <= 'd3;
	            //pwm_R<=pwm10;
	         end                         //开窗
	 9'b000001000:   begin
                pwm_L<=pwm3;
                state <= 'd4;
	            //pwm_R<=pwm10;
	         end                         //开窗
	 9'b000010000:   begin
                pwm_L<=pwm4;
                state <= 'd5;
	            //pwm_R<=pwm10;
	         end                         //开窗
	 9'b000100000:   begin
                pwm_L<=pwm5;
                state <= 'd6;
	            //pwm_R<=pwm10;
	         end                         //开窗
	 9'b001000000:   begin
                pwm_L<=pwm6;
                state <= 'd7;
	            //pwm_R<=pwm10;
	         end                         //开窗
	 9'b010000000:   begin
                pwm_L<=pwm7;
                state <= 'd8;
	            //pwm_R<=pwm10;
	         end                         //开窗
	 9'b100000000:   begin
                pwm_L<=pwm8;
                state <= 'd9;
	            //pwm_R<=pwm10;
	         end                         //开窗
	
    //4'd2:   begin
                //pwm_L<=pwm10;
	            //pwm_R<=pwm1;
	         //end                              //开左窗
    //4'd3:   begin
                //pwm_L<=pwm1;
	            //pwm_R<=pwm10;
	         //end                              //开右幢
  //  default: pwm_L <= pwm1;
    default: begin
        case(state)//pwm_L <=pwm10;
        'd1 : pwm_L <= pwm1;
        'd2 : pwm_L <= pwm10;
        'd3 : pwm_L <= pwm2;
        'd4 : pwm_L <= pwm3;
        'd5 : pwm_L <= pwm4;
        'd6 : pwm_L <= pwm5;
        'd7 : pwm_L <= pwm6;
        'd8 : pwm_L <= pwm7;
        'd9 : pwm_L <= pwm8;
        endcase
    end
  endcase
   end
    
    reg [9:0]state1;
	always@(posedge clk or negedge rst_n)
   begin
    if(!rst_n)
       begin
        pwm_R<=pwm_R;
        state1 <= 'd0;
        end
    else 
       case(judge1)
       9'b000000010:   begin
                   pwm_R<=pwm10;
                   state1 <= 'd1;
                   //pwm_R<=pwm1;
                end                       //关窗
       9'b000000001:   begin
                   pwm_R<=pwm1;
                   state1 <= 'd2;
                   //pwm_R<=pwm10;
                end 
       9'b000000100:   begin
                   pwm_R<=pwm8;
                   state1 <= 'd3;
                   //pwm_R<=pwm10;
                end 
                                        //开窗
     9'b000001000:   begin
                   pwm_R<=pwm7;
                   state1 <= 'd4;
                   //pwm_R<=pwm10;
                end 
        9'b000010000:   begin
                   pwm_R<=pwm6;
                   state1 <= 'd5;
                   //pwm_R<=pwm10;
                end 
        9'b000100000:   begin
                   pwm_R<=pwm5;
                   //pwm_R<=pwm10;
                   state1 <= 'd6;
                end 
        9'b001000000:   begin
                   pwm_R<=pwm4;
                   //pwm_R<=pwm10;
                   state1 <= 'd7;
                end 
        9'b010000000:   begin
                   pwm_R<=pwm3;
                   state1 <= 'd8;
                   //pwm_R<=pwm10;
                end 
        9'b100000000:   begin
                   pwm_R<=pwm2;
                   state1 <= 'd9;
                   //pwm_R<=pwm10;
                end 
     
       //4'd2:   begin
               //    pwm_R<=pwm1;
                   //pwm_R<=pwm1;
                //end                              //开左窗
       //4'd3:   begin
         //          pwm_R<=pwm10;
                   //pwm_R<=pwm10;
           //     end                              //开右幢
   //    default:pwm_R<=pwm_L;
        default:
        begin//pwm_R<=pwm10;
        case(state1)//pwm_L <=pwm10;
                'd1 : pwm_R <= pwm10;
                'd2 : pwm_R <= pwm1;
                'd3 : pwm_R <= pwm8;
                'd4 : pwm_R <= pwm7;
                'd5 : pwm_R <= pwm6;
                'd6 : pwm_R <= pwm5;
                'd7 : pwm_R <= pwm4;
                'd8 : pwm_R <= pwm3;
                'd9 : pwm_R <= pwm2;
       endcase
      end
endcase
end


endmodule
