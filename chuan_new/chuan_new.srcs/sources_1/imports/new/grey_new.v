module grey_new(
input pclk,
input rst_0,
input rgb_flag,//与摄像头拼接时，此接口用于指示是否一个像素已经拼接好
input [15:0]rgb_565,
output reg [3:0]grey,
output reg complete
    );
    reg flag_do;
    reg [2:0]count;//流水线中第一个灰度延迟了四个周期
    
    always@(posedge pclk or negedge rst_0)
        begin
            if(rst_0 == 1'b0)
            begin
                complete <= 1'b0;
            end
            else if(flag_do == 1'b1)//100
            begin
                complete <= 1'b1;
            end
            else
                complete <= 1'b0;
        end
        
        reg [9:0]num;
        always@(posedge pclk or negedge rst_0)
        begin
            if(rst_0 == 1'b0)
            begin
                num <= 'd0;
            end
            else if(complete == 1'b1)
            begin
                if(num == 'd639)
                num <= 'd0;
                else
                num <= num + 'd1;
            end
        end
        
        always@(posedge pclk or negedge rst_0)
        begin    
            if(rst_0 == 1'b0)
            begin
                count <= 3'b0;
                //complete <= 1'b0;
            end
            else if(rgb_flag == 1'b1)
            //else
            begin
                if(count == 3'b100)
                begin
                    count <= count;
                    //complete <= 1'b1;
                end
                else
                begin
                    count <= count + 3'b001;
                    //complete <= 1'b0;
                end
            end
            else if(num == 'd639)
            begin
                count <= 'd0;
            end
            else
            begin
                count <= count;
                //complete <= complete;
            end
        end
        
        always@(posedge pclk or negedge rst_0)
        begin
            if(rst_0 == 1'b0)
            flag_do <= 1'b0;
            else if(count == 'd4)
            begin
                flag_do <= ~flag_do;
            end
            else if(complete == 1'b1 && num == 'd639)////////////如果错误删去
            begin
                flag_do <= 1'b0;
            end
        end
        
        /*基于流水线设计*/
            reg [4:0]r;
            reg [5:0]g;
            reg [4:0]b;
            always@(posedge pclk or negedge rst_0)//截取r g b
            begin
                if(rst_0 == 1'b0)
                begin
                    r <= 5'b0;
                    g <= 6'b0;
                    b <= 5'b0;
                end
                else if(flag_do == 1'b1 || rgb_flag == 1'b1)
                //else
                //begin
                begin
                    r <= rgb_565[15:11];
                    g <= rgb_565[10:5] ;
                    b <= rgb_565[4:0]  ;
                end
                //end
                else
                begin
                    r <= r;
                    g <= g;
                    b <= b;
                end
            end
            /*565 2 888*/
            reg [7:0]r_888;
            reg [7:0]g_888;
            reg [7:0]b_888;
            always@(posedge pclk or negedge rst_0)
            begin
                if(!rst_0)
                begin
                    r_888 <= 8'b0;
                    g_888 <= 8'b0;
                    b_888 <= 8'b0;
                end
                else if(flag_do == 1'b1 || rgb_flag == 1'b1)
                //else
                begin
                    r_888 <= {r , r[4 : 2]};
                    g_888 <= {g , g[5 : 4]};
                    b_888 <= {b , b[4 : 2]};
                end
                else
                begin
                    r_888 <= r_888;
                    g_888 <= g_888;
                    b_888 <= b_888;
                end
            end
            
            /*根据公式   执行mul*/
            //parameter bia = 'd32640;
            reg [14:0]r_mul;
            reg [15:0]g_mul;
            reg [12:0]b_mul;
            //reg [15:0]r_mul_1;
            //reg [15:0]g_mul_1;
            //reg [15:0]b_mul_1;
            //reg [15:0]r_mul_2;
            //reg [15:0]g_mul_2;
            //reg [15:0]b_mul_2;
            always@(posedge pclk or negedge rst_0)
            begin
                if(rst_0 == 1'b0)
                begin
                    r_mul <= 15'b0;
                    g_mul <= 16'b0;
                    b_mul <= 13'b0;
                    //r_mul_1 <= 16'b0;
                    //g_mul_1    <= 16'b0;
                    //b_mul_1 <= 16'b0;
                    //r_mul_2 <= 16'b0;
                    //g_mul_2 <= 16'b0;
                    //b_mul_2 <= 16'b0;
                end
                else if(flag_do == 1'b1 || rgb_flag == 1'b1)
                //else
                begin
                    r_mul <= r_888 * 'd77;
                    g_mul <= g_888 * 'd150;
                    b_mul <= b_888 * 'd29;
                    //r_mul_1 <= r_mul_1 * 43;
                    //g_mul_1 <= g_mul_1 * 85;
                    //b_mul_1 <= b_mul_1 * 128;
                    //r_mul_2 <= r_mul_2 * 128;
                    //g_mul_2 <= g_mul_2 * 107;
                    //b_mul_2 <= b_mul_2 * 21;
                end
                else
                begin
                    r_mul <= r_mul;
                    g_mul <= g_mul;
                    b_mul <= b_mul;
                //    r_mul_1 <= r_mul_1;
                //    g_mul_1    <= g_mul_1;
                    //b_mul_1 <= b_mul_1;
                    //r_mul_2 <= r_mul_2;
                    //g_mul_2 <= g_mul_2;
                    //b_mul_2 <= b_mul_2;
                end
            end
            
            //执行add
            reg [15:0]y_add;
            //reg [15:0]cb_add;
            //reg [15:0]cr_add;
            always@(posedge pclk or negedge rst_0)
            begin
                if(rst_0 == 1'b0)
                begin
                    y_add <= 17'b0;
                    //cb_add <= 16'0;
                    //cr_add <= 16'b0;
                end
                else if(flag_do == 1'b1 || rgb_flag == 1'b1)
                //else
                begin
                    y_add <= r_mul + g_mul + b_mul;
                    //cb_add <= r_mul_1 + g_mul_1 + b_mul_1 + bia;
                    //cr_add <= r_mul_2 + g_mul_2 + b_mul_2 + bia;
                end
                else
                begin
                    y_add <= y_add;
                    //cb_add <= cb_add;
                    //cr_add <= cr_add;
                end
            end
            
            //move 高八位
            //reg [7:0]cb;
            //reg [7:0]cr;
            always@(posedge pclk or negedge rst_0)
            begin
                if(rst_0 == 1'b0)
                begin
                    grey <= 4'b0;
                    //cb <= 8'b0;
                    //cr <= 8'b0;
                    //complete <= 1'b0;
                end
                else if(flag_do == 1'b1 || rgb_flag == 1'b1)
                //else 
                begin
                    grey <= y_add[15:12];
                    //cb <= {cb_add[16,9],8'b0};
                    //cr <= {cr_add[16,9],8'b0};
                    //complete <= 1'b1;
                end
                else
                    grey <= grey;
            end
endmodule
