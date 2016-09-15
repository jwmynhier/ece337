// $Id: mg111
// File name:   tb_counter_8bit.sv
// Created:     9/15/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: 8 bit counter testbed module.

`timescale 1ns / 10ps

module tb_counter_8bit
();
	// use default bit length
	localparam SIZE = 8;
	
	localparam CLK_PERIOD = 4.5;
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

	counter_8bit DUT(.clear(tb_clear), .clk(tb_clk), .count_enable(tb_count_enable), .n_rst(tb_n_rst),
		.rollover_val(tb_rollover_val), .count_out(tb_count_out), .rollover_flag(tb_rollover_flag));

	initial
	begin

		$display("Initial!");
		//Test 1, start count, async reset
		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 8'b0100;

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

		//Test 3, verify count 11000000
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 8'b11000000;

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

		//Test 4, verify count 00000011
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 8'b00000011;

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

		//Test 5, verify count 00000110
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 8'b00000110;

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
		//Test 6, verify count 00001100
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 8'b00001100;

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

		//Test 7, verify count 00011000
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 8'b00011000;

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
				$info("Test 7: PASS");
			end else
			begin
				$error("Test 7: FAIL");
			end
		end

		//Test 8, verify count 00110000
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 8'b00110000;

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
				$info("Test 8: PASS");
			end else
			begin
				$error("Test 8: FAIL");
			end
		end

		//Test 9, verify count 01100000
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 8'b01100000;

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
				$info("Test 9: PASS");
			end else
			begin
				$error("Test 9: FAIL");
			end
		end

		//Test 10, verify count 10000001
		tb_n_rst = 1'b0;

		@(posedge tb_clk);
		@(posedge tb_clk);

		tb_n_rst = 1'b1;

		tb_clear = 0; //inactive
		tb_count_enable = 0; //inactive
		tb_rollover_val = 8'b10000001;

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
				$info("Test 10: PASS");
			end else
			begin
				$error("Test 10: FAIL");
			end
		end
	end
endmodule
