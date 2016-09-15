// $Id: mg111
// File name:   tb_moore.sv
// Created:     9/15/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: 1011 sequence detectore Moore model testbed.

`timescale 1ns / 10ps

module tb_moore
();
	int test_num;

	localparam CLK_PERIOD = 2.5;
	reg tb_clk;

	localparam FB_CLK_PER = CLK_PERIOD / 2.0;
	reg fb_clk;

	//setup clock
	always
	begin
		tb_clk = 1'b0;
		fb_clk = 1'b0;
		#(FB_CLK_PER/2.0);
		fb_clk = 1'b1;
		#(FB_CLK_PER/2.0);
		tb_clk = 1'b1;
		fb_clk = 1'b0;
		#(FB_CLK_PER/2.0);
		fb_clk = 1'b1;
		#(FB_CLK_PER/2.0);
	end

	logic tb_n_rst;
	logic tb_i;
	logic tb_o;

	logic [4:0] tb_test_data;
	logic tb_exp_o;

	moore DUT(.clk(tb_clk), .i(tb_i), .o(tb_o), .n_rst(tb_n_rst));
	integer i;
	// test the ouput of the function for a different
	// 5-bit sequence, then reset.
	task five_bits;
		input [4:0] bits;
		input int fb_test_num;
		input fb_expected_o;
		begin
			tb_n_rst = 1'b0;
			tb_i = 0;
	
			@(posedge tb_clk);
			@(posedge tb_clk);
	
			tb_n_rst = 1'b1;
			@(posedge tb_clk);
			@(posedge tb_clk);

			@(posedge tb_clk)
			begin
				
				@(posedge tb_clk)
					#(FB_CLK_PER/2.0)
					begin
					for (i=4; i>=0; i--)
					begin
						@(posedge fb_clk)
							tb_i = bits[i];
						#(CLK_PERIOD);
						
					end
					
					if (tb_o == fb_expected_o)
					begin
						$info("Test %0d: PASS",fb_test_num);
					end else
					begin
						$error("Test %0d: FAIL", fb_test_num);
					end
				end				
			end

			@(posedge tb_clk);
			@(posedge tb_clk);

			tb_n_rst = 1'b0;
			tb_i = 0;
	
			@(posedge tb_clk);
			@(posedge tb_clk);
		end
	endtask

	// run tests
	initial
	begin

		//Test 1, start sequence, async reset
		test_num = 1;
		tb_i = 0;

		@(posedge tb_clk);
		tb_n_rst	<= 1'b0;
		@tb_o;
		tb_n_rst	<= 1'b1; 

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_i = 1;

		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_i = 1'b0;

		if (tb_o == '0)
		begin
			$info("Test 1: PASS");
		end else
		begin
			$error("Test1: FAIL");
		end
		
		tb_n_rst = 1'b1;
		tb_i = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);

		//Test 2
		tb_test_data = 5'b01011;
		tb_exp_o = 1'b1;
		test_num = test_num + 1;
		five_bits (tb_test_data, test_num, tb_exp_o);
	
		//Test 3
		tb_test_data = 5'b10111;
		tb_exp_o = 1'b0;
		test_num = test_num + 1;
		five_bits (tb_test_data, test_num, tb_exp_o);

		//Test 4
		tb_test_data = 5'b10110;
		tb_exp_o = 1'b0;
		test_num = test_num + 1;
		five_bits (tb_test_data, test_num, tb_exp_o);

		//Test 5
		tb_test_data = 5'b01001;
		tb_exp_o = 1'b0;
		test_num = test_num + 1;
		five_bits (tb_test_data, test_num, tb_exp_o);

		//Test 6
		tb_test_data = 5'b10100;
		tb_exp_o = 1'b0;
		test_num = test_num + 1;
		five_bits (tb_test_data, test_num, tb_exp_o);	
	end

endmodule


