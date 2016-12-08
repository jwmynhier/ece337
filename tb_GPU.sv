`timescale 1ns / 100ps

`include "ahb_if.vh"
`include "apb_if.vh"

module tb_GPU();

	parameter CLK_PERIOD				= 66.67;

	logic tb_n_rst;
	logic tb_clk;

	//AHB signals
	logic [31:0] tb_HWDATA;
	logic [31:0] tb_HADDR;
	logic tb_HREADY;
	logic tb_HWRITE;

	ahb_if ahb();
	assign tb_HWDATA = ahb.HWDATA;
	assign tb_HADDR = ahb.HADDR;
	assign ahb.HREADY = tb_HREADY;
	assign tb_HWRITE = ahb.HWRITE;

	//APB signals
	logic tb_PSEL;
	logic tb_PWRITE;
	logic [31:0] tb_PWDATA;
	logic [31:0] tb_PRDATA;

	apb_if apb();
	assign apb.PSEL = tb_PSEL;
	assign apb.PWDATA = tb_PWDATA; 
	assign apb.PWRITE = tb_PWRITE;
	assign tb_PRDATA = apb.PRDATA;

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
		.ahbif(ahb.ahb_m),
		.apbif(apb.apb_s)
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
	logic [31:0] flat_address;
	always_comb
	begin
		flat_address = tb_HADDR - initial_buffer_address;
		buffer_x = (flat_address % (XWIDTH*4)) / 4;
		buffer_y = (flat_address - 4*buffer_x) / (4*XWIDTH);
	end
	
	// Write to buffer
	always_ff @ (negedge tb_clk)
	begin
		if (tb_HWRITE == 1'b0)
		begin
			buffer[buffer_y][buffer_x][PIXWIDTH-1:0] = tb_HWDATA;
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
	
	
	initial
	begin
		reset;
	
		
		
		setStart(9'b0, 8'b11101111);
		setEnd(9'b10, 8'b11101111);
				
		setColor(24'hFF0000);
		
		//setEnd(9'b0, 8'b11101111);
		draw;

	
	end

endmodule 
