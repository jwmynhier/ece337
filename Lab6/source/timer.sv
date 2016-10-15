// $Id: mg111
// File name:   timer.sv
// Created:     10/5/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: timing block for Lab 6

module timer
(
	input clk,
	input n_rst,
	input d_edge,
	input rcving,
	output logic shift_enable,
	output logic byte_received
);

	logic [3:0] count_out1;

	// count from 0 to 7, or 2 to 7 after a clear.
	flex_counter #(4) count1 (.clk(clk), .n_rst(n_rst), .clear(d_edge), 
			.count_enable(rcving), .rollover_val(4'd8), .clear_val(4'd3),
			.count_out(count_out1));

	// Shift enable logic
	always_comb
	begin
		shift_enable = '0;
		if (count_out1 == 'd5)
		begin
			shift_enable = '1;
		end
	end

	// count from 1 to 8, but start at 0 on async reset. This means sync clear
	// needs to reset count to 0 once count = 8.
	logic count2_clear;
	logic [3:0] count_out2;
	always_comb
	begin
		if (count_out2 == 4'd8 || rcving == '0)
		begin
			count2_clear = '1;
		end else
		begin
			count2_clear = '0;
		end
	end

	flex_counter  #(4) count2 (.clk(clk), .n_rst(n_rst), .clear(count2_clear), 
			.count_enable(shift_enable), .rollover_val(4'd8), .clear_val(4'd0),
			.rollover_flag(byte_received), .count_out(count_out2));

endmodule
