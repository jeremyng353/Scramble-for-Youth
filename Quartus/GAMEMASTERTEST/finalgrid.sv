//defining states of our state machine
`define FILLSTART_ON 3'd0
`define WAIT_FILLDONE 3'd1
`define GRIDSTART_ON 3'd2
`define WAIT_GRIDDONE 3'd3
`define GRID_DONE 3'd4

//module declaration for finalgrid module
module finalgrid(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW, 
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK, output logic done
            );

    //creating state wires for state machine
    logic [2:0] present_state, next_state;

    //initializing wires and buses for makegrid module
    logic grid_start, grid_done, fill_start, fill_done;
    logic [8:0] x, fill_x, grid_x;
    logic [7:0] y, fill_y, grid_y;

    //initializing wires for vga_adapter module
    logic [9:0] VGA_R_10;
    logic [9:0] VGA_G_10;
    logic [9:0] VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;
    logic fill_plot, plot, grid_plot;
    logic [2:0] white, black, fill_colour, grid_colour, colour;

    assign white = 3'b111;
    assign black = 3'b0;

    assign VGA_R = VGA_R_10[9:2];
    assign VGA_G = VGA_G_10[9:2];
    assign VGA_B = VGA_B_10[9:2];


    //instantiating register that holds the current state
    register_3bit state_machine_task2(next_state, KEY[3], CLOCK_50, present_state);

    //instantiating fillscreen module
    fillscreen paintscreen(CLOCK_50, KEY[3], white, fill_start, //inputs
                        fill_done, fill_x, fill_y, fill_colour, fill_plot); //outputs

    //instantiating makegrid module
    makegrid paintgrid(CLOCK_50, KEY[3], black, grid_start, //inputs
                        grid_done, grid_x, grid_y, grid_colour, grid_plot); //outputs
               
    //instantiating vga_adapter module
    //vga_adapter model received from TA 
    vga_adapter#(.RESOLUTION("320x240")) vga(KEY[3], CLOCK_50, colour, x, y, plot, //inputs 
                    VGA_R_10, VGA_G_10, VGA_B_10, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK); //outputs

    //always block that determines the wires that connect makegrid and vga_adapter
    always_comb begin 
        case(present_state)
            `FILLSTART_ON:      {fill_start, grid_start, x, y, plot, colour, next_state, done} = {1'b1, 1'b0, fill_x, fill_y, fill_plot, fill_colour, `WAIT_FILLDONE, 1'b0};
            `WAIT_FILLDONE:     {fill_start, grid_start, x, y, plot, colour, next_state, done} = {1'b1, 1'b0, fill_x, fill_y, fill_plot, fill_colour, fill_done? `GRIDSTART_ON : `WAIT_FILLDONE, 1'b0};
            `GRIDSTART_ON:      {fill_start, grid_start, x, y, plot, colour, next_state, done} = {1'b0, 1'b1, grid_x, grid_y, grid_plot, grid_colour, `WAIT_GRIDDONE, 1'b0};
            `WAIT_GRIDDONE:     {fill_start, grid_start, x, y, plot, colour, next_state, done} = {1'b0, 1'b1, grid_x, grid_y, grid_plot, grid_colour, grid_done? `GRID_DONE : `WAIT_GRIDDONE, 1'b0};
            `GRID_DONE:    {fill_start, grid_start, x, y, plot, colour, next_state, done} = {1'b0, 1'b0, fill_x, fill_y, fill_plot, fill_colour, `GRID_DONE, 1'b1};
            default:        {fill_start, grid_start, x, y, plot, colour, next_state, done} = {1'b0, 1'b0, fill_x, fill_y, fill_plot, fill_colour, `FILLSTART_ON, 1'b0};
        endcase        
    end

endmodule: finalgrid

//module that stores the 3-bit state the statemachine is in
module register_3bit(input logic [2:0] next_state, input logic reset, input logic clock, output logic [2:0] present_state);

    logic [2:0] next_state_reset;

    //always block that assigns values on the positive edge of the clock
    always_ff @(posedge clock)
        //when reset is enabled
        if (reset == 0)
            next_state_reset <= `FILLSTART_ON;
        else 
            next_state_reset <= next_state;

    assign present_state = next_state_reset;
            
endmodule
