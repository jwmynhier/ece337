// $Id: $
// File name:   adder_4bit.sv
// Created:     9/1/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: 4-bit adder made from 1-bit adders.
module adder_4bit
(
	input wire [3:0] a,
	input wire [3:0] b,
	input wire carry_in,
	output wire [3:0] sum,
	output wire overflow
);

	reg [4:0] carries;
	genvar i;

	assign carries[0] = carry_in;
	generate
		for(i=0; i<4; i=i+1)
		begin
			adder_1bit IX (.a(a[i]), .b(b[i]), .carry_in(carries[i]), .sum(sum[i]), .carry_out(carries[i+1]));
			
		end
	endgenerate
	assign overflow = carries[4];

endmodule