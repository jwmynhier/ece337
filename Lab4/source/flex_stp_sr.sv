// $Id: mg111
// File name:   flex_stp_sr.sv
// Created:     9/12/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: scalable serial to parallel shift register.

module flex_stp_sr
#(
	parameter NUM_BITS = 4,
	parameter SHIFT_MSB = 1  //1->MSB, 0->LSB
)
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire serial_in,
	output logic [NUM_BITS-1:0] parallel_out
);
	logic [NUM_BITS-1:0] next_out;

	always_ff @ (posedge clk, negedge n_rst) 
	begin
		if (n_rst == 1'b0) begin
			parallel_out = '1;
		end else begin
			parallel_out = next_out;
		end
	end

	always_comb
	begin
		next_out = parallel_out;

		if (shift_enable == '1) 
		begin
			if (SHIFT_MSB == 1) 
				next_out = {parallel_out[NUM_BITS-2:0],serial_in};
			end else 
				next_out = {serial_in,parallel_out[NUM_BITS-1:1]};
			end
		end 
	end
endmodule
