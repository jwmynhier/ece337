

module decode_pro
(
	input logic clk,
	input logic nrst,
	input logic penable,
	input logic render_enable,
	input logic [31:0] command_bus,
	output wire [16:0] start,
	output wire [16:0] end1,
	output wire [23:0] color,
	output wire [2:0] op,
	output wire received_op,
	output wire flip_buffer
	

);

typedef enum logic [1:0] {IDLE, CHECK, WAIT_RENDER,PULSE_HI,SETSTART,START,PWAIT,SETEND,SETCOLOR,MOVESTART,MOVEEND,STARTC}
state_type;

state_type state, next_state;

reg [16:0] start;
reg [16:0] end1;
reg [23:0] color;
reg [2:0] op;
reg [31:0] commandreg;

reg received_op_next;
reg flip_buffer_next;

reg received_op_c;
reg flip_buffer_c;

reg [31:0] next_commandreg;
reg [16:0] next_start;
reg [16:0] next_end1;
reg [23:0] next_color;
reg [2:0] next_op;


always_ff @ (posedge clk, negedge n_rst)
 begin 
 if (n_rst == 0)
  begin
 	state <= IDLE;
	start <= 17b'0;
	end1 <= 17b'0;
	color <= 24b'0;
	op <= 3b'0;
	commandreg <= 32b'0;
	received_op_c <= 1b'0;
	flip_buffer_c <= 1b'0;
  end
 else
  begin
	state <= next_state;
	start <= next_start;
	end1 <= next_end1;
	color <= next_color;
	op <= next_op;
	received_op_c <= received_op_next;
	flip_buffer_c <= flip_buffer_next;
	commandreg <= next_commandreg;
  end
 end
	
//next state logic 
always_comb
begin
	// Set the default value(s)
	next_state = state;

	// Define the state transitions
	case(state)
		IDLE:
		begin
			if(1'b1 == penable)
			begin
				next_state = CHECK;
			end
		end
		
		CHECK:
		begin
			if(1'b1 == render_enable)
			begin
				if(command_bus[26:24] != 3'b111) //rendering and not flip
				begin
					next_state = PWAIT;
				end
			end

			if(1'b1 == render_enable)
			begin
				if(command_bus[26:24] == 3'b111) //rendering and flip
				begin
					next_state = WAIT_RENDER;
				end
			end

			if(1'b0 == render_enable)
			begin
				if(command_bus[26:24] == 3'b111) //not rendering and flip
				begin
					next_state = PULSE_HI;
				end
			end

			if(1'b0 == render_enable)
			begin
				if(command_bus[26:24] == 3'b110 ) //not rendering and drAW
				begin
					next_state = START;
				end
			end

			if(1'b0 == render_enable)
			begin
				if(command_bus[26:24] == 3'b000 ) //not rendering and clear
				begin
					next_state = STARTC;
				end
			end

			if(1'b0 == render_enable)
			begin
				if(command_bus[26:24] == 3'b001) //not rendering and set start
				begin
					next_state = SETSTART;
				end
			end

			if(1'b0 == render_enable)
			begin
				if(command_bus[26:24] == 3'b010) //not rendering and set start
				begin
					next_state = SETEND;
				end
			end

			if(1'b0 == render_enable)
			begin
				if(command_bus[26:24] == 3'b011) //not rendering and set start
				begin
					next_state = SETCOLOR;
				end
			end

			if(1'b0 == render_enable)
			begin
				if(command_bus[26:24] == 3'b100) //not rendering and set start
				begin
					next_state = MOVESTART;
				end
			end

			if(1'b0 == render_enable)
			begin
				if(command_bus[26:24] == 3'b101) //not rendering and set start
				begin
					next_state = MOVEEND;
				end
			end
				
		end

		PWAIT:
		begin
			if(penable == 1'b0)
			begin
				next_state = IDLE;
			end
		end

		WAIT_RENDER:
		begin
			if(render_enable == 1'b0)
			begin
				next_state = PULSE_HI;
			end
		end

		PULSE_HI:
		begin
			
				next_state = IDLE;
			
		end

		START:
		begin
			
				next_state = IDLE;
			
		end
		STARTC:
		begin
			
				next_state = IDLE;
			
		end
		SETSTART:
		begin
			
				next_state = IDLE;
			
		end
		SETEND:
		begin
			
				next_state = IDLE;
			
		end
		SETCOLOR:
		begin
			
				next_state = IDLE;
			
		end
		MOVESTART:
		begin
				next_state = IDLE;
		end
		MOVEEND:
		begin
				next_state = IDLE;
		end

	endcase
end

//output logic
always_comb
begin
	//default
	 next_start = start ;
	 next_end1 = end1 ;
	 next_color = color ;
	 next_op = op ;
	 received_op_next = 1b'0;
	 flip_buffer_next = 1b'0;
	 next_commandreg = commandreg;
	case(state)
		CHECK:
		begin
			next_commandreg = command_bus;
		end
		PULSE_HI:
		begin
			flip_buffer_next = 1b'1;
			next_op = 3b'111;
		end
		START:
		begin
			received_op_next = 1b'1;
			next_op = 3b'110;
		end
		STARTC:
		begin
			received_op_next = 1b'1;
			next_color = 24b'0; //assume this is white
			next_op = 3b'000;
		end
		SETSTART:
		begin
			
			next_start = commandreg[16:0]; 
			next_op = 3b'001;
		end
		SETEND:
		begin
			
			next_end1 = commandreg[16:0];
			next_op = 3b'010;
		end
		SETCOLOR:
		begin
			
			next_color = commandreg[23:0];
			next_op = 3b'011;
		end
		MOVESTART:
		begin
			next_start = start + commandreg[16:0];
			next_op = 3b'100;
		end
		MOVEEND:
		begin
			next_end1 = end1 + commandreg[16:0];
			next_op = 3b'101;
		end
		
	endcase
end

assign received_op = received_op_c; //output logic
assign flip_buffer = flip_buffer_c; 

endmodule
 