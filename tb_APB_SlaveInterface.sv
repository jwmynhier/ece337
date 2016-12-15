`timescale 1ns / 100ps

`include "apb_if.vh"

module tb_APB_SlaveInterface();

	parameter CLK_PERIOD = 15;

	logic tb_n_rst;
	logic tb_clk;
	logic [31:0] tb_status_value;
	logic [31:0] tb_command_bus; 
	logic tb_penable;
  	
	//APB signals
	logic [31:0] tb_PRDATA;
	logic [31:0] tb_PWDATA;
	logic tb_PSEL;
	logic tb_PWRITE;
	logic tb_PENABLE;



	apb_if apbTL();
	assign apbTL.PWDATA = tb_PWDATA;
	assign tb_PRDATA  = apbTL.PRDATA;
	assign apbTL.PWRITE = tb_PWRITE;
	assign apbTL.PENABLE = tb_PENABLE ;
	assign apbTL.PSEL = tb_PSEL;

	APB_SlaveInterface DUT(
		.apb(apbTL.apb_s),
		.pclk(tb_clk),
		.n_rst(tb_n_rst),
		.status_value(tb_status_value),
		.command_bus(tb_command_bus),
		.penable(tb_penable));

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

		tb_status_value = 1'b0;
		
		
		
		@(negedge tb_clk);

		tb_n_rst = 1'b0;
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		tb_n_rst = 1'b1;
		@(negedge tb_clk);
	end	
	endtask

	task write;
	begin
		@(negedge tb_clk);
		tb_PWRITE = 1 'b1;
		tb_PSEL = 1 'b1;
		tb_PWDATA = {1'b1,31'b0};
		@(negedge tb_clk);
		assert(tb_command_bus == {1'b1,31'b0})
			$info("success, data is on the command bus");
		else
			$error("failed, data didnt go to the command bus");
		@(negedge tb_clk);
		tb_PSEL = 1 'b0;
		tb_PWDATA = {1'b0,31'b1111111111111111111111111111111};
		@(posedge tb_clk);
		assert(tb_command_bus == {1'b0,31'b1111111111111111111111111111111})
			$info("success , data changed");
		else
			$error("failed , data didnt change");
		
		
		
	end	
	endtask

	task read;
	begin
		@(negedge tb_clk);
		tb_PWRITE = 1 'b0;
		tb_PSEL = 1 'b1;
		tb_status_value = {1'b1,31'b0};
		@(negedge tb_clk);
		assert(tb_PRDATA  == {1'b1,31'b0})
			$info("success, data is on the read bus");
		else
			$error("failed, data didnt go to the read bus");
		@(negedge tb_clk);
		tb_PSEL = 1 'b0;
		tb_status_value = {1'b0,31'b1111111111111111111111111111111};
		@(posedge tb_clk);
		assert(tb_PRDATA == {1'b0,31'b1111111111111111111111111111111})
			$info("success , data changed on read bus");
		else
			$error("failed , data didnt change on read bus");
		
		
		
	end	
	endtask


	

	initial
	begin
		reset;
		write;
		reset;
		read;

		
		
	end

endmodule
