module LayerLatcher(
	input logic clk,
	input logic rst_n,
	input logic start,
	input logic [7:0] data_in,
	output logic [2:0] latch_i,
	output logic done,
	output logic [7:0] data_out,
	output logic [7:0] latch_out
);

	enum {WAIT, LATCH} state, next_state;
	
	logic start_latcher, latcher_done;
	
	always_ff @( posedge clk ) begin : done_block
		if( ~rst_n ) done <= 0;
		else if(next_state != state && next_state == WAIT) done <= 1;
		else if(done) done <= 0;
	end
//	
//	assign done = (state == WAIT) ? 1'b1 : 0;

	always_ff @( posedge clk ) begin : state_seq_logic
		if( ~rst_n ) state = WAIT;
		else state <= next_state;
	end
	
	always_comb begin : next_state_comb_block
		next_state = state;
		if(state == WAIT && start) next_state = LATCH;
		else if(state == LATCH && latch_i == 3'd7 && latcher_done) next_state = WAIT;
	end
	
	always_ff @( posedge clk ) begin : latch_i_block
		if( ~rst_n ) latch_i <= 0;
		else begin
			if(state == LATCH && latcher_done) latch_i <= latch_i + 1'b1;
		end
	end
		
	assign start_latcher = ((state == LATCH && latcher_done && latch_i != 3'd7) || (state == WAIT && start)) ? 1'b1 : 0;
	
	Latcher latcher(
		.clk(clk), 
		.rst_n(rst_n), 
		.start(start_latcher),
		.latch_i(latch_i),
		.data_in(data_in),  
		.data_out(data_out),
		.done(latcher_done), 
		.latch_out(latch_out)
	);	
	

endmodule : LayerLatcher