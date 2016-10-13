// $Id: mg111
// File name:   usb_reciever.sv
// Created:     10/6/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: top level block for Lab 6

module usb_receiver
(
	input clk,
	input n_rst,
	input d_plus,
	input d_minus,
	input r_enable,
	output logic [7:0] r_data,
	output logic empty,
	output logic full,
	output logic rcving,
	output logic r_error
);

	// local signals
	logic d_plus_sync;
	logic d_minus_sync;
	logic d_edge;
	logic d_orig;
	logic eop;
	logic byte_received;
	logic [7:0]rcv_data;
	logic w_enable;
	logic shift_enable;

	// sync high
	sync #(1)  SH( .clk(clk), .n_rst(n_rst), .async_in(d_plus), .sync_out(d_plus_sync));

	// sync low
	sync #(0) SL ( .clk(clk), .n_rst(n_rst), .async_in(d_minus), .sync_out(d_minus_sync));

	// edge detect
	edge_detect EDGD ( .clk(clk), .n_rst(n_rst), .d_plus(d_plus_sync), .d_edge(d_edge));

	// decode
	decode D ( .clk(clk), .n_rst(n_rst), .d_plus(d_plus_sync), .shift_enable(shift_enable),
			.eop(eop), .d_orig(d_orig));

	// eop detect
	eop_detect EOPD ( .d_plus(d_plus_sync), .d_minus(d_minus_sync), .eop(eop));

	// timer
	timer T ( .clk(clk), .n_rst(n_rst), .d_edge(d_edge), .rcving(rcving), 
			.shift_enable(shift_enable), .byte_received(byte_received));

	// shift register
	shift_register SR ( .clk(clk), .n_rst(n_rst), .shift_enable(shift_enable), 
			.d_orig(d_orig), .rcv_data(rcv_data));

	// rcu
	rcu R ( .clk(clk), .n_rst(n_rst), .d_edge(d_edge), .eop(eop), .shift_enable(shift_enable),
			.rcv_data(rcv_data), .byte_received(byte_received), .rcving(rcving),
			.w_enable(w_enable), .r_error(r_error));

	// rx fifo
	rx_fifo RF ( .clk(clk), .n_rst(n_rst), .r_enable(r_enable), .w_enable(w_enable), 
			.w_data(rcv_data), .r_data(r_data), .empty(empty), .full(full));

endmodule
