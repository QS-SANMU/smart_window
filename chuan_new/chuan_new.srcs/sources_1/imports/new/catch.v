module catch(
input clk_25m,
input rst_mix,
input [3:0]dout,//fifo
input con,
output reg read_begin,//shiftram 开始存入
output reg clk_delay,
output reg vga_finashed,//一帧读完
output reg pixel_finashed,
output reg start,//此刻vga应该开始工作
output etch//腐蚀结果
    );
	
	wire rst_n;
	assign rst_n = rst_mix&con;
	reg [11:0]rgb;
	
	wire pixel;
	assign pixel = (rgb >= 12'b001000111000 )?1'b1:1'b0;//001000100000
	
	reg read_begin1;
	reg [9:0]count_r;//行计数器
	reg [9:0]count_c;//列计数器
	always@(posedge clk_25m or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		count_r<='d0;
		end
		else// if(vga_begin==1'b1)
		begin
			if(count_r=='d799)
			begin
			count_r<='d0;
			end
			else
			begin
			count_r<=count_r+10'd1;
			end
		end
	end
	
	always@(posedge clk_25m or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		count_c<='d0;
		end
		else
		begin
			if(count_r=='d799)
			begin
				if(count_c=='d524)
				begin
				//vga_finashed<=1'b1;
				count_c<='d0;
				end
				else
				begin
				count_c<=count_c+9'd1;
				//vga_finashed<=1'b0;
				end
			end
			else
			begin
			count_c<=count_c;
			//vga_finashed<=1'b0;
			end
		end
	end
	
	//为了扩大,延缓时钟
            always@(posedge clk_25m or negedge rst_n)
            begin
                if(rst_n == 1'b0)
                clk_delay <= 1'b0;
                else
                clk_delay <= ~clk_delay;
            end
            //缓存一行像素,重复三次
            reg [2559 : 0]buffer;
            always@(posedge clk_25m or negedge rst_n)//存入的速率是读出速率的两倍
            begin
                if(rst_n == 1'b0)
                begin
                    buffer <= 'd0;
                end 
                else if(read_begin == 1'b1)
                begin
                    buffer <= {dout , buffer[2559 : 4]};
                end
                else if(count_r >= 'd143 && count_r <= 'd782)
                begin
                    buffer <= {buffer[3 : 0] , buffer[2559 : 4]};
                end
            end
	
	always@(posedge clk_25m or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		rgb<=12'h0;
		read_begin<=1'b0;
		read_begin1 <= 1'b0;
		vga_finashed<=1'b1;
		pixel_finashed <= 1'b0;
		end
		else
		begin
			if(count_c<='d35||count_c>='d516)//516
			begin
				if(count_c>='d516)
                begin
                rgb<=12'h0;
                read_begin<=1'b0;
                read_begin1 <= 1'b0;
                vga_finashed<=1'b1;
                pixel_finashed <= 1'b1;
                end
                else if(count_c=='d35)
                begin
                rgb<=12'h0;
                read_begin<=1'b0;
                read_begin1 <= 1'b0;
                vga_finashed<=1'b0;
                pixel_finashed <= 1'b0;
                end
                else
                begin
                rgb <= 12'h0;
                read_begin <= 1'b0;
                read_begin1 <= 1'b0;
                vga_finashed <= 1'b1;
                pixel_finashed <= 1'b1;
                end
			end
			else if(count_r<='d142||count_r>='d783)//if(count_r<='d143||count_r>='d785)<= 783 
			begin
			     if( count_c % 3 != 'd0)
                 begin
                    if(count_r == 'd142)
                    begin
                     rgb <= 12'h0;
                     read_begin <= 1'b0;
                     read_begin1 <= 1'b1;
                     vga_finashed <= 1'b0;//1
                     pixel_finashed <= 1'b1;
                     end
                     else
                     begin
                     rgb <= 12'h0;
                     read_begin <= 1'b0;
                     read_begin <= 1'b0;
                     read_begin1 <= 1'b0;
                     vga_finashed <= 1'b0;
                     pixel_finashed <= 1'b1;
                     end
                 end
                 else if(count_r == 'd142 && count_c % 3 == 'd0)
                 begin
                    rgb <= 12'h0;
                    read_begin <= 1'b1;
                    read_begin1 <= 1'b1;
                    vga_finashed <= 1'b0;
                    pixel_finashed <= 1'b0;
                 end
                 else
                 begin
                    rgb<=12'h0;
                    read_begin<=1'b0;
                    read_begin1 <= 1'b0;
                    vga_finashed <= 1'b0;
                    pixel_finashed <= 1'b0;
                 end
			end
			else
			begin
			     if(count_c >= 'd504)
                 begin
                 read_begin <= 1'b0;
                 read_begin1 <= 1'b0;
                 rgb <= 'd0;//{buffer[3:0] , buffer[3:0] , buffer[3:0]};
                 vga_finashed <= 1'b0;
                 pixel_finashed <= 1'b1;
                 end
                 else if( count_c % 3 == 'd0)
                 begin
                 read_begin <= 1'b1;
                 read_begin1 <= 1'b1;
                 rgb <= {dout , dout , dout};
                 vga_finashed <= 1'b0;
                 pixel_finashed <= 1'b0;
                 end
                 else
                 begin
                 read_begin <= 1'b0;
                 read_begin1 <= 1'b1;
                 rgb <= {buffer[3:0] , buffer[3:0] , buffer[3:0]};
                 vga_finashed <= 1'b0;
                 pixel_finashed <= 1'b1;
                 end
            end
		end
	end		
	
	always@(posedge clk_25m or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   start <= 1'b0;
	   else if(count_c == 'd1 && count_r == 'd798)
	   start <= 1'b1;
	end
	/*接入shiftram*/
	wire q1;
	wire q2;
	connect c1(
	.clk(clk_25m),
    .ce(read_begin1),
    .d(pixel),
    .q1(q1),
    .q2(q2)
	);
	
	reg etch1;
	reg etch2;
	reg etch3;
	always@(posedge clk_25m or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   begin
	       etch1 <= 1'b0;
	   end
	   else
	   begin
	       etch1 <= q1 & q2 & pixel;
	   end
	end
	
	always@(posedge clk_25m or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   begin
	       etch2 <= 1'b0;
	   end
	   else
	   begin
	       etch2 <= etch1;
	   end
	end
	
	always@(posedge clk_25m or negedge rst_n)
        begin
           if(rst_n == 1'b0)
           begin
               etch3 <= 1'b0;
           end
           else
           begin
               etch3 <= etch2;
           end
        end
        
        assign etch = etch1 & etch2 & etch3;
	
endmodule