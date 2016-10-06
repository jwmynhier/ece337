// $Id: mg111
// File name:   decode.sv
// Created:     10/5/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: decoding block for Lab 6

module decode
(
	input clk,
	input n_rst,
	input d_plus,
	input shift_enable,
	input eop,
	output logic d_orig
);

	logic old_d;
	logic next_old_d;

	// store old_d
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == '0)
		begin
			old_d = '1;  // reset to idle line state.
		end else
		begin
			old_d = next_old_d;
		end
	end

	// next old_d logic
	always_comb
	begin
		if (eop == '1 && shift_enable == '1)
		begin
			next_old_d = '1;
		end else if (shift_enable == '1)
		begin
			next_old_d = d_plus;
		end else
		begin
			next_old_d = old_d;
		end
	end

	logic next_d_orig;

	// store d_orig
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == '0)
		begin
			d_orig = '0;  
		end else
		begin
			d_orig = next_d_orig;
		end
	end

	// next d_orig logic
	always_comb
	begin
		if (shift_enable == '1 && eop == '1)
		begin
			next_d_orig = '0;
		end else
		begin
			next_d_orig = old_d ^ d_plus;
		end 
	end

endmodule
