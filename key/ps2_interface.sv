module chipInterface(

	input bit PS2_KBCLK,
	input bit PS2_KBDAT,
	input bit CLOCK_50,
	input bit KEY[0],
	input bit SW[0],
	output bit [17:0] LEDR,
	output bit [4:0]  GPIO);

	bit [7:0] led_reg, ascii;
	bit parity_error_reg;
	bit rdy_reg;
	bit rst_l;
	bit sel;
	bit rdyToPrint;
	bit doneFromPrinter;

	assign rst_l = KEY[0];
	assign sel = SW[0];

	keyboard key (.clk_k(PS2_KBCLK), .data(PS2_KBDAT), .led(led_reg), 
			.parity_error(parity_error_reg), .rdy(rdy_reg));
			
   decoder dec (.clk(CLOCK_50), .reset_l(KEY[0]), .led_de(led_reg), .doneFromPrinter(doneFromPrinter),
	             .rdyFromKey(rdy_reg), .rdyToPrint(rdyToPrint), .ascii(ascii));
					 
   print_control print (.clk(CLOCK_50), .rst_l(KEY[0]), .rdy(rdyToPrint), .ascii(ascii),
	                     .done(doneFromPrinter), .tx(GPIO[4]), .gnd(GPIO[0]));

	always_ff @(posedge CLOCK_50, negedge rst_l) begin
		if (~rst_l) begin
			LEDR <= 18'b0;
		end
		else begin
			LEDR[7:0] <= (sel) ? ascii : led_reg;
			LEDR[15:8] <= 8'b0;
			LEDR[16] <= parity_error_reg;
			LEDR[17] <= rdy_reg;
		end
	end

endmodule