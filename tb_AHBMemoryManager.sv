`timescale 1ns / 100ps

`include "ahb_if.vh"

module tb_AHBMemoryManager();

	parameter CLK_PERIOD				= 66.67;

	//AHB signals
	logic [31:0] tb_HWDATA;
	logic [31:0] tb_HADDR;
	logic tb_HREADY;
	logic tb_HWRITE;

	logic tb_n_rst;
	logic tb_clk;
	logic tb_enable;
	logic [31:0] tb_color; 
  logic [31:0] tb_x;
	logic [31:0] tb_y;
	logic tb_flip_buffer;

	ahb_if ahbTL();
	assign tb_HWDATA = ahbTL.HWDATA;
	assign tb_HADDR = ahbTL.HADDR;
	assign ahbTL.HREADY = tb_HREADY;
	assign tb_HWRITE = ahbTL.HWRITE;

	AHBMemoryManager DUT(
		.ahb(ahbTL.ahb_m),
		.n_rst(tb_n_rst),
		.clk(tb_clk),
		.enable(tb_enable),
		.color(tb_color),
  	.x(tb_x),
		.y(tb_y),
		.flip_buffer(tb_flip_buffer));

	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	//task to reset module
	task reset;
	begin
		tb_n_rst = 1'b1;
		tb_HREADY = 1'b1;
		tb_color = 32'h0000;
		tb_enable = 1'b0;
		tb_flip_buffer = 1'b0;
		tb_x = 32'h0000;
		tb_y = 32'h0000;
		
		@(negedge tb_clk);

		tb_n_rst = 1'b0;
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		tb_n_rst = 1'b1;
		@(negedge tb_clk);
	end	
	endtask

	//task to set color
	task setColor;
		input logic [31:0] color;	
	begin	
		tb_color = color;
	end
	endtask

	//task to set the x,y,and offset
	task setAddress;
		input logic [31:0] x;
		input logic [31:0] y;
	begin
		tb_x = x;
		tb_y = y;
	end
	endtask

	//task to pulse the enable signal
	task pulseEnable;	
	begin	
		tb_enable = 1'b0;
		tb_enable = 1'b1;
		@(negedge tb_clk);
		tb_enable = 1'b0;
	end
	endtask

	//task to pulse the flip buffer signal
	task flipBuffer;
	begin
		tb_flip_buffer = 1'b0;
		tb_flip_buffer = 1'b1;
		@(negedge tb_clk);
		tb_flip_buffer = 1'b0;
	end
	endtask

	//task to send the next 'draw pixel' AHB command 
	task drawNextPixel;
		input [31:0] x;
		input [31:0] y; 
	begin
		setAddress(x,y);
		pulseEnable; 
		//AHB master in address phase here
		@(negedge tb_clk);
		//AHB master in data phase here
		@(negedge tb_clk); 
		//AHB master back to IDLE
		@(negedge tb_clk); 
	end
	endtask	

	//task to send the next 'draw pixel' AHB command 
	task drawNextPixelWait;
		input [31:0] x;
		input [31:0] y; 
		input integer waitCycles; // waitCycles > 1
		integer i;	
	begin
		
		setAddress(x,y);
		pulseEnable;
		//AHB master in address phase
		@(negedge tb_clk); 
		//AHB master in data phase
		tb_HREADY = 1'b0;
		for(i=0; i<waitCycles; i++)
		begin
			@(negedge tb_clk); //AHB master waiting in data phase
		end
		
		tb_HREADY = 1'b1; //AHB master back to IDLE
		@(negedge tb_clk);
	end
	endtask	

	initial
	begin
		reset;

		setColor(32'h00FF);
		drawNextPixel(32'h0055, 32'h0011);
		drawNextPixel(32'h0056, 32'h0011);	
		drawNextPixel(32'h0056, 32'h0012);

		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);

		flipBuffer;
		@(negedge tb_clk);

		drawNextPixel(32'h0055, 32'h0011);
		drawNextPixel(32'h0056, 32'h0011);	
		drawNextPixel(32'h0056, 32'h0012);

		@(negedge tb_clk);
		setColor(32'h1234);
		@(negedge tb_clk);
			
		drawNextPixel(32'h0000, 32'h0000);
		drawNextPixel(32'h0001, 32'h0000);	
		drawNextPixel(32'h0001, 32'h0001);

		@(negedge tb_clk);
		setColor(32'h5555);
		@(negedge tb_clk);
		flipBuffer;
		@(negedge tb_clk);

		drawNextPixel(32'h0001, 32'h0001);
		drawNextPixel(32'h0002, 32'h0002);	
		drawNextPixel(32'h0003, 32'h0003);

		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);

		//check for: slave makes master wait by keeping HREADY low temporarily
		//wait 1 cycle
		drawNextPixelWait(32'h0001, 32'h0001, 1);
		drawNextPixelWait(32'h0002, 32'h0002, 1);	
	
		//wait 2 cycles (design doesn't handle this case)
		//drawNextPixelWait(32'h0003, 32'h0003, 2);
		//drawNextPixelWait(32'h0004, 32'h0004, 2);	
		
	end

endmodule
