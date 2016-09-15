// $Id: mg111
// File name:   flex_pts_sr.sv
// Created:     9/14/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: scalable serial to parallel shift register.

module flex_pts_sr
#(
	parameter NUM_BITS = 4,
	parameter SHIFT_MSB = 1  //1->MSB, 0->LSB
)
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire load_enable,
	input wire [NUM_BITS-1:0] parallel_in,
	output logic serial_out
);
	logic [NUM_BITS-1:0] data;
	logic [NUM_BITS-1:0] next_data;

	always_ff @ (posedge clk, negedge n_rst) 
	begin
		if (n_rst == 1'b0) begin
			data = '1;
		end else begin
			data = next_data;
		end
	end

	always_comb
	begin
		next_data = data;
		//$display("BEFORE: in: %b out: %b\n", serial_in, next_out[NUM_BITS-1:0]);
		//$display("%d par_out: %b", NUM_BITS, parallel_out[NUM_BITS-1:0]);
		//$display("%d %d", NUM_BITS, SHIFT_MSB);
		if (load_enable == 1'b1)
		begin
			next_data = parallel_in;
		end else if (shift_enable == 1'b1)
		begin
			if (SHIFT_MSB == 1) 
			begin  // most siginificant bit first
				next_data = {data[NUM_BITS-2:0],1'b1};
				//$display("MSB!");
			end else 
			begin // least significant bit first
				next_data = {1'b1,data[NUM_BITS-1:1]};
			end
		end

			//$display("AFTER: in: %b out: %b\n", serial_in, next_out[NUM_BITS-1:0]);
			//$display("EXPECTED: %b\n", {serial_in,parallel_out[NUM_BITS-1:1]});
	end

	always_comb
	begin
		if (SHIFT_MSB == 1)
		begin
			serial_out = data[NUM_BITS-1];
		end else
		begin
			serial_out = data[0];
		end
	end

endmodule
