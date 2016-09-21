// $Id: mg111
// File name:   rcu.sv
// Created:     9/20/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: FSM for the UART design.

module rcu
(
	input clk,
	input n_rst,
	input start_bit_detected,
	input packet_done
	input framing_error,
	output sbc_clear,
	output sbc_enable,
	output load_buffer,
	output enable_timer
);


	typedef enum [2:0] {
			WAIT,
			CLEAR,
			READ,
			CHECK,
			LOAD} state_type;

	state_type state;
	state_type next_state;

	// State register
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == 0)
		begin
			state <= '0;
		end else
		begin
			state <= next_state;
		end
	end

	// Next state logic 
	always
	begin
		next_state = state;
		case(state)
		WAIT:
		begin
			if (state_bit_detected == '0)
			begin
				next_state = WAIT;
			end else
			begin
				next_state = CLEAR;
			end
		end
		CLEAR:
		begin
			next_state = READ;
		end
		READ:
		begin
			if (packet_done == '0)
			begin
				next_state = READ;
			end else
			begin
				next_state = CHECK;
			end
		end
		CHECK:
		begin
			if (framing_error == '0)
			begin
				next_state = LOAD;
			end else
			begin
				next_state = WAIT;
			end
		end
		LOAD:
		begin
			next_state = WAIT;
		end		
		endcase
	end

	// Ouptut logic.
	always_comb
	begin
		sbc_clear = '0;
		sbc_enable = '0;
		load_buffer = '0;
		enable timer = '0;

		if (state == CLEAR)
		begin
			sbc_clear = '1;
		end else if (state == READ)
		begin
			enable_timer = '1;
		end else if (state == CHECK)
		begin
			sbc_enable = '1;
		end else if (state == LOAD)
		begin
			load_buffer = '1;
		end 
	end

endmodule
