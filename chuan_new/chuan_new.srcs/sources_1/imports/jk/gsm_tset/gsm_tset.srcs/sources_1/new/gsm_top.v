`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/06 12:31:47
// Design Name: 
// Module Name: gsm_top
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


module gsm_top(
   clk,
    rst_n,
    GSM_cmds,
    gsm_tx,
    tele_cancel,
    GPRS_rx,
    GPRS_cmd
    );
    input clk;
    input rst_n;
    input [3:0]GSM_cmds;//
    input tele_cancel;
    input GPRS_rx;
    output [7:0]GPRS_cmd;
    output reg gsm_tx;
    
  
     reg flag1;
     reg flag2;
     reg flag3;
     reg flag4;
     reg [87:0]telephone;
     
     wire gsm_tx0;
     wire gsm_tx1;
     wire gsm_tx2;
     wire gsm_tx3;
     
     reg flag1_reg0;
     reg flag1_reg1;
     
     wire flag1_pose;
     
  //   wire po_data;
     wire rx_down;
     
     always@(posedge clk or negedge  rst_n)
        if(!rst_n)
            begin
                flag1_reg0<=0;
                flag1_reg1<=0;
            end
        else 
           begin
                flag1_reg0<=flag1;
                flag1_reg1<=flag1_reg0;
            end 
 assign flag1_pose=(!flag1_reg1)&flag1_reg0;
 
 
     reg flag3_reg0;
     reg flag3_reg1;
     
     wire flag3_pose;
     
     always@(posedge clk or negedge  rst_n)
        if(!rst_n)
            begin
                flag3_reg0<=0;
                flag3_reg1<=0;
            end
        else 
           begin
                flag3_reg0<=flag3;
                flag3_reg1<=flag3_reg0;
            end 
 assign flag3_pose=(!flag3_reg1)&flag3_reg0;
 
     reg flag2_reg0;
     reg flag2_reg1;
     
     wire flag2_pose;
     
     always@(posedge clk or negedge  rst_n)
        if(!rst_n)
            begin
                flag2_reg0<=0;
                flag2_reg1<=0;
            end
        else 
           begin
                flag2_reg0<=flag2;
                flag2_reg1<=flag2_reg0;
            end 
 assign flag2_pose=(!flag2_reg1)&flag2_reg0;
 
 always@(posedge clk or negedge rst_n) 
 begin
    if(!rst_n)
        begin
             flag1<=0;
             flag2<=0;
             flag3<=0;
             flag4<=0;
             telephone<=88'd0;
             gsm_tx<=gsm_tx0;
        end
    else if(GSM_cmds==4'd1)
        begin
             flag1<=1;
             flag2<=0;
             flag3<=0;
             flag4<=0;
             telephone<="18729164024";
              gsm_tx<=gsm_tx0;
        end
     else if(GSM_cmds==4'd2)
        begin
             flag1<=1;
             flag2<=0;
             flag3<=0;
             flag4<=0;
             telephone<="13119160921";
              gsm_tx<=gsm_tx0;
        end
         else if(GSM_cmds==4'd3)
        begin
             flag1<=1;
             flag2<=0;
             flag3<=0;
             flag4<=0;
             telephone<="16713725197";
              gsm_tx<=gsm_tx0;
        end
         else if(GSM_cmds==4'd4)
        begin
             flag1<=1;
             flag2<=0;
             flag3<=0;
             flag4<=0;
             telephone<="15160477836";
              gsm_tx<=gsm_tx0;
        end
    else if(GSM_cmds==4'd5)
        begin
             flag1<=0;
             flag2<=1;
             flag3<=0;
             flag4<=0;
             telephone<=88'd0;
              gsm_tx<=gsm_tx1;
        end
     else if(GSM_cmds==4'd6)
        begin
             flag1<=0;
             flag2<=0;
             flag3<=1;
             flag4<=0;
             telephone<=88'd0;
              gsm_tx<=gsm_tx2;
        end
     else if(GSM_cmds==4'd7)
        begin
             flag1<=0;
             flag2<=0;
             flag3<=0;
             flag4<=1;
             telephone<=88'd0;
              gsm_tx<=gsm_tx3;
        end
     else
      begin
             flag1<=0;
             flag2<=0;
             flag3<=0;
             flag4<=0;
             telephone<=88'd0;
             gsm_tx<=gsm_tx0;
        end 
   end 
   
   

        
        
   gsm_call u1(
      .clk(clk),
	  .rst_n(rst_n),
	  .key_flag1(flag1_pose),
	  .key_flag2(tele_cancel),
	  .telephone(telephone),
	  .line_tx(gsm_tx0)
    );
    
    gsm_messge u2(
    .clk(clk),
	.rst_n(rst_n),
	.key_flag(flag2_pose),
	.line_tx(gsm_tx1)
    );
    
    gsm_GPRS u3(
    .clk(clk),
	.rst_n(rst_n),
	.key_flag(flag3_pose),
	.line_tx(gsm_tx2)
    );
    
    GPRS_rx u4(
     .clk(clk),
	 .rst_n(rst_n),
	 .rx_data(GPRS_rx),
	 .po_data(GPRS_cmd),
	 .rx_down(rx_down)
    );
 /*   
    GPRS_data_judge u5(
    .clk(clk),
	.rst_n(rst_n),
	.parallel_data_rx(po_data),
	.rx_down(rx_down),
    .GPRS_cmd(GPRS_cmd)
);*/
    
   
 
// INST_TAG_END ------ End INSTANTIATION Template -------
endmodule
