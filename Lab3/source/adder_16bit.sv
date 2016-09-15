// 337 TA Provided Lab 2 8-bit adder wrapper file template
// This code serves as a template for the 8-bit adder design wrapper file 
// STUDENT: Replace this message and the above header section with an
// appropriate header based on your other code files

module adder_16bit
(
	input wire [15:0] a,
	input wire [15:0] b,
	input wire carry_in,
	output wire [15:0] sum,
	output wire overflow
);
	//check for valid input
	always @*
	begin
		assert( !(^a === 1'bx) && !(^a === 1'bz) )
			else $error("Input 'a' to 16bit adder were incorrect.");

		assert( !(^b === 1'bx) && !(^b === 1'bz) )
			else $error("Input 'b' to 16bit adder were incorrect.");

		assert( !(^carry_in === 1'bX) && !(^carry_in === 1'bZ) )
			else $error("Input 'carry_in' to 16bit adder were incorrect.");
	end

	// STUDENT: Fill in the correct port map with parameter override syntax for using your n-bit ripple carry adder design to be an 8-bit ripple carry adder design
	adder_nbit #(16) IN (.a(a[15:0]), .b(b[15:0]), .carry_in(carry_in), .sum(sum[15:0]), .overflow(overflow));

endmodule
