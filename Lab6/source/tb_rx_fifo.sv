// $Id: mg111
// File name:   tb_edge_detect.sv
// Created:     10/5/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: fifo testbed for Lab 6

`timescale 1ns / 100ps

module tb_rx_fifo
();

	// test signals
	logic tb_clk;
	logic tb_n_rst;
	logic tb_r_enable;
	logic tb_w_enable;
	logic [7:0] tb_w_data;
	logic [7:0] tb_r_data;
	logic tb_empty;
	logic tb_full;

	// setup 96 MHz clock
	localparam CLK_PERIOD = 10.42;
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	rx_fifo DUT (.clk(tb_clk), .n_rst(tb_n_rst), .r_enable(tb_r_enable),
			.w_enable(tb_w_enable), .w_data(tb_w_data), .r_data(tb_r_data),
			.empty(tb_empty), .full(tb_ful));

	task read;
	begin
		tb_r_enable = 0;
		@(negedge tb_clk)
		begin
			tb_r_enable = '1;
		end
		#(CLK_PERIOD);
		tb_r_enable = 0;
	end
	endtask

	task write;
		input [7:0] write_data;
	begin
		tb_w_enable = 0;
		@(negedge tb_clk)
		begin
			tb_w_enable = '1;
			tb_w_data = write_data;
		end
		#(CLK_PERIOD);
		tb_w_enable = 0;
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

	int tb_test_num = 0;
	int write_count = 0;
	int read_count = 0;
	int i;
	logic [7:0] test_val;

	initial
	begin
		// initializations
		tb_n_rst = 1'b1;
		tb_r_enable = 1'b0;
		tb_w_enable = 1'b0;
		tb_w_data = 8'b0;

		// test power on reset
		reset;
		if (tb_empty != '1)
		begin
			$error("rx_fifo power on reset FAIL");
		end

		// fill the buffer, then deque and check the sum
		tb_test_num = tb_test_num + 1;
		for (i=0; i<8; i++)
		begin
			write(8'b1);
			write_count = write_count + 1;
		end
		for (i=0; i<8; i++)
		begin
			read;
			read_count = read_count + tb_r_data;
		end
		if (read_count != write_count)
		begin
			$error("Buffer fill/empty FAIL. writes: %0d reads: %0d", write_count, read_count);
		end
		#(2.0*CLK_PERIOD);

		tb_test_num = tb_test_num + 1;
		test_val = 8'b00000111;
		write(test_val);
		read;
		if (tb_r_data != test_val)
		begin
			$error("Test %0d fail. data: %0b", tb_test_num, test_val);
		end
		#(2.0*CLK_PERIOD);
		
		tb_test_num = tb_test_num + 1;
		test_val = 8'b00111000;
		write(test_val);
		read;
		if (tb_r_data != test_val)
		begin
			$error("Test %0d fail. data: %0b", tb_test_num, test_val);
		end
		#(2.0*CLK_PERIOD);

		tb_test_num = tb_test_num + 1;
		test_val = 8'b11000001;
		write(test_val);
		read;
		if (tb_r_data != test_val)
		begin
			$error("Test %0d fail. data: %0b", tb_test_num, test_val);
		end
		#(2.0*CLK_PERIOD);

		tb_test_num = tb_test_num + 1;
		test_val = 8'b00001110;
		write(test_val);
		read;
		if (tb_r_data != test_val)
		begin
			$error("Test %0d fail. data: %0b", tb_test_num, test_val);
		end
		#(2.0*CLK_PERIOD);

		$display("Testing complete.");
	end

endmodule
