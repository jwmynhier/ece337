`timescale 1ns / 100ps

module tb_toplevel();

	parameter CLK_PERIOD = 66.67;
	
	logic tb_clk;
	logic n_rst;
	
	logic [31:0] address;		// memory manager	
	logic [31:0] color;		// decode		
	logic ahb_enable;		// render		
	logic [8:0] x;			// render		
	logic [7:0] y;			// render		
	logic flip_buffer;		// decode			
	logic rcvd_op;			// decode		
	logic render_done;		// render		
	logic render_enable;		// controller		
	logic [31:0] status;		// controller		
	logic [16:0] start;		// decode		
	logic [16:0] end1;		// decode		
	logic [2:0] op;			// decode		
	logic decode_enable;		// apb 			
	logic [31:0] command_wire;	

	logic [31:0] tb_PRDATA;
	logic [31:0] tb_PWDATA;
	logic tb_PSEL;
	logic tb_PWRITE;
	logic tb_PENABLE;

	apb_if apbTL();
	assign apbTL.PWDATA = tb_PWDATA;
	assign tb_PRDATA  = apbTL.PRDATA;
	assign apbTL.PWRITE = tb_PWRITE;
	assign apbTL.PENABLE = tb_PENABLE ;
	assign apbTL.PSEL = tb_PSEL;


	module APB_SlaveInterface(
		.apb(apbTL.apb_s),
		.pclk(tb_clk),
		.n_rst(n_rst),
		.status_value(status),		
		.command_bus(command_wire),	
		.penable(decode_enable)		
	);

	decode_pro decode(
		.clk(tb_clk),
		.nrst(n_rst),
		.penable(decode_enable),	
		.render_enable(render_enable),	
		.command_bus(command_wire),	
		.start(start),			
		.end1(end1),			
		.color(color),			
		.op(op),			
		.received_op(received_op),	
		.flip_buffer(flip_buffer)	
	);
	
	render_module render(
		.clk(tb_clk),
		.n_rst(n_rst),
		.start_l(start),		
		.end_l(end1),			
		.op(op),			
		.render_enable(render_enable),	
		.x(x),				
		.y(y),				
		.enable(ahb_enable),		
		.render_done(render_done)	
	);

	
	controller ctlr(
		.clk(tb_clk),
		.n_rst(n_rst),
		.received_op(received_op),	
		.render_done(render_done),	
		.status(status),		
		.render_enable(render_enable)	
	);

	memoryManager memmanger(
		.addr(address),			
		.n_rst(n_rst),
		.clk(tb_clk), 
  		.x(x),				
		.y(y),				
		.flip_buffer(flip_buffer)	
	);


	AHB_MasterInterface ahb(	
		.ahb(ahbif),
		.hclk(tb_clk),
		.n_rst(n_rst),
		.pixel_address(address),	
		.color_data(color),		
		.write_enable(ahb_enable)	
	);

	initial
	begin
		reset;
		write_start;
			
	end

	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end


	task draw;
	begin

		@(negedge tb_clk);
			tb_PWRITE = 1 'b1;
			tb_PSEL = 1 'b1;

	


