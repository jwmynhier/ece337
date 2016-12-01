// Testbed for the Render Module in the 2D GPU project in ECE 337 Fall 2016
// Joe Mynhier
// 19 November 2016

`timescale 1ns/10ps

module tb_render_module
();
	localparam XWIDTH = 320;
	localparam YWIDTH = 240;
	localparam CLK_PERIOD = 15ns;
	localparam DRAW_LINE_OP = 3'd6;
	localparam CLEAR_OP = 3'd0;
	localparam NOOP = 3'd1;

	// DUT signals.
	logic tb_clk;
	logic tb_n_rst;
	logic [16:0] tb_start_l;
	logic [16:0] tb_end_l;
	logic [2:0] tb_op;
	logic tb_render_enable;
	logic [8:0] tb_x;
	logic [7:0] tb_y;
	logic tb_enable;
	logic tb_render_done;

	// test signals.
	int tb_test_num;

	logic buffer [YWIDTH][XWIDTH];

	task reset;
	begin
		tb_n_rst = 1'b0;
		
		@(posedge tb_clk);
		@(posedge tb_clk);

		@(negedge tb_clk);
		tb_n_rst = 1'b1;

		@(posedge tb_clk);
		@(posedge tb_clk);
	end
	endtask

	// set up clock
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2.0);
	end

	render_module DUT(.clk(tb_clk), .n_rst(tb_n_rst), .start_l(tb_start_l), 
			.end_l(tb_end_l), .op(tb_op), .render_enable(tb_render_enable),
			.x(tb_x), .y(tb_y), .enable(tb_enable), .render_done(tb_render_done));

	task test_binary_out
	(
		input enable_expected,
		input render_done_expected
	);
	begin
		if (tb_enable != enable_expected)
		begin
			$error("[%d]: enable FAIL", tb_test_num);
		end

		if (tb_render_done != render_done_expected)
		begin
			$error("[%d]: render_done FAIL");
		end
	end
	endtask

	// zero out the buffer
	task buffer_init;
	begin
		int i, j;
		for (i=0; i<YWIDTH; i++)
		begin
			for (j=0; j<XWIDTH; j++)
			begin
				buffer[i][j] = 1'b0;
			end
		end
	end
	endtask

	// write the buffer to an image
	task write_buffer
	(
		input overwrite_bool
	);
	begin
		int fout;
		int i, j;
		if (overwrite_bool == 1'b1)
		begin
			fout = $fopen("docs/render_buffer.txt", "w");
		end else
		begin
			fout = $fopen("docs/render_buffer.txt", "a");
		end

		for (i=0; i<YWIDTH; i++)
		begin
			for (j=0; j<XWIDTH; j++)
			begin
				$fwrite(fout, "%b", buffer[i][j]);
			end
			$fwrite(fout, "\n");
		end
		$fwrite(fout, "\n");
		$fclose(fout);
	end
	endtask

	// output logic
	always_ff @ (negedge tb_clk)
	begin
		if (tb_enable == 1'b1)
		begin
			buffer[tb_y][tb_x] = 1'b1;
		end
	end

	task draw_new_line
	(
		input [8:0] start_x,
		input [7:0] start_y,
		input [8:0] end_x,
		input [7:0] end_y,
		input overwrite_buff
	);
	begin
		tb_start_l = {start_x, start_y};
		tb_end_l = {end_x, end_y};
		tb_op = DRAW_LINE_OP;
		
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		tb_render_enable = 1'b1;
		@(posedge tb_render_done);
		@(negedge tb_clk);
		tb_render_enable = 1'b0;
		write_buffer(overwrite_buff);
	end
	endtask

	task clear_buffer;
	begin
		tb_op = CLEAR_OP;
		@(posedge tb_clk);
		@(posedge tb_clk);
		tb_render_enable = 1'b1;

		@(posedge tb_render_done);
		@(negedge tb_clk);
		tb_render_enable = 1'b0;
		write_buffer(1'b1);
	end
	endtask

	// testing process
	initial
	begin
		// set intial states.
		tb_n_rst = 1'b1;
		tb_start_l = 17'b0;
		tb_end_l = 17'b0;
		tb_op = NOOP;
		tb_render_enable = 1'b0;

		buffer_init;
		
		tb_test_num = 0;

		// Test 0: reset
		reset;
		test_binary_out(0, 0);

		// Test 1: "clear" output should be a totaly black image
		tb_test_num = tb_test_num + 1;
		clear_buffer;
		$system("python3 ./scripts/makeimg.py ./docs/render_buffer.txt ./docs/clear.png");
		buffer_init;

		// Test 2: Draw a 3 pixel line
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd10), .start_y(8'd10),
			      .end_x(9'd12), .end_y(8'd12), .overwrite_buff(1'b1));

		// Test 3: slope < 1
		// y = 0.5x + 80
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd0), .start_y(8'd80),
			      .end_x(9'd200), .end_y(8'd180), .overwrite_buff(1'b1));

		// Test 4: slope > 1 
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd5), .start_y(8'd50),
			      .end_x(9'd50), .end_y(8'd140), .overwrite_buff(1'b1));

		$system("python3 ./scripts/makeimg.py ./docs/render_buffer.txt ./docs/render_buffer1.png");
		
		buffer_init;
		// Test 5: max length, origin to far corner
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd0), .start_y(8'd0),
			      .end_x(9'd319), .end_y(8'd239), .overwrite_buff(1'b1));

		// Test 6: max length, other corner pair
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd0), .start_y(8'd239),
			      .end_x(9'd319), .end_y(8'd0), .overwrite_buff(1'b1));

		// Test 7: full width, zero slope
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd0), .start_y(8'd119),
			      .end_x(9'd319), .end_y(8'd119), .overwrite_buff(1'b1));

		// Test 8: full height veritcal line
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd159), .start_y(8'd0),
			      .end_x(9'd159), .end_y(8'd239), .overwrite_buff(1'b1));
		$system("python3 ./scripts/makeimg.py ./docs/render_buffer.txt ./docs/render_buffer2.png");
		buffer_init;

		// Test 9: medium length, 0 < slope < 1
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd159), .start_y(8'd0),
			      .end_x(9'd300), .end_y(8'd40), .overwrite_buff(1'b1));

		// Test 10: medium length, -1 < slope < 0
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd20), .start_y(8'd40),
			      .end_x(9'd159), .end_y(8'd0), .overwrite_buff(1'b1));

		// Test 11: medium length, slope > 1
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd20), .start_y(8'd40),
			      .end_x(9'd81), .end_y(8'd189), .overwrite_buff(1'b1));

		// Test 12: medium length, slope < -1
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd300), .start_y(8'd40),
			      .end_x(9'd238), .end_y(8'd189), .overwrite_buff(1'b1));

		// Test 13: length 1
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd159), .start_y(8'd40),
			      .end_x(9'd159), .end_y(8'd40), .overwrite_buff(1'b1));	

		// Test 14: medium length, slope < -1
		tb_test_num = tb_test_num + 1;
		draw_new_line(.start_x(9'd158), .start_y(8'd42),
			      .end_x(9'd159), .end_y(8'd42), .overwrite_buff(1'b1));		

		$system("python3 ./scripts/makeimg.py ./docs/render_buffer.txt ./docs/render_buffer3.png");
		$info("End of testing");

	end

endmodule
