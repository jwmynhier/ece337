// $Id: mg111
// File name:   shift_register.sv
// Created:     10/6/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: shift register wrapper for Lab 6

module shift_register
(
	input clk,
	input n_rst,
	input shift_enable,
	input d_orig,
	output [7:0] rcv_data
);

	flex_stp_sr #(8, 0) FSS (.clk(clk), .n_rst(n_rst), .shift_enable(shift_enable),
			.serial_in(d_orig), .parallel_out(rcv_data));	

endmodule
