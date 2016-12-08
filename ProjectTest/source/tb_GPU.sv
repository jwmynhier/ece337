// Testbed for the Render Module in the 2D GPU project in ECE 337 Fall 2016
// Joe Mynhier
// 19 November 2016

`timescale 1ns/10ps

module tb_GPU
();

	// track the number of output frames
	int image_number = 0;

	localparam initial_buffer_address = '0;		// first address in buffer. REVISE.
	localparam YWIDTH = 'd480;			// store two 240 pixel tall buffers one above the other
	localparam XWIDTH = 'd320;
	localparam PIXWIDTH = 'd24;
	logic [YWIDTH-1:0][XWIDTH-1:0][PIXWIDTH-1:0] buffer;
	int buffer_x;
	int buffer_y;

	// TEMP
	logic [23:0] tb_address = '0;
	logic [PIXWIDTH-1:0] data = '0;
	logic HWRITE = 1'b0;
	logic tb_clk;
	localparam CLK_PERIOD = 15ns;
	// set up clock
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2.0);
	end

	// decompose the flat packed address with offset into x and y coordinates
	// REVISE: assumed address data taken from AHB was called "tb_address".
	logic [23:0] flat_address;			// REVISE with correct bitwidth
	always_comb
	begin
		flat_address = tb_address - initial_buffer_address;
		buffer_x = flat_address % XWIDTH;
		buffer_y = (flat_address - {8'b0, buffer_x}) / XWIDTH;
	end

	// zero out the buffer
	task buffer_init;
	begin
		int i, j;
		for (i=0; i<YWIDTH; i++)
		begin
			for (j=0; j<XWIDTH; j++)
			begin
				buffer[i][j][PIXWIDTH-1:0] = 24'd255;
			end
		end
	end
	endtask

	// write the buffer to an image
	logic [8*74:0] formated_string;
	task write_buffer
	();
	begin
		int fout;
		int i, j;
		fout = $fopen("./docs/render_buffer.txt", "w");

		// write first buffer.
		for (i=0; i<YWIDTH/2; i++)
		begin
			for (j=0; j<XWIDTH; j++)
			begin
				$fwrite(fout, "%02h,", buffer[i][j][23:16]); // r
				$fwrite(fout, "%02h,", buffer[i][j][15:8]);  // g
				$fwrite(fout, "%02h;", buffer[i][j][7:0]);   // b
			end
			$fwrite(fout, "\n");
		end

		// write dividing line.
		for (j=0; j<XWIDTH; j++)
		begin
			$fwrite(fout, "00,00,00;");
		end
		$fwrite(fout, "\n");

		// write second buffer
		for (i=YWIDTH/2; i<YWIDTH; i++)
		begin
			for (j=0; j<XWIDTH; j++)
			begin
				$fwrite(fout, "%02h,", buffer[i][j][23:16]); // r
				$fwrite(fout, "%02h,", buffer[i][j][15:8]);  // g
				$fwrite(fout, "%02h;", buffer[i][j][7:0]);   // b
			end
			$fwrite(fout, "\n");
		end
		$fwrite(fout, "\n");
		$fclose(fout);

		// Convert to .png file.
		$sformat(formated_string,"python3 ./scripts/colorimg.py ./docs/render_buffer.txt ./docs/buffer%02d.png",image_number); 
		$system(formated_string);
		image_number = image_number + 1;
		
	end
	endtask

	// output logic
	// REVISE: name of HWRITE in AHB interface. Assumed HWRITE.
	// REVISE: name of color data that comes off the AHB. Assumed data.
	always_ff @ (negedge tb_clk)
	begin
		if (HWRITE == 1'b0)
		begin
			buffer[buffer_y][buffer_x][PIXWIDTH-1:0] = data;
		end
	end

	// testing process
	initial
	begin
		buffer_init;
		write_buffer;
		
		$info("End of testing");

	end

endmodule
