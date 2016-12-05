//top level module for testing the memory manager and the AHB interface together

`include "ahb_if.vh"

module AHBMemoryManager(
	ahb_if.ahb_m ahb,
	input logic n_rst,
	input logic clk,
	input logic enable,
	input logic [31:0] color, 
  input logic [31:0] x,
	input logic [31:0] y,
	input logic flip_buffer
);

	logic [31:0] address;

	AHB_MasterInterface master(	
		.ahb(ahb),
		.hclk(clk),
		.n_rst(n_rst),
		.pixel_address(address),
		.color_data(color),
		.write_enable(enable));

	memoryManager memManager(
		.addr(address),
		.n_rst(n_rst),
		.clk(clk), 
  	.x(x),
		.y(y),
		.flip_buffer(flip_buffer));

endmodule
