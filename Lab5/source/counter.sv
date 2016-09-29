// $Id: mg111
// File name:   counter.sv
// Created:     9/28/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: counter wrapper for Lab 5

module counter
(
	input wire clk,
	input wire n_reset,
	input wire cnt_up,
	input wire clear,
	output logic one_k_samples
);

	logic next_oks;		// next one k samples
	//logic [9:0] hold_count; // do nothing with this.
	logic rollover_flag;

	flex_counter #(10) FC (.clk(clk), .n_rst(n_reset), .clear(clear),
			.count_enable(cnt_up), .rollover_val(10'd1000), 
			.rollover_flag(rollover_flag));

	// next output flag logic
	always_comb
	begin
		next_oks = '0;
		if (rollover_flag == '1)
		begin
			next_oks = '1;
		end
		if (one_k_samples == '1 && cnt_up != '1)
		begin
			next_oks = '1;
		end
	end

	always_ff @ (posedge clk, negedge n_reset)
	begin
		if (n_reset == '0)
		begin
			one_k_samples = '0;
		end else
		begin
			one_k_samples = next_oks;
		end
	end

endmodule
