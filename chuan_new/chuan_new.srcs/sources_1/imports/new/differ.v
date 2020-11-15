`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/04 14:20:16
// Design Name: 
// Module Name: differ
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


module differ(
input pclk,//����ͷ��ʱ��
input rst_0,
//input [1:0]count_r,//ָʾ�Ҷ�������һ����Ч;
//input l_o,//һ�н����ı�־
input complete,//һ�������غ��˵ı�־
input nothing,//�ڶ��е�����;
input [3:0]dina,//reduce �洢������
input [3:0]douta,//ram������ʱ�����
input con,//��һ֡�洢��ı�־;
//output reg [9:0]r,//��
//output reg [9:0]c,//��
output reg [3:0]save,  //֡���������
output reg clk_differ,
output reg clear//fifo0��λ
    );
    //���ݲ���ͼ��Ϊ�˶���douta�ͻҶ����أ���ʱ����complete��Ȼ��ÿ��pclk������ʱcount1��һ��ÿ��count1Ϊ1ʱdouta�ͻҶ����ض���,��ʱ���
    //����addrb+1��%320Ϊ0ʱ��complete_countӦ�ûص�ԭʼ״̬
    wire flag;
    reg [9:0]r;
    reg [2:0]count1;
     assign flag = (r == 'd319&&count1 == 'd4) ? 1'b1 : 1'b0;
    
    
    reg [1:0]complete_count;
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
            complete_count <= 'd0;
        else if(con == 1'b0)
            complete_count <= 'd0;
        else if(flag == 1'b1)
            complete_count <= 'd0;
        else if(complete == 1'b1&&nothing == 1'b0)
        begin
            if(complete_count == 'd2)
            complete_count <= complete_count;
            else
            complete_count <= complete_count + 'd1;
        end
    end
    
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        count1 <= 'd5;
        else if(con == 1'b0)
        count1 <= 'd5;
        else if(flag == 1'b1)
        count1 <= 'd5;
        /*else if(nothing == 1'b1&&count1 == 'd4)
        count1 <= 'd5;*/
        else if(complete_count == 'd2)
        begin
               if(count1 == 'd5)
               count1 <= 'd0;
               else
               begin
                    if(count1 == 'd4)
                    count1 <= 'd1;
                    else
                    count1 <= count1 + 'd1;
               end
        end
        else
            count1 <= 'd5;
    end
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //��dina��douta����
    wire [3:0]del;
    assign del = (dina>= douta)?(dina - douta):(douta-dina);
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //ÿ��count1Ϊ1ʱ��del����save,������ż�һ
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            save <= 'd0;
        end
        else if(con == 1'b0)
        begin
            save <= 'd0;
        end
        else
        begin
            if(count1 == 'd1) //&& addrb == 'd51199)
            begin
                save <= del;
                //addrb <= 'd0;
            end
            else
            begin
                save <= save;
                //addrb <= addrb + 'd1;
            end
        end
    end 
    
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        clk_differ <= 1'b0;
        else if(con == 1'b0)
        clk_differ <= 1'b0;
        else if(count1 == 'd2)
        clk_differ <= 1'b1;
        else
        clk_differ <= 1'b0;
    end
    
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            r <= 'd319;//0
        end
        else if(con == 1'b0)
        begin
            r <= 'd319;//0
        end
        else if(r == 'd319&&clk_differ == 1'b1)//count1 == 'd4)//320
        begin
            r <= 'd0;
        end
        else if(clk_differ == 1'b1)//count1
        begin
                r <= r + 'd1;
        end
        /*else if(nothing == 1'b1&&count1 == 'd4)
                begin
                    r <= 'd0;
                end*/
    end
    
    reg [9:0]c;
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            c <= 'd159;
        end
        else if(con == 1'b0)
        begin
            c <= 'd159;
        end
        else if(r == 'd319&&clk_differ == 1'b1)//count1 == 'd4)//320
        begin
            if(c == 'd159)
            c <= 'd0;
            else
            c <= c + 'd1;
        end
    end
    
    always@(posedge pclk or negedge rst_0)
    begin
        if(rst_0 == 1'b0)
        begin
            clear <= 1'b1;
        end
        else if(con == 1'b0)
        begin
            clear <= 1'b1;
        end
        else if(c == 'd159 && r == 'd319&&complete == 1'b1)//���clk--differ
        begin
            clear <= 1'b0;
        end
        else if(c == 'd159 && r == 'd318)//count1
        begin
            clear <= 1'b1;
        end
    end
    /////////////////////////////////////////////////////////////////////////////////////////////
    
endmodule
