`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/05 14:47:05
// Design Name: 
// Module Name: data_judge
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


module data_judge(
    clk,
    rst_n,
    data_in,
    window_down,
    wind_speed
    );
    input clk;
    input rst_n;
    input [7:0]data_in;
     
    reg [31:0]cnt_sec;
    reg [5:0]cnt_min;
    reg [33:0]cnt_init;
    
     parameter speed_zero=5'b00000;
     parameter speed_one=5'b00001;
     parameter speed_two=5'b00010;
     parameter speed_three=5'b00100;
     parameter speed_four=5'b01000;
     parameter speed_five=5'b10000;
    
        reg [4:0]c_state;
       
     output reg window_down;
    output reg [4:0]wind_speed;
    
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt_sec<=32'd0;
    else if(cnt_sec==32'd49_999_999)
        cnt_sec<=32'd0;
    else 
        cnt_sec<=cnt_sec+1;
end


always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt_init<=34'd0;
    else if(cnt_init==34'd249_999_999)
        cnt_init<=34'd249_999_999;
    else 
        cnt_init<=cnt_init+1;
end


 always@(posedge clk or negedge rst_n)
 begin
    if(!rst_n)
        c_state<=speed_zero;
    else 
        case(c_state)
            speed_zero:begin
                                 if(data_in>=8'd5 & data_in<=8'd15)
                                     begin
                                        c_state<=speed_one;
                                        cnt_min<=6'd0;
                                     end
                              
                                 else  if(data_in>=8'd16 & data_in<=8'd20)
                                    begin
                                     c_state<=speed_two;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd21 & data_in<=8'd30)
                                    begin
                                     c_state<=speed_three;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd31 & data_in<=8'd50)
                                    begin
                                     c_state<=speed_four;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd50)
                                    begin
                                     c_state<=speed_five;
                                     cnt_min<=6'd0;
                                    end
                                  else
                                    begin
                                     c_state<=speed_zero;
                                     cnt_min<=6'd0;
                                    end
                                end   
                      
            speed_one:begin
                           if(cnt_min<=6'd3)
                               begin
                                 if(cnt_sec==32'd49_999_999)
                                        cnt_min<=cnt_min+1;
                                  else
                                        cnt_min<=cnt_min;
                              end
                           else 
                          begin
                                 if(data_in>=8'd5 & data_in<=8'd15)
                                     begin
                                        c_state<=speed_one;
                                        cnt_min<=6'd0;
                                     end
                              
                                 else  if(data_in>=8'd16 & data_in<=8'd20)
                                    begin
                                     c_state<=speed_two;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd21 & data_in<=8'd30)
                                    begin
                                     c_state<=speed_three;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd31 & data_in<=8'd50)
                                    begin
                                     c_state<=speed_four;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd50)
                                    begin
                                     c_state<=speed_five;
                                     cnt_min<=6'd0;
                                    end
                                  else
                                    begin
                                     c_state<=speed_zero;
                                     cnt_min<=6'd0;
                                    end
                                end 
                             end    
                      
                      speed_two:begin
                           if(cnt_min<=6'd3)
                               begin
                                 if(cnt_sec==32'd49_999_999)
                                        cnt_min<=cnt_min+1;
                                  else
                                        cnt_min<=cnt_min;
                              end
                           else 
                          begin
                                 if(data_in>=8'd5 & data_in<=8'd15)
                                     begin
                                        c_state<=speed_one;
                                        cnt_min<=6'd0;
                                     end
                              
                                 else  if(data_in>=8'd16 & data_in<=8'd20)
                                    begin
                                     c_state<=speed_two;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd21 & data_in<=8'd30)
                                    begin
                                     c_state<=speed_three;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd31 & data_in<=8'd50)
                                    begin
                                     c_state<=speed_four;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd50)
                                    begin
                                     c_state<=speed_five;
                                     cnt_min<=6'd0;
                                    end
                                  else
                                    begin
                                     c_state<=speed_zero;
                                     cnt_min<=6'd0;
                                    end
                                end 
                             end    
                      
                      
                       speed_three:begin
                           if(cnt_min<=6'd3)
                               begin
                                 if(cnt_sec==32'd49_999_999)
                                        cnt_min<=cnt_min+1;
                                  else
                                        cnt_min<=cnt_min;
                              end
                           else 
                          begin
                                 if(data_in>=8'd5 & data_in<=8'd15)
                                     begin
                                        c_state<=speed_one;
                                        cnt_min<=6'd0;
                                     end
                              
                                 else  if(data_in>=8'd16 & data_in<=8'd20)
                                    begin
                                     c_state<=speed_two;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd21 & data_in<=8'd30)
                                    begin
                                     c_state<=speed_three;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd31 & data_in<=8'd50)
                                    begin
                                     c_state<=speed_four;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd50)
                                    begin
                                     c_state<=speed_five;
                                     cnt_min<=6'd0;
                                    end
                                  else
                                    begin
                                     c_state<=speed_zero;
                                     cnt_min<=6'd0;
                                    end
                                end 
                             end    
                      
                           speed_four:begin
                           if(cnt_min<=6'd3)
                               begin
                                 if(cnt_sec==32'd49_999_999)
                                        cnt_min<=cnt_min+1;
                                  else
                                        cnt_min<=cnt_min;
                              end
                           else 
                          
                                begin
                                 if(data_in>=8'd5 & data_in<=8'd15)
                                     begin
                                        c_state<=speed_one;
                                        cnt_min<=6'd0;
                                     end
                              
                                 else  if(data_in>=8'd16 & data_in<=8'd20)
                                    begin
                                     c_state<=speed_two;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd21 & data_in<=8'd30)
                                    begin
                                     c_state<=speed_three;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd31 & data_in<=8'd50)
                                    begin
                                     c_state<=speed_four;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd50)
                                    begin
                                     c_state<=speed_five;
                                     cnt_min<=6'd0;
                                    end
                                  else
                                    begin
                                     c_state<=speed_zero;
                                     cnt_min<=6'd0;
                                    end
                                end 
                             end    
          
                           speed_five:begin
                           if(cnt_min<=6'd3)
                               begin
                                 if(cnt_sec==32'd49_999_999)
                                        cnt_min<=cnt_min+1;
                                  else
                                        cnt_min<=cnt_min;
                              end
                           else 
                           begin
                                 if(data_in>=8'd5 & data_in<=8'd15)
                                     begin
                                        c_state<=speed_one;
                                        cnt_min<=6'd0;
                                     end
                              
                                 else  if(data_in>=8'd16 & data_in<=8'd20)
                                    begin
                                     c_state<=speed_two;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd21 & data_in<=8'd30)
                                    begin
                                     c_state<=speed_three;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd31 & data_in<=8'd50)
                                    begin
                                     c_state<=speed_four;
                                     cnt_min<=6'd0;
                                    end
                                  else  if(data_in>=8'd50)
                                    begin
                                     c_state<=speed_five;
                                     cnt_min<=6'd0;
                                    end
                                  else
                                    begin
                                     c_state<=speed_zero;
                                     cnt_min<=6'd0;
                                    end
                                end 
                           end 
    
                      default:c_state<=speed_zero;
                     endcase
      end
                                         
 always@(posedge clk or negedge rst_n)
 if(!rst_n)
          begin
             window_down<=0;
             wind_speed<=5'b00000;
          end
  else if(cnt_init<34'd249_999_999)
              begin
             window_down<=0;
             wind_speed<=5'b00000;
          end
 else
    begin
    case(c_state)
        speed_zero:begin
                        window_down<=0;
                        wind_speed<=5'b00000;
                   end
        speed_one:begin
                        window_down<=0;
                        wind_speed<=5'b00001;
                   end
                   
         speed_two:begin
                        window_down<=1;////////////////////////////////
                        wind_speed<=5'b00011;
                   end
                                                   
                                                   
         speed_three:begin
                        window_down<=1;////////////////////////////
                        wind_speed<=5'b00111;
                   end
                                                   
         speed_four:begin
                        window_down<=1;///////////////////////////////////////
                        wind_speed<=5'b01111;
                   end
                                                   
         speed_five:begin
                        window_down<=1;/////////////////////////////////////////
                        wind_speed<=5'b11111;
                   end
        default:  begin
                        window_down<=0;
                        wind_speed<=5'b00000;
                   end                                         
          endcase
   end
                    
          
                     
         
endmodule

