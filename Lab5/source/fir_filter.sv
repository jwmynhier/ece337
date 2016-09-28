// $Id: mg111
// File name:   fir_filter.sv
// Created:     9/28/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: Top block for Lab 5

module fir_filter
(
	input wire clk,
	input wire n_reset,
	input wire [15:0] sample_data,
	input wire [15:0] fir_coefficient,
	input wire load_coeff,
	input wire data_ready,
	output logic one_k_samples,
	output logic modwait,
	output logic [15:0] fir_out,
	output logic err
);

	// internal signals
	logic dr;
	logic lc;
	logic cnt_up;
	logic clear;
	logic [2:0] op;
	logic [3:0] src1;
	logic [3:0] src2;
	logic [3:0] dest;
	logic overflow;
	logic [16:0] outreg_data;

	// data synch
	sync_low DSYNCH (.clk(clk), .n_rst(n_reset), .async_in(data_ready),
			.sync_out(dr));

	// coef synch
	sync_low CSYNCH (.clk(clk), .n_rst(n_reset), .async_in(load_coeff),
			.sync_out(lc));

	// controll unit
	controller CTRL (.clk(clk), .n_reset(n_reset), .dr(dr), .lc(lc),
			.overflow(overflow), .cnt_up(cnt_up), .clear(clear),
			.modwait(modwait), .op(op), .src1(src1), .src2(src2),
			.dest(dest), .err(err));

	// counter
	counter CNT (.clk(clk), .n_reset(n_reset), .cnt_up(cnt_up), .clear(clear),
			.one_k_samples(one_k_samples));

	// datapath
	datapath DP (.clk(clk), .n_reset(n_reset), .op(op), .src1(src1), .src2(src2),
			.dest(dest), .ext_data1(sample_data), 
			.ext_data2(fir_coefficient), .outreg_data(outreg_data),
			.overflow(overflow));
	// mag
	magnitude MAG (.in(outreg_data), .out(fir_out));

endmodule
