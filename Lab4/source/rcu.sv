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
	input packet_done,
	input framing_error,
	output logic sbc_clear,
	output logic sbc_enable,
	output logic load_buffer,
	output logic enable_timer
);


	typedef enum bit [2:0] {
			WAIT,
			CLEAR,
			READ,
			CHECK_START,
			CHECK_FINISH} state_type;

	state_type state;
	state_type next_state;

	// State register
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == 0)
		begin
			state <= WAIT;
		end else
		begin
			state <= next_state;
		end
	end

	// Next state logic 
	always_comb
	begin
		next_state = state;
		case(state)
		WAIT:
		begin
			if (start_bit_detected == '0)
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
				next_state = CHECK_START;
			end
		end
		CHECK_START:
		begin
			next_state = CHECK_FINISH;
		end
		CHECK_FINISH:
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
		enable_timer = '0;

		if (state == CLEAR)
		begin
			sbc_clear = '1;
		end else if (state == READ)
		begin
			enable_timer = '1;
		end else if (state == CHECK_START)
		begin
			sbc_enable = '1;
		end else if (state == CHECK_FINISH)
		begin
			if (framing_error == '0)
			begin
				load_buffer = '1;
			end
		end 
	end

endmodule
