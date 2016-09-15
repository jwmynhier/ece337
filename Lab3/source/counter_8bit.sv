// $Id: mg111
// File name:   counter_8bit.sv
// Created:     9/15/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: wrapper that makes an 8 bit counter.

module counter_8bit
(
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input wire [7:0] rollover_val,
	output reg [7:0] count_out,
	output reg rollover_flag
);

	flex_counter #(8) IN (.clk(clk), .n_rst(n_rst), .clear(clear), .count_enable(count_enable),
			.rollover_val(rollover_val), .count_out(count_out), .rollover_flag(rollover_flag));

endmodule
