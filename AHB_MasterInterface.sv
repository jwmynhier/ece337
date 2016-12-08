//AHB master implementation for Memory Manger module within the '2D-GPU' ECE 337 project
//12/2/16 - Dwezil D'souza 

`include "ahb_if.vh"

module AHB_MasterInterface(
	ahb_if.ahb_m ahb,
	input logic hclk,
	input logic n_rst,
	input logic [31:0] pixel_address,
	input logic [31:0] color_data,
	input logic write_enable
);

//check syntax
typedef enum bit [1:0]{
	IDLE,ADDR,DATA
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
			if(1'b1 == write_enable)
			begin
				next_state = ADDR;
			end
		end
		
		ADDR:
		begin
			next_state = DATA;
		end

		DATA:
		begin
			if(1'b1 == ahb.HREADY)
			begin
				next_state = IDLE;
			end
		end
	endcase
end

//state reg 
always@(negedge n_rst, posedge hclk)
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
	ahb.HWDATA = '0;
	ahb.HADDR = '0;	
	ahb.HWRITE = 1'b1;

	case(state)
		ADDR:
		begin
			ahb.HADDR = pixel_address;
			ahb.HWRITE = 1'b1;
		end
		
		DATA:
		begin
			ahb.HWDATA = color_data;
		end
	endcase

end
endmodule
