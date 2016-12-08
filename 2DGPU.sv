// top level for 2d-GPU project for ECE 337 - Fall 2016
// team members: Dwezil D, Nithin V, Pranav G, Joe M

`include "ahb_if.vh"
`include "apb_if.vh"

module 2DGPU(
	input logic clk,
	input logic n_rst,
	ahb_if.ahb_m ahbif,
	apb_if.apb_s apbif
);

	//internal signals		FROM			-> TO
	logic [31:0] address;		// memory manager	-> ahb 
	logic [31:0] color;		// decode		-> ahb
	logic ahb_enable;		// render		-> ahb
	logic [8:0] x;			// render		-> memory manager
	logic [7:0] y;			// render		-> memory manager
	logic flip_buffer;		// decode		-> memory manager	
	logic rcvd_op;			// decode		-> controller
	logic render_done;		// render		-> controller
	logic render_enable;		// controller		-> render & decode
	logic [31:0] status;		// controller		-> apb
	logic [16:0] start;		// decode		-> render
	logic [16:0] end1;		// decode		-> render
	logic [2:0] op;			// decode		-> render
	logic decode_enable;		// apb 			-> decode
	logic [31:0] command_wire;	// apb 			-> decode
	
	//APB
	APB_SlaveInterface apb(
		.apb(apbif),
		.pclk(clk),
		.n_rst(n_rst),
		.status_value(status),		// <- controller
		.command_bus(command_wire),	// -> decode
		.penable(decode_enable)		// -> decode
	);
	
	//decode
	decode_pro decode(
		.clk(clk),
		.nrst(n_rst),
		.penable(decode_enable),	// <- apb
		.render_enable(render_enable),	// -> controller
		.command_bus(command_wire),	// <- apb
		.start(start),			// -> render
		.end1(end1),			// -> render
		.color(color),			// -> render
		.op(op),			// -> render
		.received_op(received_op),	// -> controller
		.flip_buffer(flip_buffer)	// -> memory manager
	);
		
	//render
	render_module render(
		.clk(clk),
		.n_rst(n_rst),
		.start_l(start),		// <- decode
		.end_l(end1),			// <- decode
		.op(op),			// <- decode
		.render_enable(render_enable),	// <- controller
		.x(x),				// -> memory manager
		.y(y),				// -> memory manager
		.enable(ahb_enable),		// -> ahb
		.render_done(render_done)	// -> controller
	);

	//ahb
	AHB_MasterInterface ahb(	
		.ahb(ahbif),
		.hclk(clk),
		.n_rst(n_rst),
		.pixel_address(address),	// <- memory manager
		.color_data(color),		// <- decode
		.write_enable(ahb_enable)	// <- render
	);

	//memory manager
	memoryManager memmanger(
		.addr(address),			// -> ahb
		.n_rst(n_rst),
		.clk(clk), 
  		.x(x),				// <- render
		.y(y),				// <- render
		.flip_buffer(flip_buffer)	// <- decode
	);

	//controller 
	controller ctlr(
		.clk(clk),
		.n_rst(n_rst),
		.received_op(received_op),	// <- decode
		.render_done(render_done),	// <- render
		.status(status),		// -> apb
		.render_enable(render_enable)	// -> render & decode
	);

endmodule
