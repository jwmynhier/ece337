// Testbed for the Render Module in the 2D GPU project in ECE 337 Fall 2016
// Joe Mynhier
// 19 November 2016

`timescale 1ns/10ps

module tb_GPU
();

	// Buffer tracking and rendering signals.
	int image_number = 0;				// track the number of output frames
	localparam initial_buffer_address = '0;		// first address in buffer. REVISE.
	localparam YWIDTH = 'd480;			// store two 240 pixel tall buffers one above the other
	localparam XWIDTH = 'd320;
	localparam PIXWIDTH = 'd24;
	logic [YWIDTH-1:0][XWIDTH-1:0][PIXWIDTH-1:0] buffer;
	int buffer_x;
	int buffer_y;


	// Decompose the flat packed address with offset into x and y coordinates
	logic [31:0] flat_address;
	always_comb
	begin
		flat_address = tb_HADDR - initial_buffer_address;
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
				buffer[i][j][PIXWIDTH-1:0] = 24'hffffff;
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
	always_ff @ (negedge tb_clk)
	begin
		if (tb_HWRITE == 1'b0)
		begin
			buffer[buffer_y][buffer_x][PIXWIDTH-1:0] = tb_HWDATA;
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
