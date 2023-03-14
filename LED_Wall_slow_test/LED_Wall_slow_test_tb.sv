module slow_test_tb;

	logic clk_tb, clk2_tb, rst_tb;
	
	LED_Wall_slow_test DUT(.CLOCK_50(clk_tb), .KEY({3'b0, rst_tb}));
	
	initial begin
		clk_tb = 0;
		forever begin clk_tb = ~clk_tb; #5; end;
	end
	
	initial begin
		rst_tb = 0;
		#10;
		rst_tb = 1;
		#10;
		rst_tb = 0;
		#20;
		rst_tb = 1;
	end
	
endmodule : slow_test_tb