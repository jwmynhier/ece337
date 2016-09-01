// $Id: $
// File name:   sensor_b.sv
// Created:     9/1/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: Behavioral Style Sensor Error Detector
module sensor_b
(
	input wire [3:0] sensors,
	output reg error
);

	reg OneAndThree, OneAndTwo;

	always_comb
	begin
		OneAndThree = sensors[1] & sensors[3];
		OneAndTwo = sensors[1] & sensors[2];
		error = sensors[0] | OneAndThree | OneAndTwo;
	end
endmodule