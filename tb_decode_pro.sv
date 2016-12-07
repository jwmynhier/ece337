`timescale 1ns / 100ps


module tb_decode_pro();

	parameter CLK_PERIOD = 66.67;

	logic tb_n_rst;
	logic tb_clk;
	logic tb_penable;
	logic tb_render_enable; 
	logic [31:0] tb_command_bus;
  	logic [16:0] tb_start;
	logic [16:0] tb_end1;
	logic [23:0] tb_color;
	logic [2:0] tb_op;
	logic tb_received_op;
	logic tb_flip_buffer;

	decode_pro DUT(
		.clk(tb_clk),
		.nrst(tb_n_rst),
		.penable(tb_penable),
		.render_enable(tb_render_enable),
		
		.command_bus(tb_command_bus),
  	        .start(tb_start),
		.end1(tb_end1),
		.color(tb_color),
		.op(tb_op),
		.received_op(tb_received_op),
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

		tb_render_enable = 1'b0;
		tb_penable = 1'b0;
		tb_command_bus = 32'b0;
		tb_start = 17'b0;
		tb_end1 = 17'b0;
		tb_color = 24'b0;
		tb_op = 3'b0;
		tb_received_op = 1'b0;
		tb_flip_buffer = 1'b0;
		
		@(negedge tb_clk);

		tb_n_rst = 1'b0;
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		tb_n_rst = 1'b1;
		@(negedge tb_clk);
	end	
	endtask

	

	initial
	begin
		reset;

		
		
	end

endmodule