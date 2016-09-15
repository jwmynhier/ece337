// $Id: $
// File name:   adder_4bit.sv
// Created:     9/1/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: 4-bit adder made from 1-bit adders.
module adder_nbit
#(
	parameter BIT_WIDTH = 4
)
(
	input wire [BIT_WIDTH-1:0] a,
	input wire [BIT_WIDTH-1:0] b,
	input wire carry_in,
	output wire [BIT_WIDTH-1:0] sum,
	output wire overflow
);
	// Check input values
	always @ (a)
	begin	
		assert( !(^a === (1'bz)) && !(^a === 1'bx) )
			else $error("Input 'a' to nbit adder had non-digital logic value %b.", a);
	end
	always @ (b)
	begin	
		assert( !(^b === 1'bz) && !(^b === 1'bx) )
			else $error("Input 'b' to nbit adder had non-digital logic value %b.", b);
	end
	always @ (carry_in)
	begin	
		assert( !(^carry_in === 1'bz) && !(^carry_in === 1'bx) )
			else $error("Input 'carry_in' to nbit adder had non-digital logic value %b.", carry_in);
	end

	reg [BIT_WIDTH:0] carries;
	genvar i;

	assign carries[0] = carry_in;
	generate
		for(i=0; i<BIT_WIDTH; i=i+1)
		begin
			adder_1bit IX (.a(a[i]), .b(b[i]), .carry_in(carries[i]), .sum(sum[i]), .carry_out(carries[i+1]));

			always @ (a[i], b[i], carries[i])
			begin
				assert(((a[i] + b[i] + carries[i]) % 2) == sum[i])
					else $error("Incorrect output from one bit adder ",i);
			end
		end
	endgenerate
	assign overflow = carries[BIT_WIDTH];


endmodule