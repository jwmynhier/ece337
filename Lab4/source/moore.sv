// $Id: mg111
// File name:   moore.sv
// Created:     9/15/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: moore model 1101 sequence detector.

module moore
(
	input wire clk,
	input wire n_rst,
	input wire i,
	output reg o
);
	localparam NUM_STATE_BITS = 3;
	typedef enum logic [NUM_STATE_BITS-1:0] 
		{	HAS0,
			HAS1,
			HAS10,
			HAS101,
			HAS1011 } fsr_state;

	fsr_state next_state;
	fsr_state curr_state;
	logic next_o;

	// Store the state.
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == '0)
		begin
			curr_state = HAS0;
		end else
		begin
			curr_state = next_state;
		end
	end

	// Set the next state.
	always_comb
	begin
		next_state = HAS0;
		next_o = '0;
		case (curr_state)
			HAS0:
			begin
				if (i == 0)
				begin
					next_state = HAS0;
				end else // i == 1
				begin
					next_state = HAS1;
				end
			end
			HAS1:
			begin
				if (i == 0)
				begin
					next_state = HAS10;
				end else // i == 1
				begin
					next_state = HAS1;
				end
			end
			HAS10:
			begin
				if (i == 0)
				begin
					next_state = HAS0;
				end else // i == 1
				begin
					next_state = HAS101;
				end
			end
			HAS101:
			begin
				if (i == 0)
				begin
					next_state = HAS10;
				end else // i == 1
				begin
					next_state = HAS1011;
					next_o = '1;
				end
			end
			HAS1011:
			begin
				if (i == 0)
				begin
					next_state = HAS10;
				end else // i == 1
				begin
					next_state = HAS1;
				end
			end
		endcase
	end

	// store output value.
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == '0)
		begin
			o = 0;
		end else
		begin
			o = next_o;
		end
	end


endmodule
