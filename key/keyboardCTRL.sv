/* Build18 keyboard controller *
 * Date Created: 1/11/15       *
 * Data last edit: 1/11/15     */

module keyboard(
  input bit clk_k, //clk of the keyboard
  input bit data, //data from the keyboard 
  output bit [7:0] led, //printing data from led
  output bit parity_error, //check for parity error
  output bit rdy); // ready signal 

  reg [9:0] register; 
  bit [3:0] counter; 
  bit       parity;

  assign led = register[9:2];
  assign parity = register[1];

  always_ff@(negedge clk_k)
    begin
      register <= {register[8:0], data};
      if(counter == 4'b1011)
        counter <= 4'b0000; 
      else 
        counter <= counter + 4'b1;  
    end     

  always_ff@(posedge clk_k)
    begin
      if(counter == 4'b1011) 
        if(!parity == ^led)
          rdy <= 1'b1;
        else 
          parity_error <= 1'b1;
      else begin
        rdy <= 1'b0;
        parity_error <= 1'b0; 
      end 
    end 

endmodule 

module decoder(
  input bit clk, reset_l,
  input bit [7:0] led_de,
  input bit doneFromPrinter,
  input bit rdyFromKey, 
  output bit rdyToPrint, 
  output bit [7:0] ascii);

  bit [7:0] ascii_tmp;

  always_ff@(posedge clk,negedge reset_l)
    if(~reset_l) begin 
      ascii <= 8'h3D; //'='
      rdyToPrint <= 1'b0; 
    end
    else begin
      if(doneFromPrinter && rdyFromKey) begin 
        rdyToPrint <= 1'b1;  
        ascii <= ascii_tmp; 
      end 
      else begin
        rdyToPrint <= 1'b0;
        ascii <= 8'h3D; //'='
      end 
    end 

   ascii_translation at(.keyboard_input(ascii_tmp),.led(led_de));

endmodule 

module ascii_translation(
    input bit [7:0] led,
    output bit [7:0] keyboard_input
  );

  always_comb begin
      keyboard_input = 8'b0;
      case (led)
        8'b0011_1000: keyboard_input = 8'h41; //A
        8'b0100_1100: keyboard_input = 8'h42; //B
        8'b1000_0100: keyboard_input = 8'h43; //C
        8'b1100_0100: keyboard_input = 8'h44; //D
        8'b0010_0100: keyboard_input = 8'h45; //E
        8'b1101_0100: keyboard_input = 8'h46; //F
        8'b0010_1100: keyboard_input = 8'h47; //G
        8'b1100_1100: keyboard_input = 8'h48; //H
        8'b1100_0010: keyboard_input = 8'h49; //I
        8'b1101_1100: keyboard_input = 8'h4a; //J
        8'b0100_0010: keyboard_input = 8'h4b; //K
        8'b1101_0010: keyboard_input = 8'h4c; //L
        8'b0101_1100: keyboard_input = 8'h4d; //M
        8'b1000_1100: keyboard_input = 8'h4e; //N
        8'b0010_0010: keyboard_input = 8'h4f; //O
        8'b1011_0010: keyboard_input = 8'h50; //P
        8'b1010_1000: keyboard_input = 8'h51; //Q
        8'b1011_0100: keyboard_input = 8'h52; //R
        8'b1101_1000: keyboard_input = 8'h53; //S
        8'b0011_0100: keyboard_input = 8'h54; //T
        8'b0011_1100: keyboard_input = 8'h55; //U
        8'b0101_0100: keyboard_input = 8'h56; //V
        8'b1011_1000: keyboard_input = 8'h57; //W
        8'b0100_0100: keyboard_input = 8'h58; //X
        8'b1010_1100: keyboard_input = 8'h59; //Y
        8'b0101_1000: keyboard_input = 8'h5a; //Z
        8'b0110_1000: keyboard_input = 8'h31; //1
        8'b0111_1000: keyboard_input = 8'h32; //2
        8'b0110_0100: keyboard_input = 8'h33; //3
        8'b1010_0100: keyboard_input = 8'h34; //4
        8'b0111_0100: keyboard_input = 8'h35; //5
        8'b0110_1100: keyboard_input = 8'h36; //6
        8'b1011_1100: keyboard_input = 8'h37; //7
        8'b0111_1100: keyboard_input = 8'h38; //8
        8'b0110_0010: keyboard_input = 8'h39; //9
        8'b1010_0010: keyboard_input = 8'h30; //0
		  default: keyboard_input = 8'b0;
      endcase
  end
endmodule
