`timescale 1ns / 100ps


module tb_decode_pro();

	parameter CLK_PERIOD = 66.67;

	logic tb_n_rst;
	logic tb_clk;
	logic tb_penable;
	logic tb_render_enable; 
	logic [31:0] tb_command_bus;
  	logic [16:0] tb_start;
	logic [16:0] tb_end1;
	logic [23:0] tb_color;
	logic [2:0] tb_op;
	logic tb_received_op;
	logic tb_flip_buffer;

	decode_pro DUT(
		.clk(tb_clk),
		.nrst(tb_n_rst),
		.penable(tb_penable),
		.render_enable(tb_render_enable),
		
		.command_bus(tb_command_bus),
  	        .start(tb_start),
		.end1(tb_end1),
		.color(tb_color),
		.op(tb_op),
		.received_op(tb_received_op),
		.flip_buffer(tb_flip_buffer));

	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	//task to reset module
	task reset;
	begin
		tb_n_rst = 1'b1;

		tb_render_enable = 1'b0;
		tb_penable = 1'b0;
		tb_command_bus = 32'b0;
		tb_start = 17'b0;
		tb_end1 = 17'b0;
		tb_color = 24'b0;
		tb_op = 3'b0;
		tb_received_op = 1'b0;
		tb_flip_buffer = 1'b0;
		
		@(negedge tb_clk);

		tb_n_rst = 1'b0;
		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
		tb_n_rst = 1'b1;
		@(negedge tb_clk);
	end	
	endtask

	task sendCmd;
		input logic [2:0] opcode;
		input logic [23:0] data;
	begin
		tb_command_bus = {5'b0, opcode, data};
		tb_penable = 1'b1;
		tb_render_enable = 1'b0;
		@(negedge tb_clk);
		@(negedge tb_clk);

		tb_penable = 1'b0;
	end
	endtask

	task setColor;
		input logic [23:0] color; 
	begin
		$info("sending color red");			
		sendCmd(3'b011,color);
	end
	endtask 

	task setStart;
		input logic [8:0] x;
		input logic [7:0] y;
	begin
		$info("set start");		
		sendCmd(3'b001,{7'b0,x,y});
	end	
	endtask

	task setEnd;
		input logic [8:0] x;
		input logic [7:0] y;
	begin
		$info("set end");	
		sendCmd(3'b010,{7'b0,x,y});
	end	
	endtask

	task moveStart;
		input logic [8:0] x;
		input logic [7:0] y;
	begin
		sendCmd(3'b100,{7'b0,x,y});
	end	
	endtask

	task moveEnd;
		input logic [8:0] x;
		input logic [7:0] y;
	begin
		sendCmd(3'b101,{7'b0,x,y});
	end	
	endtask

	task flip;
	begin
		sendCmd(3'b111,24'b0);
	end
	endtask 

	task draw;
	begin
		$info("draw line");
		sendCmd(3'b110,24'b0);
	end
	endtask 

	task clear;
	begin
		sendCmd(3'b000,24'b0);
	end
	endtask 
	

	initial
	begin
		reset;
		
		setStart(9'd0, 8'd0);
		#(10*CLK_PERIOD);
		assert(tb_start == 16'b0)
	 	 $info("Test 1 has correctly set start ");
		else
	 	 $error("Error start");
		setEnd(9'd319, 8'd239);
		#(10*CLK_PERIOD);
		assert(tb_end1 == {9'd319,8'd239})
	 	 $info("Test 2 has correctly set end ");
		else
	 	 $error("Error end");	
		setColor(24'hFF0000);
		#(10*CLK_PERIOD);
		assert(tb_color == 24'hFF0000)
	 	 $info("Test 3 has correctly set color ");
		else
	 	 $error("Error color");
		
		draw;
		
		assert(tb_received_op == 1'b1)
	 	 $info("Test 5 has correctly set received_op");
		else
	 	 $error("Error rec_op");
		
		#(3*CLK_PERIOD);
		assert(tb_op == 3'b110)
	 	 $info("Test 4 has correctly set op");
		else
	 	 $error("Error op");

		flip;
		
		assert(tb_flip_buffer == 1'b1)
	 	 $info("Test 6 has correctly set flip_buffer");
		else
	 	 $error("Error flip");
		
		#(3*CLK_PERIOD);
		assert(tb_op == 3'b111)
	 	 $info("Test 6 has correctly set op");
		else
	 	 $error("Error op");

		
		clear;
		
		#(3*CLK_PERIOD);
		assert(tb_op == 3'b000)
	 	 $info("Test 7 has correctly set op");
		else
	 	 $error("Error op");

		moveStart(9'd0, 8'd0);
		#(10*CLK_PERIOD);
		assert(tb_start == 16'b0)
	 	 $info("Test 8 has correctly moved start ");
		else
	 	 $error("Error start");
		moveEnd(9'd0, 8'd0);
		#(10*CLK_PERIOD);
		assert(tb_end1 == {9'd319,8'd239})
	 	 $info("Test 9 has correctly move end ");
		else
	 	 $error("Error end");	
		

		
		
		
	end

endmodule

