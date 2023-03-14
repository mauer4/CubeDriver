module single_frame_tb;

	logic clk_tb, clk2_tb, rst_tb, start_tb, stop_tb;
	
	LED_cube_multi_frame DUT(.CLOCK_50(clk_tb), .KEY({1'b0, stop_tb, start_tb, rst_tb}));
	
	initial begin
		clk_tb = 0;
		forever begin clk_tb = ~clk_tb; #5; end;
	end
	
	initial begin
		stop_tb = 1;
		rst_tb = 0;
		#10;
		rst_tb = 1;
		#10;
		rst_tb = 0;
		#20;
		rst_tb = 1;
		start_tb = 0;
		#10;
		start_tb = 1;
	end
endmodule : single_frame_tb