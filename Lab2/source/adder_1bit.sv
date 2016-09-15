// $Id: $
// File name:   adder_1bit.sv
// Created:     9/1/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: 1-bit Full Adder.
module adder_1bit
(
	input wire a,
	input wire b,
	input wire carry_in,
	output wire sum,
	output wire carry_out
);

	always @ (a)
	begin
		assert((a == 1'b1) || (a == 1'b0))
			else $error("'a' is not a digital logic value.");
	end

	always @ (b)
	begin
		assert((b == 1'b1) || (b == 1'b0))
			else $error("'b' is not a digital logic value.");
	end
	
	always @ (carry_in)
	begin
		assert((carry_in == 1'b1) || (carry_in == 1'b0))
			else $error("'carry_in' is not a digital logic value.");
	end

	assign sum = carry_in ^ (a ^ b);
	assign carry_out = (!carry_in & b & a) | (carry_in & (b | a));
endmodule