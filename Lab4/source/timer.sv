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
	input timer_enable,
	output shift_strobe,
	output packet_done
);

	// Strobe the shift signal at every 10 cycles.
	localparam RV_C1 = 'd10;
	flex_counter C1(4)(.clk(clk), .n_rst(n_rst), .clear(count_clear), 
			.count_enable(enable_timer), .rollover_val(RV_C1), 
			.rollover_flag(shift_strobe));

	// When 9 shifts have been counted, strobe packet_done.
	localparam RV_C2 = 'd9;
	flex_counter C2(4)(.clk(clk), .n_rst(n_rst), .clear(count_clear), 
			.count_enable(shift_strobe), .rollover_val(RV_C2), 
			.rollover_flag(packet_done));

	// Set up the clear signal.
	logic count_clear;
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
