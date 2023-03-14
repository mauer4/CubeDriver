//`define TB

`ifdef TB
	`define setup_time 4'hf
	`define latch_time 8'hf
	`define hold_time  12'hf
`else
	`define setup_time 4'h1
	`define latch_time 4'h2
	`define hold_time  4'h1
`endif


module Latcher(
	input logic clk,
	input logic rst_n,
	input logic [2:0] latch_i,
	input logic [7:0] data_in,
	input logic start,
	output logic [7:0] data_out,
	output logic [7:0] latch_out,
	output logic done
);

	enum {WAIT, SETUP, LATCH, HOLD} state, next_state;
	
	always_ff @( posedge clk ) begin : state_seq_logic
		if( ~rst_n ) state = WAIT;
		else state = next_state;
	end
	
	always_comb begin : next_state_comb_logic
		next_state = state;
		case(state)
			WAIT:  if(start) next_state = SETUP;	
			SETUP: next_state = LATCH;
			LATCH: next_state = HOLD;
			HOLD:  next_state = WAIT;
		endcase
	end
	
	assign done = (state == WAIT) ? 1'b1 : 1'b0;
	
	assign latch_out = (state == LATCH) ? 8'b1 << latch_i : 1'b0;
	
	assign data_out = (state != WAIT) ? data_in : 8'b0;
	
endmodule : Latcher