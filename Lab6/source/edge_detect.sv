// $Id: mg111
// File name:   edge_detect.sv
// Created:     10/5/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: edge dectection block for Lab 6

module edge_detect
(
	input clk,
	input n_rst,
	input d_plus,
	output logic d_edge
);

	logic old_d;

	// store old_d
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == '0)
		begin
			old_d = '1;  // reset to idle line state.
		end else
		begin
			old_d = d_plus;
		end
	end

	logic next_edge;

	// store d_edge
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == '0)
		begin
			d_edge = '0; 
		end else
		begin
			d_edge = next_edge;
		end
	end

	// next flag logic
	always_comb
	begin
		if ( (old_d ^ d_plus) == '1 )
		// old_d and d_plus are different
		begin
			next_edge = '1;
		end else
		// old_d and d_plus are the same
		begin
			next_edge = '0;
		end
	end

endmodule
