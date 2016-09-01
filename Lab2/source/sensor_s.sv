// $Id: $
// File name:   sensor_s.sv
// Created:     9/1/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: Sensor Error Detector Design
module sensor_s
(
	input wire [3:0] sensors,
	output wire error
);

reg OneAndThree, OneAndTwo, SoP;

and OATh (OneAndThree, sensors[1], sensors[3]);
and OATw (OneAndTwo, sensors[1], sensors[2]);
or result (SoP, sensors[0], OneAndThree, OneAndTwo);

assign error = SoP;

endmodule