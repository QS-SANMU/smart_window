`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/07 20:15:01
// Design Name: 
// Module Name: JQ8900_cmds_tx
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


module JQ8900_cmds_tx(clk,rst_n,LD3320_cmds,senser_cmds,JQ8900_cmds_tx

    );
    input clk;
    input rst_n;
    input [3:0]LD3320_cmds;
    input [3:0]senser_cmds;
    output  reg [4:0]JQ8900_cmds_tx;
   /*
 always@(posedge clk or negedge rst_n)
 begin
    if(!rst_n)
        JQ8900_cmds_tx<=5'd0;
    else if(LD3320_cmds==4'd1)  //小花
        JQ8900_cmds_tx<=5'd1;
    else if(LD3320_cmds==4'd2)  //打开窗户
        JQ8900_cmds_tx<=5'd2;
    else if(LD3320_cmds==4'd3)   //关闭窗户
        JQ8900_cmds_tx<=5'd3;
    else if(LD3320_cmds==4'd4)   //打开客厅窗帘
        JQ8900_cmds_tx<=5'd4;
    else if(LD3320_cmds==4'd5)    //关闭
        JQ8900_cmds_tx<=5'd5;
    else if(LD3320_cmds==4'd6)    //打开卧室窗帘
        JQ8900_cmds_tx<=5'd4;
    else if(LD3320_cmds==4'd7)    //关闭
        JQ8900_cmds_tx<=5'd5;
    else if(senser_cmds==4'd1)
        JQ8900_cmds_tx<=5'd6;
    else if(senser_cmds==4'd2)
        JQ8900_cmds_tx<=5'd7;
    else if(senser_cmds==4'd3)
        JQ8900_cmds_tx<=5'd8;
    else if(senser_cmds==4'd4)
        JQ8900_cmds_tx<=5'd9;
    else if(senser_cmds==4'd5)
        JQ8900_cmds_tx<=5'd10;
    else if(senser_cmds==4'd6)
        JQ8900_cmds_tx<=5'd11;
    else if(senser_cmds==4'd9)
        JQ8900_cmds_tx<=5'd14;
    else if(senser_cmds==4'd10)
        JQ8900_cmds_tx<=5'd15;
    else
        JQ8900_cmds_tx<=5'd0;
 end

*/
 
 always@(posedge clk or negedge rst_n)
  begin
     if(!rst_n)
         JQ8900_cmds_tx<=5'd0;
      
      else if(senser_cmds)
        begin
             case(senser_cmds)
             4'd1:    JQ8900_cmds_tx<=5'd6;
             4'd2:    JQ8900_cmds_tx<=5'd7;
             4'd3:    JQ8900_cmds_tx<=5'd8;
             4'd4:    JQ8900_cmds_tx<=5'd9;
             4'd5:    JQ8900_cmds_tx<=5'd10;
             4'd6:    JQ8900_cmds_tx<=5'd11;
             4'd9:    JQ8900_cmds_tx<=5'd14;
             4'd10:    JQ8900_cmds_tx<=5'd15;
             default:  JQ8900_cmds_tx<=5'd0;
                endcase
        end        
          else if(LD3320_cmds)
                             begin
                               case(LD3320_cmds)
                               4'd1:    JQ8900_cmds_tx<=5'd1;//xiao hua 
                               4'd2:    JQ8900_cmds_tx<=5'd2;  //open
                               4'd3:    JQ8900_cmds_tx<=5'd3;//down
                               4'd4:    JQ8900_cmds_tx<=5'd4;//open curtain
                               4'd5:    JQ8900_cmds_tx<=5'd5;//down
                               4'd6:    JQ8900_cmds_tx<=5'd4;
                               4'd7:    JQ8900_cmds_tx<=5'd5;
                               default:  JQ8900_cmds_tx<=5'd0;
                               endcase
                          end                                                  
    else
          JQ8900_cmds_tx<=5'd0;
  end    
        
 
endmodule
