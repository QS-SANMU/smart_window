`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/07 06:46:33
// Design Name: 
// Module Name: curtain
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


module curtain(clk,rst_n,curtain_cmd,LD3320_cmds,key1_p,key2_p,key1_n,key2_n,curtain_cmds1

    );
    input clk;
    input rst_n;
    input [3:0]curtain_cmd;
    input [3:0]LD3320_cmds;
    input [3:0]curtain_cmds1;
    output reg key1_p;//窗户1  打开 
    output reg key2_p;//窗户2  打开
    output reg key1_n;//窗户1  关闭 
    output reg key2_n;//窗户2  关闭

wire [1:0]judge;
wire [1:0]judge1;
assign judge[1] = (curtain_cmd==4'd1 | LD3320_cmds==4'd4);
assign judge[0] = (curtain_cmd==4'd3 | LD3320_cmds==4'd5);
assign judge1[1] = (curtain_cmds1 ==4'd2 | LD3320_cmds==4'd6);
assign judge1[0] = (curtain_cmds1 ==4'd4 | LD3320_cmds==4'd7);   

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        key1_p <= 0;
        key1_n <= 0;
    end 
    else
    begin
        case(judge)
        2'b10 : 
        begin
            key1_p <=1;
            key1_n <= 0;
        end
        
        2'b01:
        begin
            key1_p <= 0;
            key1_n <= 1;
        end
        
        default :
        begin
            key1_p <= 0;
            key1_n <= 0;
        end
        
        endcase
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        key2_p <= 0;
        key2_n <= 0;
    end
    else
    begin
        case(judge1)
        2'b10:
        begin
            key2_p <= 1;
            key2_n <= 0;
        end
        
        2'b01:
        begin
            key2_p <= 0;
            key2_n <= 1;
        end
        
        default:
        begin
            key2_p <= 0;
            key2_n <= 0;
        end
        endcase
    end
end

/*always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
       begin
        key1_p<=0;
		//key2_p<=0;
		key1_n<=0;
		//key2_n<=0;
	 end
	else if(curtain_cmd==4'd1 | LD3320_cmds==4'd4)
       begin
        key1_p<=1;
		//key2_p<=0;
		key1_n<=0;
		//key2_n<=0;
	   end
	 else if(curtain_cmd==4'd3 | LD3320_cmds==4'd5)
       begin
        key1_p<=0;
		//key2_p<=0;
		key1_n<=1;
		//key2_n<=0;
	    end
	  /*else if(curtain_cmd==4'd2 | LD3320_cmds==4'd6)
       begin
        key1_p<=0;
		key2_p<=1;
		key1_n<=0;
		key2_n<=0;
	    end
	  else if(curtain_cmd==4'd4 | LD3320_cmds==4'd7)
       begin
        key1_p<=0;
		key2_p<=0;
		key1_n<=0;
		key2_n<=1;
	    end// 
	  else 
       begin
        key1_p<=0;
		//key2_p<=0;
		key1_n<=0;
		//key2_n<=0;
	    end*/
	 
//end

/*always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
       begin
        //key1_p<=0;
		key2_p<=0;
		//key1_n<=0;
		key2_n<=0;
	 end
	/*else if(curtain_cmd==4'd1 | LD3320_cmds==4'd4)
       begin
        key1_p<=1;
		//key2_p<=0;
		key1_n<=0;
		//key2_n<=0;
	   end
	 else if(curtain_cmd==4'd3 | LD3320_cmds==4'd5)
       begin
        key1_p<=0;
		//key2_p<=0;
		key1_n<=1;
		//key2_n<=0;
	    end
	  else if(curtain_cmds1==4'd2 | LD3320_cmds==4'd6)
       begin
        //key1_p<=0;
		key2_p<=1;
		//key1_n<=0;
		key2_n<=0;
	    end
	  else if(curtain_cmds1==4'd4 | LD3320_cmds==4'd7)
       begin
       // key1_p<=0;
		key2_p<=0;
	//	key1_n<=0;
		key2_n<=1;
	    end
	  else 
       begin
        //key1_p<=0;
		key2_p<=0;
		//key1_n<=0;
		key2_n<=0;
	    end*/
	 
//end
endmodule