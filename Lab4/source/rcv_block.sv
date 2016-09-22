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
	logic stop_bit;

	// RCU
	rcu FSM(.clk(clk), .n_rst(n_rst), .load_buffer(load_buffer), 
			.start_bit_detected(start_bit_detected), 
			.packet_done(packet_done), .framing_error(framing_error),
			.sbc_clear(sbc_clear), .sbc_enable(sbc_enable), 
			.enable_timer(enable_timer));

	// Timing Controller
	timer TC(.clk(clk), .n_rst(n_rst), .enable_timer(enable_timer), 
			.shift_strobe(shift_strobe), .packet_done(packet_done));

	// Start-Bit Detector
	start_bit_det SBD(.clk(clk), .n_rst(n_rst), .serial_in(serial_in),
			.start_bit_detected(start_bit_detected));

	// 9-bit Shift Register
	sr_9bit SR9(.clk(clk), .n_rst(n_rst), .shift_strobe(shift_strobe), 
			.serial_in(serial_in), .packet_data(packet_data),
			.stop_bit(stop_bit));

	// Stop-Bit Checker
	stop_bit_chk SBC(.clk(clk), .n_rst(n_rst), .sbc_clear(sbc_clear),
			.sbc_enable(sbc_enable), .stop_bit(stop_bit),
			.framing_error(framing_error));

	// RX Data Buffer
	rx_data_buff RDB(.clk(clk), .n_rst(n_rst), .load_buffer(load_buffer),
			.packet_data(packet_data), .data_read(data_read),
			.rx_data(rx_data), .data_ready(data_ready), 
			.overrun_error(overrun_error));


endmodule
