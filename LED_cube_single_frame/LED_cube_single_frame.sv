module LED_cube_single_frame(
	input logic CLOCK_50,
	input logic [3:0] KEY,
	input logic [9:0] SW,
//	input logic start,
//	input logic stop,
	output logic [9:0] LEDR,
	output logic [35:0] GPIO_0 
);


	logic clk, rst_n;
	assign clk = CLOCK_50;
	assign rst_n = KEY[0];
		
	logic [7:0] Layers, Latches, Data;
	assign {GPIO_0[32], GPIO_0[30], GPIO_0[28], GPIO_0[26], GPIO_0[35], GPIO_0[33], GPIO_0[31], GPIO_0[27]} = Layers;
	assign {GPIO_0[25], GPIO_0[7], GPIO_0[9], GPIO_0[13], GPIO_0[15], GPIO_0[19], GPIO_0[21], GPIO_0[23]} = Latches;
	assign {GPIO_0[2], GPIO_0[4], GPIO_0[6], GPIO_0[10], GPIO_0[12], GPIO_0[16], GPIO_0[18], GPIO_0[20]} = Data;
	
	logic [63:0] [7:0] data = { 8'h81, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h81, 
												8'h00, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h00, 
												8'h00, 8'h00, 8'h24, 8'h18, 8'h18, 8'h24, 8'h00, 8'h00, 
												8'h00, 8'h00, 8'h00, 8'h18, 8'h18, 8'h00, 8'h00, 8'h00, 
												8'h00, 8'h00, 8'h00, 8'h18, 8'h18, 8'h00, 8'h00, 8'h00, 
												8'h00, 8'h00, 8'h24, 8'h18, 8'h18, 8'h24, 8'h00, 8'h00, 
												8'h00, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h00, 
												8'h81, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h81  };
												
	logic start, stop;
	assign start = ~KEY[1];
	assign stop = ~KEY[2];
	
	logic [2:0] layer_i;
	logic [2:0] latch_i;
	
	logic layer_latcher_done, layer_driver_done, start_layer_latcher, start_layer_driver;
	
	logic [7:0] data_to_latch;

	enum {WAIT, DRIVE, LOAD} state, next_state;
	
	always_comb begin : LEDR_Debug_block
		case( SW[9:8] )
			2'b00: LEDR = Data;
			2'b01: LEDR = Latches;
			2'b10: LEDR = Layers;
			2'b11: begin
				case(state)
					WAIT: LEDR = 10'b00;
					LOAD: LEDR = 10'b01;
					DRIVE:LEDR = 10'b10;
					default: LEDR = 10'b00;
				endcase
			end
		endcase
	end
	 
	 always_ff @( posedge clk ) begin : state_seq_logic
		if( ~rst_n ) state = WAIT;
		else state = next_state;
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
	 assign new_layer = (state == DRIVE) && (next_state == LOAD) ? 1'b1 : 0;

	 always_ff @( posedge clk ) begin : layer_data_shift
		if( ~rst_n ) layer_i = 3'd7;
		else begin
			if( new_layer) layer_i <= layer_i - 1'b1;
		end
	 end
	 
	 assign data_to_latch = data[{layer_i,latch_i}];

	 logic start_layer_latcher_cond;
	 assign start_layer_latcher_cond = ((next_state == LOAD && state != next_state) || start) ? 1'b1 : 0;
	 
	 ConditionalPulse start_layer_latcher_pulse(
				.clk(clk), 
				.rst_n(rst_n), 
				.cond(start_layer_latcher_cond), 
				.pulse(start_layer_latcher)
	  );
	  
	  logic start_layer_driver_cond;
	  assign start_layer_driver_cond = (next_state == DRIVE && state != next_state) ? 1'b1 : 0;
	 
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