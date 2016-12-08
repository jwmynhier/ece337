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
	assign ahb.PSEL = tb_PSEL;
	assign ahb.PWDATA = tb_PWDATA； 
	assign ahb.PWRITE = tb_PWRITE;
	assign tb_PRDATA = apb.PRDATA;

	//DUT
	2DGPU DUT(
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


endmodule 

