`define TB

`ifdef TB
	`define layer_hold_time 3'b100
`else
	`define layer_hold_time 12'b101101110001
`endif

module LayerActivator(
	input logic clk,
	input logic rst_n, 
	input logic start,
	input logic [2:0] layer_i,
	output logic done,
	output logic [7:0] layer_out
);

	logic [11:0] layer_counter;
	
	logic counter_done;
	assign counter_done = (layer_counter == `layer_hold_time) ? 1'b1 : 1'b0;

	enum bit[1:0] {WAIT, ACTIVATE} state, next_state;
	
	always_ff @(posedge clk) begin : state_seq_logic
		if( ~rst_n ) state <= WAIT;
		else state <= next_state;
	end
	
	always_comb begin : next_state_comb_block
		next_state = state;
		if(state == WAIT && start) next_state = ACTIVATE;
		else if(counter_done) next_state = WAIT;
	end
	
	always_ff @( posedge clk ) begin : done_block
		if( ~rst_n ) done <= 0;
		else if(counter_done) done <= 1;
		else if(done) done <= 0;
	end
//	
	
//	assign done = (state == WAIT) ? 1'b1 : 1'b0;
	
	assign layer_out = (state == ACTIVATE) ? 8'b1 << layer_i : 8'b0;
	
	always_ff @( posedge clk ) begin :layer_counter_block
		if( ~rst_n ) layer_counter <= 0;
		else begin 
			if(state == WAIT) layer_counter <= 0;
			else layer_counter <= layer_counter + 1'b1;
		end
	end
	
endmodule : LayerActivator