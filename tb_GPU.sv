`timescale 1ns / 100ps

module tb_GPU();

	parameter CLK_PERIOD				= 15;

	logic tb_n_rst;
	logic tb_clk;

	//AHB signals
	logic [31:0] tb_HWDATA;
	logic [31:0] tb_HADDR;
	logic tb_HREADY;
	logic tb_HWRITE;

	//APB signals
	logic tb_PSEL;
	logic tb_PWRITE;
	logic [31:0] tb_PWDATA;
	logic [31:0] tb_PRDATA;

	// Buffer tracking and rendering signals.
	int image_number = 0;				// track the number of output frames
	localparam initial_buffer_address = '0;		// first address in buffer. REVISE.
	localparam YWIDTH = 'd480;			// store two 240 pixel tall buffers one above the other
	localparam XWIDTH = 'd320;
	localparam PIXWIDTH = 'd24;
	logic [YWIDTH-1:0][XWIDTH-1:0][PIXWIDTH-1:0] buffer;
	int buffer_x;
	int buffer_y;

//DUT
	GPU DUT(
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.HWDATA(tb_HWDATA),
		.HADDR(tb_HADDR),
		.HWRITE(tb_HWRITE),
		.HREADY(tb_HREADY),
		.PSEL(tb_PSEL),
		.PWRITE(tb_PWRITE),
		.PWDATA(tb_PWDATA),
		.PRDATA(tb_PRDATA)
	);

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
		tb_HREADY = 1'b1;
		tb_PSEL = 1'b0;
		tb_PWRITE = 1'b1;
		tb_PWDATA = 32'b0;
		
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
		tb_PSEL = 1'b1;
		tb_PWRITE = 1'b1;
		tb_PWDATA = {5'b0, opcode, data};
	
		@(negedge tb_clk);
		@(negedge tb_clk);

		tb_PSEL = 1'b0;

		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
	end
	endtask

	task getStatus;
	begin
		tb_PSEL = 1'b1;
		tb_PWRITE = 1'b0;
		//tb_PADDR = 'd100;  // REVISE
	
		@(negedge tb_clk);
		@(negedge tb_clk);

		tb_PSEL = 1'b0;

		@(negedge tb_clk);
		@(negedge tb_clk);
		@(negedge tb_clk);
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


	// Decompose the flat packed address with offset into x and y coordinates
	// Write to buffer.
	logic [31:0] flat_address;
	always @ (tb_HADDR)
	begin
		@(negedge tb_clk)
		begin
			if (tb_HADDR != '0)
			begin
				flat_address = tb_HADDR - initial_buffer_address;
				buffer_x = (flat_address % (XWIDTH*4)) / 4;
				buffer_y = (flat_address - 4*buffer_x) / (4*XWIDTH);
				@(negedge tb_clk)
					buffer[buffer_y][buffer_x][PIXWIDTH-1:0] = tb_HWDATA[23:0];
			end
		end
	end

	// task to zero out the buffer
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

	// task to write the buffer to an image
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
	
	logic [7:0] dummy_var;		// used to gather input from stdin.
	
	int i;
	initial
	begin
		reset;
		buffer_init;
	
		
		
		setStart(9'd0, 8'd0);
		setEnd(9'd319, 8'd239);
				
		setColor(24'hFF0000);
		
		draw;

		#(2004*CLK_PERIOD);
		
		moveStart(9'd319, 8'd0); //final -> (10, 20)
		//moveEnd(9'd40, 8'd110);  //final -> (45, 130)
		setEnd(9'd0, 8'd239);

		flip;
		draw;

		#(2004*CLK_PERIOD);

		write_buffer;
		// pause simulation until given user input.
		//$display("Press enter to continue.");		
		//dummy = $fgetc('h8000_0000);
		setStart(9'd0, 8'd0);
		setEnd(9'd0, 8'd239);
		draw;
		#(2004*CLK_PERIOD);

		for (i=0; i<320; i=i+1)
		begin
			moveStart(9'd1, 8'd0);
			moveEnd(9'd1, 8'd0);
			draw;
			#(2004*CLK_PERIOD);
			
		end
		write_buffer;
		
		
		
		$info("done");
	end

endmodule
