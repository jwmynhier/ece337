`timescale 1ns / 100ps

`include "ahb_if.vh"
`include "apb_if.vh"

module tb_GPU();

	parameter CLK_PERIOD				= 66.67;

	logic tb_n_rst;
	logic tb_clk;

	//AHB signals
	logic [31:0] tb_HWDATA;
	logic [31:0] tb_HADDR;
	logic tb_HREADY;
	logic tb_HWRITE;

	ahb_if ahb();
	assign tb_HWDATA = ahb.HWDATA;
	assign tb_HADDR = ahb.HADDR;
	assign ahb.HREADY = tb_HREADY;
	assign tb_HWRITE = ahb.HWRITE;

	//APB signals
	logic tb_PSEL;
	logic tb_PWRITE;
	logic [31:0] tb_PWDATA;
	logic [31:0] tb_PRDATA;

	apb_if apb();
	assign apb.PSEL = tb_PSEL;
	assign apb.PWDATA = tb_PWDATA; 
	assign apb.PWRITE = tb_PWRITE;
	assign tb_PRDATA = apb.PRDATA;

	//DUT
	GPU DUT(
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.ahbif(ahb.ahb_m),
		.apbif(apb.apb_s)
	);

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
		tb_PSEL = 1'b0;
		tb_PWRITE = 1'b1;
		tb_PWDATA = 32'b0;
		
		@(negedge tb_clk);

		tb_n_rst = 1'b0;
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		tb_n_rst = 1'b1;
		@(negedge tb_clk);
	end	
	endtask

	task sendCmd;
		input logic [2:0] opcode;
		input logic [23:0] data;
	begin
		tb_PSEL = 1'b1;
		tb_PWRITE = 1'b1;
		tb_PWDATA = {5'b0, opcode, data};
	
		@(negedge tb_clk);
		@(negedge tb_clk);

		tb_PSEL = 1'b0;
	end
	endtask


	task setColor;
		input logic [23:0] color; 
	begin
		sendCmd(3'b011,color);
	end
	endtask 

	task setStart;
		input logic [8:0] x;
		input logic [7:0] y;
	begin
		sendCmd(3'b001,{7'b0,x,y});
	end	
	endtask

	task setEnd;
		input logic [8:0] x;
		input logic [7:0] y;
	begin
		sendCmd(3'b010,{7'b0,x,y});
	end	
	endtask

	task moveStart;
		input logic [8:0] x;
		input logic [7:0] y;
	begin
		sendCmd(3'b100,{7'b0,x,y});
	end	
	endtask

	task moveEnd;
		input logic [8:0] x;
		input logic [7:0] y;
	begin
		sendCmd(3'b101,{7'b0,x,y});
	end	
	endtask

	task flip;
	begin
		sendCmd(3'b111,24'b0);
	end
	endtask 

	task draw;
	begin
		sendCmd(3'b110,24'b0);
	end
	endtask 

	task clear;
	begin
		sendCmd(3'b000,24'b0);
	end
	endtask 

	initial
	begin
		reset;
	
		$info("sending color red");	
		setColor(24'hFF0000);
	end

endmodule 
