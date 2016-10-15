// $Id: mg111
// File name:   controller.sv
// Created:     10/6/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: controller for Lab 6

module rcu
(
	input clk,
	input n_rst,
	input d_edge,
	input eop,
	input shift_enable,
	input [7:0] rcv_data,
	input byte_received,
	output logic rcving,
	output logic w_enable,
	output logic r_error
);

	localparam SYNC_BYTE = 8'h80;

	typedef enum bit [5:0] 
	{
		IDLE,	RSYNC,	READ,	WRITE,	EIDLE,	ERR,
		EOP_CHECK1,	EOP_CHECK2,	EOP_CHECK3,
		ERR_EOP
	} state_type;
	
	state_type state;
	state_type next_state;

	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == '0)
		begin
			state <= IDLE;
		end else
		begin
			state <= next_state;
		end
	end

	// next state logic
	always_comb
	begin
		next_state = IDLE;
		case (state)
		IDLE:
		begin
			if (d_edge == '0)
			begin
				next_state = IDLE;
			end else
			begin
				next_state = RSYNC;
			end
		end
		RSYNC:	
		begin
			if (eop == '1)
			begin
				next_state = ERR_EOP;
			end else if (byte_received == '0)
			begin
				next_state = RSYNC;
			end else if (rcv_data == SYNC_BYTE)
			begin
				next_state = READ;
			end else 
			begin
				next_state = ERR;
			end
		end
		READ:	
		begin
			if (byte_received == '0 && eop == '0)
			begin
				next_state = READ;
			end else if (eop == '1)
			begin
				next_state = ERR_EOP;
			end else 
			begin
				next_state = WRITE;
			end
		end
		WRITE:	
		begin
			if (eop == '1)
			begin
				next_state = ERR_EOP;
			end else
			begin
				next_state = EOP_CHECK1;
			end
		end
		EIDLE:	
		begin
			if (d_edge == '0)
			begin
				next_state = EIDLE;
			end else
			begin
				next_state = RSYNC;
			end
		end
		ERR:	
		begin
			if (eop == '0)
			begin
				next_state = ERR;
			end else
			begin
				next_state = ERR_EOP;
			end
		end
		EOP_CHECK1:
		begin
			if (shift_enable == '0)
			begin
				next_state = EOP_CHECK1;
			end else if (eop == '1)
			begin
				next_state = EOP_CHECK2;
			end else
			begin
				next_state = READ;
			end
		end
		EOP_CHECK2:
		begin
			if (shift_enable == '0)
			begin
				next_state = EOP_CHECK2;
			end else if (eop == '1)
			begin
				next_state = EOP_CHECK3;
			end else
			begin
				next_state = ERR;
			end
		end
		EOP_CHECK3:
		begin
			if (d_edge == '0)
			begin
				next_state = EOP_CHECK3;
			end else
			begin
				next_state = IDLE;
			end
		end
		ERR_EOP:
		begin
			if (eop == '1)
			begin
				next_state = ERR_EOP;
			end else if (d_edge == '0)
			begin
				next_state = ERR_EOP;
			end else
			begin
				next_state = EIDLE;
			end
		end
		endcase
	end

	// output logic
	always_comb
	begin
		rcving = '0;
		w_enable = '0;
		r_error = '0;

		case (state)
		IDLE:
		begin
		end
		RSYNC:	
		begin
			rcving = '1;
		end
		READ:	
		begin
			rcving = '1;
		end
		WRITE:	
		begin
			rcving = '1;
			w_enable = '1;
		end
		EIDLE:	
		begin
			r_error = '1;
		end
		ERR:	
		begin
			rcving = '1;
			r_error = '1;
		end
		EOP_CHECK1:	
		begin
			rcving = '1;
		end
		EOP_CHECK2:	
		begin
			rcving = '1;
		end
		EOP_CHECK3:	
		begin
			rcving = '1;
		end
		ERR_EOP:
		begin
			r_error = '1;
			rcving = '1;
		end
		endcase
	end


endmodule
