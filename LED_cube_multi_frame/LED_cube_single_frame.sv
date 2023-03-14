module LED_cube_single_frame(
	input logic clk,
	input logic rst_n,
	input logic start,
	input logic stop,
	input logic [7:0] data_to_latch,
	output logic [5:0] addr,
	output logic done,
	output logic [7:0] Layers, 
	output logic [7:0] Latches,
	output logic [7:0] Data
);
		
	
	
//	logic [63:0] [7:0] data = { 8'h81, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h81, 
//												8'h00, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h00, 
//												8'h00, 8'h00, 8'h24, 8'h18, 8'h18, 8'h24, 8'h00, 8'h00, 
//												8'h00, 8'h00, 8'h00, 8'h18, 8'h18, 8'h00, 8'h00, 8'h00, 
//												8'h00, 8'h00, 8'h00, 8'h18, 8'h18, 8'h00, 8'h00, 8'h00, 
//												8'h00, 8'h00, 8'h24, 8'h18, 8'h18, 8'h24, 8'h00, 8'h00, 
//												8'h00, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h00, 
//												8'h81, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h81  };
	
	logic [2:0] layer_i;
	logic [2:0] latch_i;
	assign addr = {layer_i, latch_i};
	
	logic layer_latcher_done, layer_driver_done, start_layer_latcher, start_layer_driver;

	enum bit[1:0] {WAIT, DRIVE, LOAD} state, next_state;
		
	assign done = (layer_latcher_done && layer_i == 3'd0) ? 1'b1 : 1'b0;
	 
	 always_ff @( posedge clk ) begin : state_seq_logic
		if( ~rst_n ) state = WAIT;
		else state <= next_state;
	 end
	 
	 always_comb begin : next_state_comb_block
		next_state = state;
		case(state)
			WAIT:  if(start) next_state = LOAD;
			LOAD:  if(layer_latcher_done) next_state = DRIVE;
			DRIVE: begin
				if(layer_driver_done) begin
					if(~stop) next_state = LOAD;
					else next_state = WAIT;
				end
			end
		endcase
	 end
	 
	 logic new_layer;
	 assign new_layer = (state == DRIVE) && (next_state == LOAD) ? 1'b1 : 1'b0;

	 always_ff @( posedge clk ) begin : layer_data_shift
		if( ~rst_n ) layer_i = 3'd7;
		else begin
			if( new_layer) layer_i <= layer_i - 1'b1;
		end
	 end

	 logic start_layer_latcher_cond;
	 assign start_layer_latcher_cond = ((state == DRIVE && next_state == LOAD) || start) ? 1'b1 : 1'b0;
	 
	 ConditionalPulse start_layer_latcher_pulse(
				.clk(clk), 
				.rst_n(rst_n), 
				.cond(start_layer_latcher_cond), 
				.pulse(start_layer_latcher)
	  );
	  
	  logic start_layer_driver_cond;
	  assign start_layer_driver_cond = (state == LOAD && next_state == DRIVE) ? 1'b1 : 1'b0;
	 
	  ConditionalPulse start_layer_driver_pulse(
				.clk(clk), 
				.rst_n(rst_n), 
				.cond(start_layer_driver_cond), 
				.pulse(start_layer_driver)
		);
		
	 LayerLatcher layer_latcher(
		.clk(clk), 
		.rst_n(rst_n), 
		.start(start_layer_latcher),
		.latch_i(latch_i),
		.data_in(data_to_latch),  
		.data_out(Data),
		.done(layer_latcher_done), 
		.latch_out(Latches)
	);	
	
	LayerActivator layer_activator(
		.clk(clk),
		.rst_n(rst_n),
		.start(start_layer_driver),
		.layer_i(layer_i),
		.done(layer_driver_done),
		.layer_out(Layers)
	);
	
	



endmodule : LED_cube_single_frame