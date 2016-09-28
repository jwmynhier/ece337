// $Id: mg111
// File name:   counter.sv
// Created:     9/28/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: magnitude block for Lab 5

module magnitude
(
	input wire [16:0] in,
	output logic [15:0] out
);

	logic is_pos;
	logic [15:0] min_one;
	logic [15:0] flipped;

	// determine sign for muliplexing.
	always_comb
	begin
		is_pos = '0;
		if (in[16] == '1)
			is_pos = '1;
	end

	// convert from negative to unsigned
	// subtract 1
	// flip the bits
	always_comb
	begin
		min_one = in[15:0] - 16'd1;
		flipped = min_one ^ '0;
	end

	// multiplex the result
	always_comb
	begin
		if (is_pos == '1)
		begin
			out = in[15:0];
		end else
		begin
			out = flipped;
		end
	end

endmodule
