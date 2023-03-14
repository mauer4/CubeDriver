module ConditionalPulse(
	input logic clk,
	input logic rst_n,
	input logic cond,
	output logic pulse
);

	always_ff @( posedge clk ) begin : pulse_logic
		if( ~rst_n ) pulse <= 0;
		else begin
			if(cond) pulse <= 1'b1;
			else pulse <= 1'b0;
		end
	end

endmodule : ConditionalPulse