module sync_low
(
	input wire clk,
	input wire n_rst,
	input wire async_in,
	output reg sync_out
);

reg midline = 0; //Connector between flip-flops.

//first flip-flop
always_ff @ (posedge clk, negedge n_rst)
begin
	if (n_rst == 1'b0)
	begin
		midline = 1'b0;
	end
	else
	begin
		midline = async_in;
	end
end

//second flip-flop
always_ff @ (posedge clk, negedge n_rst)
begin
	if (n_rst == 1'b0)
	begin
		sync_out = 1'b0;
	end
	else
	begin
		sync_out = async_in;
	end
end

endmodule
