// $Id: mg111
// File name:   tb_flex_counter.sv
// Created:     9/15/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: scalable counter testbed module.

`timescale 1ns / 10ps

module tb_flex_counter
();
	int test_num;
	// use default bit length
	localparam SIZE = 4;
	
	localparam CLK_PERIOD = 2.5;
	reg tb_clk;

	//setup clock
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	logic tb_clear;
	logic tb_n_rst;
	logic tb_count_enable;
	logic [SIZE-1:0] tb_rollover_val;
	logic [SIZE-1:0] tb_count_out;
	logic tb_rollover_flag;

	flex_counter DUT(.clear(tb_clear), .clk(tb_clk), .count_enable(tb_count_enable), .n_rst(tb_n_rst),
		.rollover_val(tb_rollover_val), .count_out(tb_count_out), .rollover_flag(tb_rollover_flag));

	initial
	begin

		$display("Initial!");
		//Test 1, start count, async reset
		test_num = 1;
		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 4'b0100;

		@(posedge tb_clk);
		tb_n_rst	<= 1'b0;
		@tb_count_out;
		tb_n_rst	<= 1'b1; 

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_count_enable = 1'b1;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_count_enable = 1'b0;

		if (tb_count_out == '0)
		begin
			$info("Test 1: PASS");
		end else
		begin
			$error("Test1: FAIL");
		end
		
		tb_n_rst = 1'b1;

		//Test 2, start count, sync reset
		test_num = 2;
		tb_count_enable = 1'b1;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_clear = 1'b1;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_count_enable = 1'b0;

		if (tb_count_out == '0)
		begin
			$info("Test 1: PASS");
		end else
		begin
			$error("Test1: FAIL");
		end
		
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		tb_clear = 1'b1;

		@(posedge tb_clk);
		@(posedge tb_clk);

		//Test 3, verify count 1100
		test_num = 3;
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 4'b1100;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_count_enable = 1'b1;

		@(posedge tb_clk);
		@(posedge tb_clk);


		@(posedge tb_rollover_flag)
		begin
			
			#0.25
			if (tb_count_out == tb_rollover_val)
			begin
				$info("Test 3: PASS");
			end else
			begin
				$error("Test 3: FAIL");
			end
			
		end

		@(posedge tb_clk);
		@(posedge tb_clk);

		//Test 4, verify count 0011
		test_num = 4;
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 4'b0011;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_count_enable = 1'b1;

		@(posedge tb_clk);
		@(posedge tb_clk);

		@(posedge tb_rollover_flag)
		begin
			
			#0.25
			if (tb_count_out == tb_rollover_val)
			begin
				$info("Test 4: PASS");
			end else
			begin
				$error("Test 4: FAIL");
			end
		end

		@(posedge tb_clk);
		@(posedge tb_clk);

		//Test 5, verify count 1001
		test_num = 5;
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 4'b1001;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_count_enable = 1'b1;

		@(posedge tb_clk);
		@(posedge tb_clk);

		@(posedge tb_rollover_flag)
		begin
			
			#0.25
			if (tb_count_out == tb_rollover_val)
			begin
				$info("Test 5: PASS");
			end else
			begin
				$error("Test 5: FAIL");
			end
		end

		@(posedge tb_clk);
		@(posedge tb_clk);

		//Test 6, verify count 0110
		test_num = 6;
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 4'b0110;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_count_enable = 1'b1;

		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_rollover_flag)
		begin
			
			#0.25
			if (tb_count_out == tb_rollover_val)
			begin
				$info("Test 6: PASS");
			end else
			begin
				$error("Test 6: FAIL");
			end
		end

		@(posedge tb_clk);
		@(posedge tb_clk);
	end
endmodule
