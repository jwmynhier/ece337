// $Id: $
// File name:   sensor_d.sv
// Created:     9/1/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: Dataflow Style sensor Error Detector.
module sensor_d
(
	input wire [3:0] sensors,
	output wire error
);

wire OneAndThree, OneAndTwo;

assign OneAndThree = sensors[1] & sensors[3];
assign OneAndTwo = sensors[1] & sensors[2];

assign error = sensors[0] | OneAndThree | OneAndTwo;

endmodule