// $Id: mg111
// File name:   eop_detect.sv
// Created:     10/5/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: eop dectection block for Lab 6

module eop_detect
(
	input d_plus,
	input d_minus,
	output eop
);

	assign eop = (d_plus == '0 && d_minus == '0) ? '1 : '0;

endmodule
