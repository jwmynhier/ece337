// $Id: mg111
// File name:   controller.sv
// Created:     9/27/2016
// Author:      Joseph Mynhier
// Lab Section: 4
// Version:     1.0  Initial Design Entry
// Description: controller for Lab 5

module controller
(
	input clk,
	input n_reset,
	input dr,
	input lc,
	input overflow,
	output logic cnt_up,
	output logic clear,
	output logic modwait,
	output logic [2:0] op,
	output logic [3:0] src1,
	output logic [3:0] src2,
	output logic [3:0] dest,
	output logic err
);

	typedef enum bit [4:0] {
		IDLE,	STORE,	ZERO,	SORT1,	SORT2,	SORT3,
		SORT4,	MUL1,	ADD1,	MUL2,	SUB1,	MUL3,
		ADD2,	MUL4,	SUB2,	EIDLE,	LOADF0,	WAITF1,
		LOADF1,	WAITF2,	LOADF2,	WAITF3,	LOADF3 } state_type;
	
	state_type state;
	state_type next_state;

	always_ff @ (posedge clk, negedge n_reset)
	begin
		if (n_reset == '0)
		begin
			state <= IDLE;
		end else
		begin
			state <= next_state;
		end
	end

	logic next_modwait;

	// Op states
	localparam [2:0] NoOp = 	3'b000;
	localparam [2:0] Copy = 	3'b001;
	localparam [2:0] Load1 =	3'b010;
	localparam [2:0] Load2  =	3'b011;
	localparam [2:0] Add = 		3'b100;
	localparam [2:0] Sub = 		3'b101;
	localparam [2:0] Mul = 		3'b110;

	// Memory Locations
	localparam [3:0] Disp =		4'd0;
	localparam [3:0] DataNew =	4'd5;
	localparam [3:0] Data0 =	4'd4;
	localparam [3:0] Data1 =	4'd3;
	localparam [3:0] Data2 =	4'd2;
	localparam [3:0] Data3 =	4'd1;
	localparam [3:0] Coef0 =	4'd9;
	localparam [3:0] Coef1 =	4'd8;
	localparam [3:0] Coef2 =	4'd7;
	localparam [3:0] Coef3 =	4'd6;
	localparam [3:0] Temp =		4'd10;


	always_comb
	begin

		next_modwait = '0;
		next_state = IDLE;
		clear = '0;
		cnt_up = '0;
		err = '0;
		src1 = '0;
		src2 = '0;
		dest = '0;
		op = '0;

		case (state)
		IDLE:
		begin
			if (dr == '0 && lc == '0)
			begin
				next_state = IDLE;
			end else if (lc == '1)
			begin
				next_state = LOADF0;
				next_modwait = '1;
			end else if (dr == '1)
			begin
				next_state = STORE;
				next_modwait = '1;
			end
		end
		STORE:	
		begin
			op = Load1;
			dest = DataNew;
			
			if (dr == '0)
			begin
				next_state = EIDLE;
				next_modwait = '0;
			end else
			begin
				next_state = ZERO;
				next_modwait = '1;
			end
		end
		ZERO:	
		begin
			op = Sub;
			dest = Disp;
			src1 = Disp;
			src2 = Disp;
			next_modwait = '1;
			cnt_up = '1;
			next_state = SORT1;
		end
		SORT1:	
		begin
			op = Copy;
			dest = Data0;
			src1 = Data1;
			next_modwait = '1;
			next_state = SORT2;
		end
		SORT2:	
		begin
			op = Copy;
			dest = Data1;
			src1 = Data2;
			next_modwait = '1;
			next_state = SORT3;
		end
		SORT3:
		begin
			op = Copy;
			dest = Data2;
			src1 = Data3;
			next_modwait = '1;
			next_state = SORT4;
		end
		SORT4:
		begin
			op = Copy;
			dest = Data3;
			src1 = DataNew;
			next_modwait = '1;
			next_state = MUL1;
		end
		MUL1:	
		begin
			op = Mul;
			dest = Temp;
			src1 = Data3;
			src2 = Coef3;
			next_modwait = '1;
			next_state = ADD1;
		end
		ADD1:	
		begin
			op = Add;
			dest = Disp;
			src1 = Disp;
			src2 = Temp;
			next_modwait = '1;
			if (overflow == '1)
			begin
				next_state = EIDLE;
			end else
			begin
				next_state = MUL2;
			end
		end
		MUL2:	
		begin
			op = Mul;
			dest = Temp;
			src1 = Data2;
			src2 = Coef2;
			next_modwait = '1;
			next_state = SUB1;
		end
		SUB1:	
		begin
			op = Sub;
			dest = Disp;
			src1 = Disp;
			src2 = Temp;
			next_modwait = '1;
			if (overflow == '1)
			begin
				next_state = EIDLE;
			end else
			begin
				next_state = MUL3;
			end
		end
		MUL3:
		begin
			op = Mul;
			dest = Temp;
			src1 = Data1;
			src2 = Coef1;
			next_modwait = '1;
			next_state = ADD2;
		end
		ADD2:	
		begin
			op = Add;
			dest = Disp;
			src1 = Disp;
			src2 = Temp;
			next_modwait = '1;
			if (overflow == '1)
			begin
				next_state = EIDLE;
			end else
			begin
				next_state = MUL4;
			end
		end
		MUL4:	
		begin
			op = Mul;
			dest = Temp;
			src1 = Data0;
			src2 = Coef0;
			next_modwait = '1;
			next_state = SUB2;
		end
		SUB2:	
		begin
			op = Sub;
			dest = Disp;
			src1 = Disp;
			src2 = Temp;
			next_modwait = '0;
			if (overflow == '1)
			begin
				next_state = EIDLE;
			end else
			begin
				next_state = IDLE;
			end
		end
		EIDLE:	
		begin
			err = '1;
			if (dr == '0)
			begin
				next_state = EIDLE;
				next_modwait = '0;
			end else
			begin
				next_state = STORE;
				next_modwait = '1;
			end
		end
		LOADF0:	
		begin
			op = Load2;
			next_modwait = '0;
			dest = Coef0;
			clear = 1;
			next_state = WAITF1;			
		end
		WAITF1:
		begin
			if (lc == '0)
			begin
				next_state = WAITF1;
				next_modwait = '0;
			end else
			begin
				next_state = LOADF1;
				next_modwait = '1;
			end
		end
		LOADF1:	
		begin
			op = Load2;
			next_modwait = '0;
			dest = Coef1;
			next_state = WAITF2;	
		end
		WAITF2:	
		begin
			if (lc == '0)
			begin
				next_state = WAITF2;
				next_modwait = '0;
			end else
			begin
				next_state = LOADF2;
				next_modwait = '1;
			end
		end
		LOADF2:	
		begin
			op = Load2;
			next_modwait = '0;
			dest = Coef2;
			next_state = WAITF3;	
		end
		WAITF3:	
		begin
			if (lc == '0)
			begin
				next_state = WAITF3;
				next_modwait = '0;
			end else
			begin
				next_state = LOADF3;
				next_modwait = '1;
			end
		end
		LOADF3:
		begin
			op = Load2;
			next_modwait = '0;
			dest = Coef3;
			next_state = IDLE;	
		end
		endcase
	end

	always_ff @ (posedge clk, negedge n_reset)
	begin
		if (n_reset == 0)
		begin
			modwait <= '0;
		end else
		begin
			modwait <= next_modwait;
		end
	end

endmodule
