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
	flex_counter count1 #(4) (.clk(clk), .n_rst(n_rst), .clear(d_edge), 
			.count_enable(rcving), .rollover_val('d7), .clear_val('d2),
			.count_out(count_out1));

	// Shift enable logic
	always_comb
	begin
		shift_enable = '0;
		if (count_out1 == 'd4)
		begin
			shift_enable = '1;
		end
	end

	// count from 0 to 7. Should not need the synchronous clear.
	flex_counter count2 #(4) (.clk(clk), .n_rst(n_rst), .clear('0), 
			.count_enable(shift_enable), .rollover_val('d7), .clear_val('d0),
			.count_out(byte_received));

endmodule
