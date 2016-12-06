//APB slave implementation for  '2D-GPU' ECE 337 project
//12/6/16 - Nithin V

`include "apb_if.vh"

module APB_SlaveInterface(
	apb_if.apb_s apb,
	input logic pclk,
	input logic n_rst,
	input logic status_value,
	output logic [31:0] command_bus,
	output logic penable
);

//check syntax
typedef enum bit [1:0]{
	IDLE,WRITE,READ
}stateType;

stateType state, next_state;

//next state logic 
always_comb
begin
	// Set the default value(s)
	next_state = state;

	// Define the state transitions
	case(state)
		IDLE:
		begin
			if(1'b1 == apb.PSEL)
			begin
				if(1'b1 == apb.PWRITE)
				begin
					next_state = WRITE;
				end
				else
				begin
					next_state = READ;
				end
				
			end
		end
		
		WRITE:
		begin
			if(1'b0 == apb.PSEL)
			begin
				next_state = IDLE;
			end
				
		end

		READ:
		begin
			if(1'b0 == apb.PSEL)
			begin
				next_state = IDLE;
			end
		end
	endcase
end

//state reg 
always@(negedge n_rst, posedge pclk)
begin
	if(n_rst == 1'b0)
	begin
		state <= IDLE;
	end
	else
	begin
			state <= next_state;
	end
end

//output logic
always_comb
begin
	//default
	penable = apb.PENABLE;

	case(state)
		READ:
		begin
			
			apb.PRDATA = {32{status_value}};
		end
		WRITE:
		begin
			command_bus = apb.PWDATA;
			
		end
	endcase
end

endmodule

