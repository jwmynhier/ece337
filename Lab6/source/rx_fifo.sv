// $Id: mg111
// File name:   rx_fifo.sv
// Created:     10/5/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: fifo wrapper for Lab 6

module rx_fifo
(
	input clk,
	input n_rst,
	input r_enable,
	input w_enable, 
	input [7:0] w_data,
	output logic [7:0] r_data,
	output logic empty,
	output logic full
);

	fifo F (.r_clk(clk), .w_clk(clk), .n_rst(n_rst), .r_enable(r_enable), 
			.w_enable(w_enable), .w_data(w_data), .r_data(r_data), 
			.empty(empty), .full(full));

endmodule
