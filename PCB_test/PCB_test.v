module PCB_test(
	input [9:0] SW,
	input [1:0] KEY,
	output [9:0] LEDR, 
	output [35:0] GPIO_0);
	
	reg [7:0] Layers, Latches, Data;
	assign {GPIO_0[32], GPIO_0[30], GPIO_0[28], GPIO_0[26], GPIO_0[35], GPIO_0[33], GPIO_0[31], GPIO_0[27]} = Layers;
	assign {GPIO_0[25], GPIO_0[7], GPIO_0[9], GPIO_0[13], GPIO_0[15], GPIO_0[19], GPIO_0[21], GPIO_0[23]} = Latches;
	assign {GPIO_0[2], GPIO_0[4], GPIO_0[6], GPIO_0[10], GPIO_0[12], GPIO_0[16], GPIO_0[18], GPIO_0[20]} = Data;
	assign GPIO_0[1] = GPIO_0[3];
	
	assign LEDR = SW;
	
	always @(negedge KEY[1]) begin
		if(~KEY[0])
			{Layers, Latches, Data} = 0;
		else begin
			case(SW[9:8])
				2'b00: Layers <= SW[7:0];
				2'b01: Latches <= SW[7:0];
				2'b10: Data <= SW[7:0];
			endcase
		end		
	end
	

endmodule 