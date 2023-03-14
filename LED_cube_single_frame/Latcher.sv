//`define TB

`ifdef TB
	`define setup_time 4'hf
	`define latch_time 8'hf
	`define hold_time  12'hf
`else
	`define setup_time 4'h1
	`define latch_time 4'h1
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
	
	logic [3:0] counter;
	
	always_ff @( posedge clk ) begin
		if( ~rst_n ) counter <= 0;
		else if(state != WAIT) counter <= (counter == 4'h4) ? 0 : counter + 1'b1;
	end
	
	always_ff @( posedge clk ) begin : state_seq_logic
		if( ~rst_n ) state = WAIT;
		else state = next_state;
	end
	
	always_comb begin : next_state_comb_logic
		next_state = state;
		case(state)
			WAIT:  if(start) next_state = SETUP;	
			SETUP: if(counter == `setup_time) next_state = LATCH;
			LATCH: if(counter == `setup_time + `latch_time) next_state = HOLD;
			HOLD:  if(counter == `setup_time + `latch_time + `hold_time) next_state = WAIT;
		endcase
	end
	
	logic done_cond;
	assign done_cond	= (next_state != state && next_state == WAIT) ? 1'b1 : 0;
	
	always_ff @( posedge clk ) begin : done_block
		if( ~rst_n ) done <= 0;
		else if (done_cond) done <= 1;
		else if(done) done <= 0;
	end
	
//	
	
//	assign done = (state == WAIT) ? 1'b1 : 1'b0;
	
	assign latch_out = (state == LATCH) ? 8'b1 << latch_i : 1'b0;
	
	assign data_out = (state != WAIT) ? data_in : 8'b0;
	
endmodule : Latcher