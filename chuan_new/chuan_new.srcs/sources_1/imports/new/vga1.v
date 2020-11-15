module vga1(
input clk_vga,
input con,
input rst_mix,
input etch,//fifo
input start,
//input vga_begin,//sdram发来的控制vga是否工作的信号;
//input vsync,
output [3:0] red,
output [3:0] green,
output [3:0] blue,
output reg c_t,//场同步
output reg h_t,//行同步
//output reg [3:0]led,
output reg [31:0]gravity0,//重心最新;
output reg [31:0]gravity1,//重心前一帧;
output reg fall
    );
	reg [11:0]rgb;
	wire rst_n;
	
	assign rst_n = rst_mix & con;
	assign {red,green,blue} = rgb;
	
	/*always@(posedge clk or negedge rst_mix)
	begin
		if(rst_mix=='d0)
		clk_vga<=1'b0;
		else
		clk_vga<=~clk_vga;
	end*/
	
	reg [9:0]count_r;//行计数器
	reg [9:0]count_c;//列计数器
	always@(posedge clk_vga or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		count_r<='d0;
		end
		else if(start == 1'b1)// if(vga_begin==1'b1)
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
		/*else
		begin
			count_r<='d0;
		end*/
	end
	
	always@(posedge clk_vga or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		count_c<='d0;
		//vga_finashed<=1'b0;
		end
		/*else  if(down_begin==1'b1)//
		begin
			count_c<='d0;
		end*/
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
	
	always@(posedge clk_vga or negedge rst_n)  //行同步
	begin
		if(rst_n==1'b0)
		h_t<='d0;
		else if(count_r<='d95)//
		h_t<='d1;
		else
		h_t<='d0;
	end
	
	always@(posedge clk_vga or negedge rst_n) //场同步
	begin
		if(rst_n==1'b0)
		c_t<='d0;
		else if(count_c<='d1)//
		c_t<='d1;
		else
		c_t<=1'b0;
	end
	
	//添加重心线
        reg [9:0]pixel_white;//存下像素点有效的坐标
        reg [9:0]pixel_white0;//存下像素有效的坐标
        reg [9:0]pixel_white1;//比较大小
        reg [9:0]pixel_white2;//比较大小
        
        reg [9:0]pr;
        reg [9:0]pr0;
        reg [9:0]pr1;
        reg [9:0]pr2;
    reg [9:0]next_pixel;//第一次采集到有效坐标；最高
    reg [9:0]next_pixel1;//最后一次采集到有效坐标;最低
    reg [9:0]next_r;
    reg [9:0]next_r1;//宽
	always@(posedge clk_vga or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
		rgb<=12'h0;
		end
		else
		begin
			if(count_c<='d35||count_c>='d516)//516
			begin
				/*if(count_c>='d196)//516 >=
				begin
				rgb<=12'hfff;
				read_begin<=1'b0;
				vga_finashed<=1'b1;
				end
				else if(count_c=='d35)
				begin
				rgb<=12'hfff;
				read_begin<=1'b0;
				vga_finashed<=1'b0;
				end*/
				if(count_c>='d516)
                begin
                rgb<=12'h0;
                end
                else if(count_c=='d35)
                begin
                rgb<=12'h0;
                end
			end
			else if(count_r<='d142||count_r>='d783)//if(count_r<='d143||count_r>='d785)<= 783 
			begin
                rgb<=12'h0;
			end
			else
			begin
                   if(count_c >= 'd504)
                   begin
                   rgb <= 12'h0;
                   end
                   else if( (count_c == next_pixel && count_r > next_r && count_r < next_r1)  || (count_c == next_pixel1 && count_r > next_r && count_r < next_r1))
                   begin
                   rgb <= 12'hfff;
                   end
                   else if( (count_r == next_r && count_c > next_pixel && count_c < next_pixel1) || (count_r == next_r1 && count_c < next_pixel1 && count_c > next_pixel))
                   begin
                   rgb <= 12'hfff;
                   end
                   else if(count_c == gravity0)
                   begin
                   rgb <= 12'h00f;
                   end
                   else if(count_c == gravity1)
                   begin
                   rgb <= 12'hf00;
                   end
                   else
                   begin
                        if(etch == 1'b1)
                        rgb <= 12'hfff;
                        else
                        rgb <= 12'h000;
                   end
             end
       end
	end		
	
	reg [32:0]count;
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   count <= 'd0;
	   else if(count_r == 'd783)
	   count <= 'd0;
	   else if(count_r > 'd142 && count_r <'d783 && count_c > 'd35 && count_c < 'd504 && etch == 1'b1)
	   count <= count + 'd1;
	end
	
	//添加重心线
	//reg [9:0]pixel_white;//存下像素点有效的坐标
	//reg [9:0]pixel_white0;//存下像素有效的坐标
	//reg [9:0]pixel_white1;//比较大小
	//reg [9:0]pixel_white2;//比较大小
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   begin
	   pixel_white <= 'd504;
	   pixel_white0 <= 'd35;
	   //count <= 'd0;
	   //led <= 4'b0;
	   end
	   else if(count_c > 'd503)
	   begin
	   pixel_white <= 'd504;
	   pixel_white0 <= 'd35;
	   //count <= 'd0;
	   //led <= 4'b0;
	   end
	   //else if(count_r >= 'd783)
	   //begin
	   //pixel_white <= pixel_white;
	   //pixel_white0 <= pixel_white0;
	   //count <= 'd0;
	   //end
	   else if(count_r >= 'd143 && count_r <='d782 && count_c <= 'd503 && count_c > 'd35 && etch == 1'b1)// && count >= 'd15)
	   begin
	      // if(count == 'd10)
	       //begin
	           pixel_white <= count_c;
	           pixel_white0 <= count_c;
	           //count <= count;
	       //end
	       //else
	       //begin
	           //count <= count + 'd1;
	       //end
	   //pixel_white <= count_c;
	   //pixel_white0 <= count_c;
	   //led <= 4'b1111;
	   end
	   else
	   begin
	   //count <= count;
	   pixel_white <= pixel_white;
	   pixel_white0 <= pixel_white0;
	   //led <= 4'b0;
	   end
	end
	
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   begin
	       pr <= 'd783;
	       pr0 <= 'd142;
	   end
	   else if(count_c > 'd503)
	   begin
	       pr <= 'd783;
	       pr0 <= 'd142;
	   end
	   else if(count_r >= 'd143 && count_r <='d782 && count_c <= 'd503 && count_c > 'd35 && etch == 1'b1)
	   begin
	       pr <= count_r;
	       pr0 <= count_r;
	   end
	end
	
	always@(posedge clk_vga or negedge rst_n)
        begin
           if(rst_n == 1'b0)
           pixel_white1 <= 'd504;
           else if(count_c >= 'd504)
           pixel_white1 <= 'd504;
           else if(pixel_white < pixel_white1)
           pixel_white1 <= pixel_white;
           else
           pixel_white1 <= pixel_white1;
        end
        
   always@(posedge clk_vga or negedge rst_n)
       begin
           if(rst_n == 1'b0)
           pixel_white2 <= 'd35;
           else if(count_c >= 'd504)
           pixel_white2 <= 'd35;
           else if(pixel_white0 > pixel_white2)
           pixel_white2 <= pixel_white0;
           else
           pixel_white2 <= pixel_white2;
           end
	
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   pr1 <= 'd783;
	   else if(count_c >= 'd504)
	   pr1 <= 'd783;
	   else if(pr < pr1)
	   pr1 <= pr;
	end
	
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   pr2 <= 'd142;
	   else if(count_c >= 'd504)
	   pr2 <= 'd142;
	   else if(pr0 > pr2)
	   pr2 <= pr0;
	end
	
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   next_pixel <= 'd35;
	   else if(count_c == 'd503)//若是516，那么将会在800个周期内一直赋值，只有第一个周期是真正的坐标
	   next_pixel <= pixel_white1;
	   else
	   next_pixel <= next_pixel;
	end
	
	always@(posedge clk_vga or negedge rst_n)
        begin
           if(rst_n == 1'b0)
           next_pixel1 <= 'd504;
           else if(count_c == 'd503)//若是516，那么将会在800个周期内一直赋值，只有第一个周期是真正的坐标
           next_pixel1 <= pixel_white2;
           else
           next_pixel1 <= next_pixel1;
        end
	
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   next_r <= 'd142;
	   else if(count_c == 'd503)
	   next_r <= pr1;
	end
	
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   next_r1 <= 'd783;
	   else if(count_c == 'd503)
	   next_r1 <= pr2;
	end
	/*always@(posedge clk_vga or negedge rst_mix)
	begin
	   if(rst_mix == 1'b0)
	   led <= 4'b0;
	   else if( pixel_white2 > 'd0 && pixel_white2 < 'd190)
	   led <= 4'b1111;
	   else
	   led <= 4'b0;
	end*/
	wire [9:0]weidth;
	wire [9:0]height;
	assign weidth = next_r1 - next_r;
	assign height = next_pixel1 - next_pixel; 
	///////////////////////////计算重心//////////////////////////////////
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   gravity0 <= 'd504;
	   else if(count_c == 'd503&&count_r == 'd783)
	   begin
	       if(pixel_white1 == 'd504 && pixel_white2 == 'd35)//物体不动
	       gravity0 <= 'd504;
	       else
	       gravity0 <= next_pixel1 -( height * 3 / 5);
	   end
	   else
	   gravity0 <= gravity0;
	end
	
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   gravity1 <= 'd504;
	   else if(count_c == 'd503&&count_r == 'd783)
	   begin
	       if(pixel_white1 == 'd504 && pixel_white2 == 'd35)
	       gravity1 <= 'd504;
	       else
	       gravity1 <= gravity0;
	   end
	   else
	   gravity1 <= gravity1;
	end
            
	
	reg [31:0]diff;
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   begin
	       diff <= 'd0;
	   end
	   else if(count_c == 'd503 && count_r == 'd784)
	   begin
	       if(pixel_white1 == 'd504 && pixel_white2 == 'd35)
	           diff <= 'd0;
	       else if(gravity0 > gravity1)
	       begin
	           diff <= gravity0 - gravity1;
	       end
	       else
	       begin
	           diff <= 'd0;
	       end
	   end
	end
       
    wire [9:0]rate;
    assign rate = weidth / height * 'd10;
	always@(posedge clk_vga or negedge rst_n)
	begin
	   if(rst_n == 1'b0)
	   begin
	       fall <= 1'b0;
	   end
	   else if(diff > 'd65 && rate > 'd12)
	   begin
	       fall <= 1'b1;
	   end
	end
	
	
	//assign next_pixel = pixel_white + 'd1;
endmodule
