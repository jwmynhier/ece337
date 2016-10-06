// $Id: mg111
// File name:   tb_edge_detect.sv
// Created:     10/5/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: edge dectection testbed for Lab 6

`timescale 1ns / 100ps

module tb_decode
();

// test signals
	logic tb_clk;
	logic tb_n_rst;
	logic tb_d_plus;
	logic tb_shift_enable;
	logic tb_eop;
	logic tb_d_orig;

	// setup 96 MHz clock
	localparam CLK_PERIOD = 10.42;
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	decode DUT (.clk(tb_clk), .n_rst(tb_n_rst), .d_plus(tb_d_plus), 
			.shift_enable(tb_shift_enable), .eop(tb_eop),
			.d_orig(tb_d_orig));

	int tb_test_num;

	task send_signal;
		input old_d;
		input new_d;
		input expected_orig;
	begin
		tb_shift_enable = '0;

		@(negedge tb_clk)
		begin
			tb_shift_enable = '1;
			tb_d_plus = old_d;
		end

		#(CLK_PERIOD);
		tb_shift_enable = '0;
		tb_d_plus = new_d;
		#(CLK_PERIOD);
		if (tb_d_orig != expected_orig)
		begin
			$error("decode send_signal FAIL old: %0d new: %0d. @ %0d", old_d, new_d, tb_test_num);
		end
	end
	endtask

	task reset;
	begin
		tb_n_rst = '0;

		#(CLK_PERIOD);
		#(CLK_PERIOD);
		
		tb_n_rst = '1;

		#(CLK_PERIOD);
		#(CLK_PERIOD);

	end
	endtask

	logic [1:0] old_var;
	logic [1:0] new_var;
	logic expected;

	initial
	begin
		// set initial value
		tb_d_plus = '1;
		tb_eop = '0;
		tb_shift_enable = '0;
		tb_n_rst = '1;

		// test reset
		tb_test_num = '0;
		reset;
		if (tb_d_orig != '0)
		begin
			$error("decode power on reset FAIL");
		end

		// test internal memory reset to 1 in reset.
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk)
		begin
			tb_d_plus = '1;
		end
		#(CLK_PERIOD)

		if (tb_d_orig != '0)
		begin
			$error("decode internal reset FAIL");
		end

		// test synchronous reset of output.
		tb_test_num = tb_test_num + 1;
		reset;
		tb_shift_enable = '0;

		@(negedge tb_clk)
		begin
			tb_shift_enable = '1;
			tb_eop = '1;
			tb_d_plus = '0;
		end

		#(CLK_PERIOD);
		tb_shift_enable = '0;
		tb_eop = '0;
		if (tb_d_orig != '0)
		begin
			$error("decode synch reset output FAIL");
		end

		// test synchronous reset of internal reg.
		tb_test_num = tb_test_num + 1;
		tb_d_plus = '1;
		#(CLK_PERIOD);
		if (tb_d_orig != '0)
		begin
			$error("decode synch reset internal FAIL");
		end
		
		tb_eop = '1;
		#(CLK_PERIOD);
		tb_eop = '0;
		#(CLK_PERIOD);

		// test all input combinations
		reset;
		for (old_var = 2'b11; old_var >= 2'b01; old_var = old_var - 2'b1)
		begin
			for (new_var = 2'b11; new_var >= 2'b10; new_var = new_var - 2'b1)
			begin
				tb_test_num = tb_test_num + 1;
				if (old_var[0] != new_var[0])
				begin
					expected = '1;
				end else
				begin
					expected = '0;
				end
				send_signal(old_var[0], new_var[0], expected);
			end
		end

		$display("Testing complete.");
	end

endmodule
