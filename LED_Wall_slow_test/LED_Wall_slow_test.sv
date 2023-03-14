//`define sw_testing

module LED_Wall_slow_test(
	input logic CLOCK_50,
	input logic [3:0] KEY,
	input logic [9:0] SW,
	output logic [9:0] LEDR,
	output logic [35:0] GPIO_0 );
		
	logic clk, rst_n;
	assign clk = CLOCK_50;
	assign rst_n = KEY[0];
		
	logic [7:0] Layers, Latches, Data;
	assign {GPIO_0[32], GPIO_0[30], GPIO_0[28], GPIO_0[26], GPIO_0[35], GPIO_0[33], GPIO_0[31], GPIO_0[27]} = Layers;
	assign {GPIO_0[25], GPIO_0[7], GPIO_0[9], GPIO_0[13], GPIO_0[15], GPIO_0[19], GPIO_0[21], GPIO_0[23]} = Latches;
	assign {GPIO_0[2], GPIO_0[4], GPIO_0[6], GPIO_0[10], GPIO_0[12], GPIO_0[16], GPIO_0[18], GPIO_0[20]} = Data;
	assign GPIO_0[1] = GPIO_0[3];
	
	logic [7:0] [7:0] data = {8'h81, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h81};
	
	logic [2:0] layer_i;
//	assign layer_i = 3'd7;
	
	logic [2:0] latch_i;
	assign latch_i = 3'd7;
	
	logic latcher_done, layer_done, start_latcher, start_layer;
	
	logic [7:0] data_to_latch;

	enum {drive, load} state, next_state;
	
	logic CLOCK_25;
	
	always_comb begin : LEDR_Debug_block
		case( SW[9:8] )
			2'b00: LEDR = Data;
			2'b01: LEDR = Latches;
			2'b10: LEDR = Layers;
			2'b11: LEDR = (state == load) ? 10'h3f0 : 0;
		endcase
	end
	
    always_ff @( posedge clk ) begin : CLOCK_25_block
			if( ~rst_n) CLOCK_25 <= 0;
         else CLOCK_25 <= (CLOCK_25 ^ clk);
    end
	 
	 always_ff @( posedge clk ) begin : state_seq_logic
		if( ~rst_n ) state = load;
		else state = next_state;
	 end
	 
	 always_comb begin : next_state_comb_block
		next_state = state;
		case(state)
			load:  if(latcher_done) next_state = drive;
			drive: if(layer_done)   next_state = load;
		endcase
	 end
	 
	 logic new_layer;
	 assign new_layer = (state == drive) && (next_state == load) ? 1'b1 : 0;
	 logic new_data;
	 assign new_data = (state == load) && (next_state == drive) ? 1'b1 : 0;
	
	
	 always_ff @( posedge clk ) begin : layer_data_shift
		if( ~rst_n ) layer_i = 3'd7;
		else begin
			if( new_layer) layer_i <= layer_i - 1'b1;
		end
	 end
	 
	 assign data_to_latch = data[3'd7 - layer_i]; 
	 
	`ifdef sw_testing
		assign Layers = 8'h80;
		assign layer_done = 1'b1;
	`endif
	
	`ifdef sw_testing
		assign data_to_latch = SW[7:0];
		assign start_latcher = ~KEY[1];
		assign start_layer   = ~KEY[2];
	`else
		assign start_latcher = (next_state == load) ?  1'b1 : 1'b0;
		assign start_layer   = (next_state == drive) ? 1'b1 : 1'b0;
//		assign data_to_latch = 8'h3a;
	 `endif
	 
	 Latcher latcher(
		.clk(clk), 
		.rst_n(rst_n), 
		.start(start_latcher),
		.latch_i(latch_i),
		.data_in(data_to_latch),  
		.data_out(Data),
		.done(latcher_done), 
		.latch_out(Latches)
	);	
	
	LayerActivator layer_activator(
		.clk(clk),
		.rst_n(rst_n),
		.start(start_layer),
		.layer_i(layer_i),
		.done(layer_done),
		.layer_out(Layers)
	);
	
	

endmodule : LED_Wall_slow_test