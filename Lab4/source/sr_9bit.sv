// $Id: mg111
// File name:   sr_9bit.sv
// Created:     9/20/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: 9-bit shift register for the UART design.

module sr_9bit
(
	input clk,
	input n_rst,
	input shift_strobe,
	input serial_in,
	output reg [7:0] packet_data,
	output stop_bit
);

	flex_stp_sr #(.NUM_BITS(9), .SHIFT_MSB(0)) FSS (
			.clk(clk), .n_rst(n_rst), 
			.shift_enable(shift_strobe),
			.serial_in(serial_in),
			.parallel_out({stop_bit,packet_data}));

endmodule
