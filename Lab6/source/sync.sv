// $Id: mg111
// File name:   sync.sv
// Created:     10/6/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: sync wrapper for Lab 6

module sync
#(
	parameter ACTIVE_HIGH = 1
)
(
	input clk,
	input n_rst,
	input async_in,
	output logic sync_out
);

	reg midline = 0; //Connector between flip-flops.

	logic rst_val;
	always_comb
	begin
		if (ACTIVE_HIGH == 1)
		begin
			rst_val = 1'b1;
		end else
		begin
			rst_val = 1'b0;
		end
	end
	
	always_ff @(posedge clk, negedge n_rst)
	begin
		if (n_rst == 1'b0)
		begin
			midline <= rst_val;
		end else
		begin
			midline <= async_in;
		end
	end

	//second flip-flop
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == 1'b0)
		begin
			sync_out <= rst_val;
		end else
		begin
			sync_out <= midline;
		end
	end

endmodule
