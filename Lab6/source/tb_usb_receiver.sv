// $Id: mg111
// File name:   tb_usb_reciever.sv
// Created:     10/6/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: top level testbed for Lab 6

`timescale 1ns / 100ps

module tb_usb_receiver
();

	// test signals
	logic tb_clk;
	logic tb_n_rst;
	logic tb_d_plus;
	logic tb_d_minus;
	logic tb_r_enable;
	logic [7:0] tb_r_data;
	logic tb_empty;
	logic tb_full;
	logic tb_rcving;
	logic tb_r_error;

	// setup 96 MHz clock
	realtime CLK_PERIOD = 10.42;
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	usb_receiver DUT (.clk(tb_clk), .n_rst(tb_n_rst), .d_plus(tb_d_plus), .d_minus(tb_d_minus),
			.r_enable(tb_r_enable), .r_data(tb_r_data), .empty(tb_empty), .full(tb_full),
			.rcving(tb_rcving), .r_error(tb_r_error));

	int tb_test_num;

	task reset_receiver;
	begin
		tb_n_rst = '0;

		#(CLK_PERIOD);
		#(CLK_PERIOD);
		
		tb_n_rst = '1;

		#(CLK_PERIOD);
		#(CLK_PERIOD);
	end
	endtask

	task send_bit;
		input logic bit_val;
		input realtime bit_period;
	begin
		tb_d_plus = bit_val;
		tb_d_minus = ~bit_val;
		#(bit_period);

	end
	endtask

	int i;
	task send_sync;
		input realtime bit_period;
	begin
		send_byte(8'h80, bit_period);
	end
	endtask

	task encode_bit;
		input d_bit;
		output logic d_out;
	begin
		if (d_bit == '0)
		begin
			d_out = ~tb_d_plus;
		end else
		begin
			d_out = tb_d_plus;
		end
	end
	endtask

	task send_byte;
		input [7:0] byte_val;
		input realtime bit_period;
	begin
		logic temp;
		encode_bit(byte_val[0], temp);
		send_bit(temp, bit_period);

		encode_bit(byte_val[1], temp);
		send_bit(temp, bit_period);

		encode_bit(byte_val[2], temp);
		send_bit(temp, bit_period);

		encode_bit(byte_val[3], temp);
		send_bit(temp, bit_period);

		encode_bit(byte_val[4], temp);
		send_bit(temp, bit_period);

		encode_bit(byte_val[5], temp);
		send_bit(temp, bit_period);

		encode_bit(byte_val[6], temp);
		send_bit(temp, bit_period);

		encode_bit(byte_val[7], temp);
		send_bit(temp, bit_period);

	end
	endtask

	task send_eop;
		input realtime bit_period;
	begin
		send_bit(~tb_d_plus, bit_period);  // send 0
		send_bit(~tb_d_plus, bit_period);  // send 0

		tb_d_plus = 0;
		tb_d_minus = 0;
		#(bit_period);

	end
	endtask

	task check_out;
		input exp_r_error;
		input exp_rcving;
		input exp_empty;
		input exp_full;
		input [7:0] exp_r_data;
	begin
		if (tb_r_error != exp_r_error) //'0)
		begin
			$error("%0d: r_error FAIL.", tb_test_num);
		end
		if (tb_rcving != exp_rcving) //'0)
		begin
			$error("%0d: rcving FAIL.", tb_test_num);
		end
		if (tb_empty != exp_empty) //'1)
		begin
			$error("%0d: empty FAIL.", tb_test_num);
		end
		if (tb_full != exp_full) //'0)
		begin
			$error("%0d: full FAIL.", tb_test_num);
		end
		if (tb_r_data != exp_r_data) //8'b0)
		begin
			$error("%0d: r_data FAIL.", tb_test_num);
		end
	end
	endtask

	task read_signal;
	begin
		@(negedge tb_clk)
			tb_r_enable = '1;
		#(CLK_PERIOD);
		tb_r_enable = '0;
	end
	endtask

	initial
	begin
		// initial values
		tb_n_rst = '1;
		tb_d_plus = '1;
		tb_d_minus = '0;
		tb_r_enable = '0;

		tb_test_num = 0;
		// power on reset
		reset_receiver;
		check_out('0, '0, '1, '0, 8'b0);

		// Send a byte
		tb_test_num = tb_test_num + 1;
		reset_receiver;
		#(4.0 * CLK_PERIOD);
		send_sync(8.0*CLK_PERIOD);
		send_byte(8'hFF, 8.0*CLK_PERIOD);
		send_eop(8.0*CLK_PERIOD);
		#(CLK_PERIOD / 2.0);
		check_out('0, '0, '0, '0, 8'hFF);
		// one read
		read_signal;
		#(CLK_PERIOD);
		if (tb_empty != '1)
		begin
			$error("%0d: trivial read FAIL.", tb_test_num);
		end
		

		$display("Testing complete.");
	end
endmodule
