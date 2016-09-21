// $Id: mg111
// File name:   rcv_block.sv
// Created:     9/20/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: Upper level block for the UART design.

module rcv_block
(
	input clk,
	input n_rst,
	input serial_in,
	input data_read,
	output reg [7:0] rx_data,
	output data_ready,
	output overrun_error,
	output framing_error
);
	logic load_buffer;
	logic [7:0] packet_data;
	logic sbc_enable;
	logic sbc_clear;
	logic enable_timer;
	logic packet_done;
	logic shift_strobe;
	logic start_bit_detected;
	logic start_bit;

	// RCU
	rcu FSM(.clk(clk), .n_rst(n_rst), .load_buffer(load_buffer), 
			.start_bit_detected(start_bit_detected), 
			.packet_done(packet_done), .framing_error(framing_error),
			.sbc_clear(sbc_clear), .load_buffer(load_buffer), 
			.enable_timer(enable_timer));

	// Timing Controller
	timer TC(

	// Start-Bit Detector

	// 9-bit Shift REgister

	// Stop-Bit Checker

	// RX Data Buffer


endmodule
