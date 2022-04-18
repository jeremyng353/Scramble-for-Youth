//defining states of our state machine
`define WAIT 3'd0
`define TURNPIXEL 3'd1
`define ITERATE_Y 3'd2
`define ITERATE_X 3'd3
`define DONE 3'd4
`define SET_Y 3'd5

//module that fills the screen of the VGA
module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [8:0] vga_x, output logic [7:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);

//     reference code of what needs to be implemented
//      for x = 0 to 159:
//           for y = 0 to 119:
//                turn on pixel (x, y) with colour (x mod 8)

    //creating state wires for state machine
    logic [2:0] present_state, next_state;

    //creating indices of iteration
    logic [8:0] x;
    logic [7:0] y;
    
    //instantiating register that holds the current state
    fillregister_3bit state_machine_fillscreen(next_state, rst_n, clk, present_state);

     //always block that determines the outputs of the module and the next state of the state machine
     always_comb begin 
          case(present_state)
               `WAIT:         {done, vga_x, vga_y, vga_colour, vga_plot, next_state} = {1'b0, x, y, colour, 1'b0, start? `TURNPIXEL : `WAIT};
               `TURNPIXEL:    {done, vga_x, vga_y, vga_colour, vga_plot, next_state} = {1'b0, x, y, colour, 1'b1, (y < 8'd240)? `ITERATE_Y : ((x < 9'd320)? `ITERATE_X : `DONE)};
               `ITERATE_Y:    {done, vga_x, vga_y, vga_colour, vga_plot, next_state} = {1'b0, x, y, colour, 1'b0, `TURNPIXEL};
               `ITERATE_X:    {done, vga_x, vga_y, vga_colour, vga_plot, next_state} = {1'b0, x, y, colour, 1'b0, `SET_Y};
               `DONE:         {done, vga_x, vga_y, vga_colour, vga_plot, next_state} = {1'b1, x, y, colour, 1'b0, `DONE};
               `SET_Y:        {done, vga_x, vga_y, vga_colour, vga_plot, next_state} = {1'b0, x, y, colour, 1'b0, `TURNPIXEL};
               default:       {done, vga_x, vga_y, vga_colour, vga_plot, next_state} = {1'b0, x, y, colour, 1'b0, `WAIT};
          endcase
     end


     //always block that manages iteration
     always_ff @( posedge clk ) begin 
          if (present_state == `WAIT) begin
               x = 0; y = 0;
          end
          else if (present_state == `ITERATE_Y) y++;
          else if (present_state == `ITERATE_X) x++;
          else if (present_state == `SET_Y) y = 0;
          
     end


endmodule

//module that stores the 3-bit state the statemachine is in
module fillregister_3bit(input logic [2:0] next_state, input logic reset, input logic clock, output logic [2:0] present_state);

    logic [2:0] next_state_reset;

    //always block that assigns values on the positive edge of the clock
    always_ff @(posedge clock)
        //when reset is enabled
        if (reset == 0)
            next_state_reset <= `WAIT;
        else 
            next_state_reset <= next_state;

    assign present_state = next_state_reset;
            
endmodule
