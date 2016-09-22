// $Id: mg111
// File name:   timer.sv
// Created:     9/20/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: shift timer for the UART design.

module timer
(
	input clk,
	input n_rst,
	input enable_timer,
	output shift_strobe,
	output packet_done
);

	logic count_clear;
	logic [3:0] count_out1;
	// Strobe the shift signal at every 10 cycles.
	flex_counter #(.NUM_CNT_BITS('d4)) C1(.clk(clk), .n_rst(n_rst), .clear(count_clear), 
			.count_enable(enable_timer), .rollover_val(4'd10), 
			.rollover_flag(shift_strobe), .count_out(count_out1));

	// When 9 shifts have been counted, strobe packet_done.
	logic [3:0] count_out2;
	flex_counter #(.NUM_CNT_BITS('d4)) C2(.clk(clk), .n_rst(n_rst), .clear(count_clear), 
			.count_enable(shift_strobe), .rollover_val(4'd9), 
			.rollover_flag(packet_done), .count_out(count_out2));

	// Set up the clear signal.
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == '0)
		begin
			count_clear = '0;
		end else
		begin
			count_clear = packet_done;
		end
	end

endmodule
