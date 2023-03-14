`define TB

`ifdef TB
	`define frame_time 21'd8
`else 
	`define frame_time 21'b101101110001101100000
`endif
	
	
module LED_cube_multi_frame(
	input logic CLOCK_50,
	input logic [3:0] KEY,
	input logic [9:0] SW,
	output logic [9:0] LEDR,
	output logic [35:0] GPIO_0
);

	logic clk, rst_n;
	assign clk = CLOCK_50;
	assign rst_n = KEY[0];
	
	logic animate_start, frame_stop, frame_done;
	logic [7:0] data_to_latch;
	logic [5:0] frame_addr;
	logic [7:0] offset;
	logic [20:0] frame_timer, next_frame_timer;
	
	
	assign animate_start = ~KEY[1];
	assign frame_stop  = ~KEY[2];
	
	logic [7:0] Layers, Latches, Data;
	assign {GPIO_0[32], GPIO_0[30], GPIO_0[28], GPIO_0[26], GPIO_0[35], GPIO_0[33], GPIO_0[31], GPIO_0[27]} = Layers;
	assign {GPIO_0[25], GPIO_0[7], GPIO_0[9], GPIO_0[13], GPIO_0[15], GPIO_0[19], GPIO_0[21], GPIO_0[23]} = Latches;
	assign {GPIO_0[2], GPIO_0[4], GPIO_0[6], GPIO_0[10], GPIO_0[12], GPIO_0[16], GPIO_0[18], GPIO_0[20]} = Data;

	enum bit[1:0] {WAIT, DRIVE_FRAME, NEXT_FRAME} state, next_state;
	
	logic [63:0] [7:0] data = { 8'h81, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h81, 
											8'h00, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h00, 
											8'h00, 8'h00, 8'h24, 8'h18, 8'h18, 8'h24, 8'h00, 8'h00, 
											8'h00, 8'h00, 8'h00, 8'h18, 8'h18, 8'h00, 8'h00, 8'h00, 
											8'h00, 8'h00, 8'h00, 8'h18, 8'h18, 8'h00, 8'h00, 8'h00, 
											8'h00, 8'h00, 8'h24, 8'h18, 8'h18, 8'h24, 8'h00, 8'h00, 
											8'h00, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h00, 
											8'h81, 8'h42, 8'h24, 8'h18, 8'h18, 8'h24, 8'h42, 8'h81  };

//	logic [7:0] data [9599:0];
	initial begin
	$readmemh("animation_wave.hex", data);
	end

	logic timer_done;
	assign timer_done	= (frame_timer == `frame_time) ? 1'b1 : 1'b0;
	
	always_ff @( posedge clk ) begin : state_seq_logic
		if( ~rst_n ) state <= WAIT;
		else begin
			state <= next_state;
		end	
	end
	
	always_comb begin : next_state_logic
		next_state = state;
		if(frame_stop) next_state = WAIT;
		else begin
			case(state)
				WAIT: if(animate_start) next_state = DRIVE_FRAME;
				DRIVE_FRAME: if(timer_done) next_state = NEXT_FRAME;
				NEXT_FRAME: next_state = DRIVE_FRAME;
			endcase
		end
	end
	
	always_ff @( posedge clk ) begin : offset_logic
		if( ~rst_n ) offset <= 8'b0;
		else if(timer_done) begin
			if(frame_addr == 6'd7) offset <= offset + 8'b1;
			else offset <= offset + 1'b1;
		end
	end
	
	always_ff @( posedge clk ) begin : frame_timer_logic
		if( ~rst_n ) frame_timer <= 21'b0;
		else begin
			if(state == DRIVE_FRAME) begin
				frame_timer <= next_frame_timer;
			end
		end
	end
	
	always_comb begin : frame_timer_next_comb_block
		if(timer_done) begin
			if(state == DRIVE_FRAME) next_frame_timer = frame_timer;
			else if(state == NEXT_FRAME) next_frame_timer = 21'b0;
		end 
		else begin
			next_frame_timer = frame_timer + 1'b1;
		end
	end
	
	logic [15:0] addr;
	assign addr = {offset, frame_addr};
	
	assign data_to_latch = data[addr];
	

	

	always_comb begin : LEDR_Debug_block
		case( SW[9:8] )
			2'b00: LEDR = Data;
			2'b01: LEDR = Latches;
			2'b10: LEDR = Layers;
			2'b11: begin
				case(state)
					WAIT: LEDR = 10'b00;
					DRIVE_FRAME: LEDR = 10'b01;
					default: LEDR = 10'b00;
				endcase
			end
		endcase
	end

							
	LED_cube_single_frame frame_drive(
		.clk(clk),
		.rst_n(rst_n),
		.start(animate_start),
		.stop(frame_stop),
		.done(frame_done),
		.addr(frame_addr),
		.data_to_latch(data_to_latch),
		.Layers(Layers),
		.Latches(Latches),
		.Data(Data)
	);

endmodule : LED_cube_multi_frame