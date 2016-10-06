// $Id: mg111
// File name:   tb_eop_detect.sv
// Created:     10/5/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: eop dectection testbed for Lab 6

`timescale 1ns / 100ps

module tb_eop_detect
();

	// loop vars
	logic [1:0] plus_var;
	logic [1:0] minus_var;

	// test signals
	logic tb_d_plus;
	logic tb_d_minus;
	logic tb_eop;

	eop_detect DUT (.d_plus(tb_d_plus), .d_minus(tb_d_minus), .eop(tb_eop));

	// testing
	initial
	begin

		for (plus_var = 2'b11; plus_var >= 2'b01; plus_var = plus_var - 2'b1)
		begin
			tb_d_plus = plus_var[0];
			for (minus_var = 2'b11; minus_var >= 2'b10; minus_var = minus_var - 2'b1)
			begin
				tb_d_minus = minus_var[0];
				#1
				if ((tb_d_minus=='0 && tb_d_plus=='0 && tb_eop=='1) || ( (tb_d_minus!='0 || tb_d_plus!='0) && tb_eop == '0))
				begin
					$info("eop_detect PASS %0d %0d", tb_d_plus, tb_d_minus);
				end else
				begin
					$error("eop_detect FAIL %0d %0d", tb_d_plus, tb_d_minus);
				end
			end
		end

	end
endmodule
