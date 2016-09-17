// $Id: mg111
// File name:   mealy.sv
// Created:     9/16/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: mealy model 1101 sequence detector.

module mealy
(
	input wire clk,
	input wire n_rst,
	input wire i,
	output reg o
);
	localparam NUM_STATE_BITS = 2;
	typedef enum logic [NUM_STATE_BITS-1:0] 
		{	DFLT,
			HAS1,
			HAS11,
			HAS110 } fsr_state;

	fsr_state next_state;
	fsr_state curr_state;
	//logic next_o;

	// Store the state.
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == '0)
		begin
			curr_state = DFLT;
		end else
		begin
			curr_state = next_state;
		end
	end

	// Set the next state.
	always_comb
	begin
		next_state = DFLT;
		case (curr_state)
			DFLT:
			begin
				if (i == 0)
				begin
					next_state = DFLT;
				end else // i == 1
				begin
					next_state = HAS1;
				end
			end
			HAS1:
			begin
				if (i == 0)
				begin
					next_state = DFLT;
				end else // i == 1
				begin
					next_state = HAS11;
				end
			end
			HAS11:
			begin
				if (i == 0)
				begin
					next_state = HAS110;
				end else // i == 1
				begin
					next_state = HAS11;
				end
			end
			HAS110:
			begin
				next_state = DFLT;
			end
		endcase
	end

	// store output value.
	//always_ff @ (posedge clk, negedge n_rst)
	//begin
//		if (n_rst == '0)
//		begin
//			o = 0;
//		end else
//		begin
//			o = next_o;
//		end
//	end



	always_comb
	begin
		o = 1'b0;
		if ((curr_state == HAS110) && (i == 1))
			o = 1'b1;

	end

endmodule
