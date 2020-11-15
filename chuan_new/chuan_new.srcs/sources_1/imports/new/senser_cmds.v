`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/07 19:49:50
// Design Name: 
// Module Name: senser_cmds
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


module senser_cmds(
    clk,
    rst_n,
    fire,
    CO,
    CH4,
    rain,
    wind,
    finger,
    fall,
    senser_cmds,
    send_en_2

    );
    input clk;
    input rst_n;
    input fire;
    input CO;
    input CH4;
    input rain;
    input wind;
    input [2:0]finger;
    input fall;
    output reg [3:0]senser_cmds;
    output reg  send_en_2;
    
    wire [7:0] judge;
    assign judge[7] = wind;
    assign judge[6] = rain;
    assign judge[5] = CH4;
    assign judge[4] = CO;
    assign judge[3] = fire;
    assign judge[2] = fall;
    assign judge[1:0] = finger;
 
    reg  wind_ed0;
    reg wind_ed1;
    
    reg rain_ed0;
    reg rain_ed1;
    
    reg CH4_ed0;
    reg CH4_ed1;
    
    reg CO_ed0;
    reg CO_ed1;
    
    reg fire_ed0;
    reg fire_ed1;
    
    reg fall_ed0;
    reg fall_ed1;
    
    reg finger_ok0;
    reg finger_ok1;
    wire finger_ok;
    
    reg finger_no0;
    reg finger_no1;
   wire finger_no;
    
    assign finger_ok=(finger==2'b10)?1:0;
    assign finger_no=(finger==2'b01)?1:0;
    
   
    
    reg [29:0]cnt;
    
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
        wind_ed0<=0;
        wind_ed1<=0;
        rain_ed0<=0;
        rain_ed1<=0;
        CH4_ed0<=0;
        CH4_ed1<=0;
        CO_ed0<=0;
        CO_ed1<=0;
        fire_ed0<=0;
        fire_ed1<=0;
        fall_ed0<=0;
        fall_ed1<=0;
        finger_ok0<=0;
        finger_ok1<=0;
         finger_no0<=0;
         finger_no1<=0;
        end
     else 
     begin
                 wind_ed0<=wind;
                 wind_ed1<=wind_ed0;
                 rain_ed0<=rain;
                rain_ed1<=rain_ed0;
                CH4_ed0<=CH4;
                CH4_ed1<=CH4_ed0;
                CO_ed0<=CO;
                CO_ed1<=CO_ed0;
                fire_ed0<=fire;
                fire_ed1<=fire_ed0;
                fall_ed0<=fall;
                fall_ed1<=fall_ed0;
                finger_ok0<=finger_ok;
                finger_ok1<=finger_ok0;
                finger_no0<=finger_no;
                finger_no1<=finger_no0;                           
       end
 end
 
 always@(posedge clk or negedge rst_n)
     begin
         if(!rst_n)
            cnt<=30'd0;
         else if( (!wind_ed1 & wind_ed0) |(!rain_ed1 & rain_ed0) | (!CH4_ed1 & CH4_ed0) | (!CO_ed1&CO_ed0) | (!fire_ed1 & fire_ed0) | (!fall_ed1& fall_ed0) | (!finger_ok1& finger_ok0) |  (!finger_no1& finger_no0) )
          cnt<=30'd49_999_999;
         else if(cnt>=30'd1)
           cnt<=cnt-1;
          else
           cnt<=30'd0;
     end
     
 always@(posedge clk or negedge rst_n)
     if(!rst_n)
         send_en_2<=0;
     else if((cnt>=30'd2)&(cnt<=30'd499999))
         send_en_2<=1;
      else
      send_en_2<=0;
     
 //assign send_en_2=(!wind_ed1 & wind_ed0)?1:0;
 /*
 always@(posedge clk or negedge rst_n)
 begin
    if(!rst_n)
        send_en_2<=0;
     else if(!wind_ed1 & wind_ed0)
        send_en_2<=1;
      else 
        send_en_2<=send_en_2;
   end
    */
 always@(posedge clk or negedge rst_n)
 begin
    if(rst_n == 1'b0)
    begin
        senser_cmds <= 4'd0;
      //  send_en_2<=0;
      end
    else
    begin
        case(judge)
        
        8'b00000000 : begin 
                                  
                                senser_cmds <= 4'd0;               
                            //    send_en_2<=0;
                                end
        8'b10000000 :  begin
                                   
                                 senser_cmds <= 4'd1;
                             
                                  end
                                                             //  senser_cmds <= 4'd1;
        8'b01000000 :  begin
                                      
                                      senser_cmds <= 4'd2;
                                  
                                end
                                                                                            //senser_cmds <= 4'd2;
        8'b00100000 :  begin
                                      
                                     senser_cmds <= 4'd3;
                                  
                               ///          send_en_2<=1;
                             end
                                                                                                                           //senser_cmds <= 4'd3;
        8'b00010000 :begin
                                         
                                       senser_cmds <= 4'd4;
                                     
                                //     send_en_2<=1;
                                  end
        8'b00001000 :begin
                                                              
                                                                  senser_cmds <= 4'd5;
                                                             
                                                       //           send_en_2<=1;
                                                                  end
        8'b00000100 : begin  
                                                                 
                                                                     senser_cmds <= 4'd6;
                                                                  
                                                            
                                                                               //                   send_en_2<=1;
                                                                                                  end
8'b00000001 : begin                
                                                            senser_cmds <= 4'd9;
                                                         
                                                                                                                                
                                  //               send_en_2<=1;
                                                                                                                                  end
        8'b00000010 : begin                          
                                                                       senser_cmds <= 4'd10;
                                                                
                                                                    end
       
        default : begin
                        senser_cmds <=4'd0;
                //        send_en_2<=0;
                        end
        endcase
    end
 end
 
 
 /*always@(posedge clk or negedge rst_n)
 begin
    if(!rst_n)
        senser_cmds<=4'd0;
     else 
        begin
            if(wind)
                senser_cmds<=4'd1;
             if(rain)
                senser_cmds<=4'd2;
             if(CH4)
                senser_cmds<=4'd3;
             if(CO)
                senser_cmds<=4'd4;
             if(fire)
                senser_cmds<=4'd5;
             if(fall)
                 senser_cmds<=4'd6;    
              if(finger==2'b01)
                senser_cmds<=4'd9; //no
               if(finger==2'b10)
                senser_cmds<=4'd10;//ok
         end
  end*/
     
 
endmodule
