// $Id: mg111
// File name:   flex_counter.sv
// Created:     9/14/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: scalable counter module.

`timescale 1ns / 10ps

module flex_counter
#(
	parameter NUM_CNT_BITS = 4
)
(
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input wire [NUM_CNT_BITS-1:0] rollover_val,
	input wire [NUM_CNT_BITS-1:0] clear_val,
	output reg [NUM_CNT_BITS-1:0] count_out
);
	logic [NUM_CNT_BITS-1:0] next_count;

	reg rollover_flag;


	always_ff @ (posedge clk, negedge n_rst) 
	begin
		if (n_rst == 1'b0) begin
			count_out = '0;
		end else begin
			count_out = next_count;
		end
	end

	logic next_flag;

	always_comb
	begin
		next_count = count_out;
		next_flag = '0;
		if (clear == 1'b1)
		begin
			next_count = clear_val;
			next_flag = '0;
		end else if (count_enable == 1'b1)
		begin
			if (count_out == rollover_val)
			begin
				next_count = '0;
				next_flag = '1;
			end else
			begin
				next_count = next_count + 1;
				next_flag = '0;
			end
		end
	end

	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == 0)
		begin
			rollover_flag = 1'b0;
		end else
		begin
			rollover_flag = next_flag;
		end
	end

endmodule
