//defining states of our state machine
`define WAIT_NEWDATA 5'd0
`define FILLSTART_ON 5'd1
`define WAIT_FILLDONE 5'd2
`define GRIDSTART_ON 5'd3
`define WAIT_GRIDDONE 5'd4
`define MAPSTART_ON 5'd5
`define WAIT_MAPDONE 5'd6
`define MAP_DONE 5'd7
`define GET_COMID 5'd8
`define WAIT_COMID 5'd9  
`define GET_XIN 5'd10        
`define WAIT_XIN 5'd11
`define GET_YIN 5'd12
`define WAIT_YIN 5'd13 
`define GET_XOUT 5'd14    
`define WAIT_XOUT 5'd15 
`define GET_YOUT 5'd16
`define WAIT_YOUT 5'd17
`define GOT_COMID 5'd18
`define ALL_DONE 5'd19


//module declaration for gamemaster module
module gamemaster(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW, output logic [9:0] LEDR, 
                output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2, output logic [6:0] HEX3, output logic [6:0] HEX4,
            
             //input logic newData, //signals new data input so screen should be updated
             //input logic gamemasterTurn, //should grab info from keyboard for gamemaster's turn
             //input logic [783:0] mapData, //data on map (such as where players and walls are)

             output logic gamemasterDone, //signals that gamemaster has finished their move
             output logic [1:0] gamemasterCommand, //signals which move is done by gamemaster
             output logic [3:0] wallx_in, output logic [3:0] wally_in, output logic [3:0] wallx_out, output logic [3:0] wally_out,

             //wires needed for VGA module
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK
             
             );

    //creating state wires for state machine
    logic [4:0] present_state, next_state;

    //initializing wires and buses for makegrid module
    logic grid_start, grid_done, fill_start, fill_done, map_start, map_done, gotinput, got_xin, got_yin, got_xout, got_yout;
    logic [8:0] x, fill_x, grid_x, map_x;
    logic [7:0] y, fill_y, grid_y, map_y;
    logic [1:0] comID;
    //logic [3:0] wallx_in, wally_in, wallx_out, wally_out;

    //initializing wires for vga_adapter module
    logic [9:0] VGA_R_10;
    logic [9:0] VGA_G_10;
    logic [9:0] VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;
    logic fill_plot, plot, grid_plot, map_plot;
    logic [2:0] white, black, fill_colour, grid_colour, colour, map_colour;
    
    //creating here to test
    logic [783:0] mapData;
    logic newData, gamemasterTurn;

    assign newData = 1;
    assign gamemasterTurn = 1;

    assign mapData[55:0] = 56'b0010_0010_0010_0000_0000_0101_0000_0000_0101_0000_0000_0001_0001_0001;
    assign mapData[111:56] = 56'b0010_0010_0000_0101_0000_0000_0000_0000_0000_0000_0000_0000_0001_0001;
    assign mapData[167:112] = 56'b0000_0000_0000_0000_0000_0000_0000_0000_0101_0000_0000_0000_0000_0000;
    assign mapData[223:168] = 56'b0000_0000_0000_0000_0101_0000_0101_0000_0000_0000_0101_0000_0000_0000;
    assign mapData[279:224] = 56'b0101_0000_0101_0000_0000_0000_0000_0000_0000_0101_0000_0000_0101_0000;
    assign mapData[335:280] = 56'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    assign mapData[391:336] = 56'b0000_0000_0000_0000_0101_0000_0110_0110_0000_0000_0101_0000_0000_0000;
    assign mapData[447:392] = 56'b0000_0101_0000_0000_0000_0000_0110_0110_0000_0000_0000_0000_0000_0000;
    assign mapData[503:448] = 56'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    assign mapData[559:504] = 56'b0101_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0101_0000_0000;
    assign mapData[615:560] = 56'b0000_0000_0101_0000_0000_0101_0000_0000_0000_0101_0000_0000_0000_0000;
    assign mapData[671:616] = 56'b0000_0000_0000_0000_0000_0000_0000_0000_0101_0000_0000_0000_0000_0000;
    assign mapData[727:672] = 56'b0100_0100_0000_0000_0101_0000_0000_0000_0000_0000_0101_0000_0011_0011;
    assign mapData[783:728] = 56'b0100_0100_0100_0000_0000_0000_0000_0000_0000_0000_0000_0011_0011_0011;

    assign white = 3'b111;
    assign black = 3'b0;

    assign VGA_R = VGA_R_10[9:2];
    assign VGA_G = VGA_G_10[9:2];
    assign VGA_B = VGA_B_10[9:2];
    

    //instantiating register that holds the current state
    register_5bit state_machine(next_state, KEY[3], CLOCK_50, present_state);

    //instantiating fillscreen module
    fillscreen paintscreen(CLOCK_50, KEY[3], white, fill_start, //inputs
                        fill_done, fill_x, fill_y, fill_colour, fill_plot); //outputs

    //instantiating makegrid module
    makegrid paintgrid(CLOCK_50, KEY[3], black, grid_start, //inputs
                        grid_done, grid_x, grid_y, grid_colour, grid_plot); //outputs
    
    //instantiating mapbuilder module
    mapbuilder buildmap(CLOCK_50, KEY[3], mapData, map_start, //inputs
                         map_done, map_x, map_y, map_colour, map_plot);          
               
    //instantiating vga_adapter module
    //vga_adapter model received from TA 
    vga_adapter#(.RESOLUTION("320x240")) vga(KEY[3], CLOCK_50, colour, x, y, plot, //inputs 
                    VGA_R_10, VGA_G_10, VGA_B_10, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK); //outputs


    //assign LEDR = present_state;

    //always block that determines the wires that connect makegrid and vga_adapter
    always_comb begin 
        case(present_state)
            // `WAIT_NEWDATA:      {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, fill_x, fill_y, fill_plot, fill_colour, (newData? `FILLSTART_ON : `WAIT_NEWDATA), 1'b0};
            `WAIT_NEWDATA:      {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, fill_x, fill_y, fill_plot, fill_colour, newData? `FILLSTART_ON : `WAIT_NEWDATA, 1'b0};
            `FILLSTART_ON:      {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b1, 1'b0, 1'b0, fill_x, fill_y, fill_plot, fill_colour, `WAIT_FILLDONE, 1'b0};
            `WAIT_FILLDONE:     {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b1, 1'b0, 1'b0, fill_x, fill_y, fill_plot, fill_colour, fill_done? `GRIDSTART_ON : `WAIT_FILLDONE, 1'b0};
            `GRIDSTART_ON:      {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b1, 1'b0, grid_x, grid_y, grid_plot, grid_colour, `WAIT_GRIDDONE, 1'b0};
            `WAIT_GRIDDONE:     {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b1, 1'b0, grid_x, grid_y, grid_plot, grid_colour, grid_done? `MAPSTART_ON : `WAIT_GRIDDONE, 1'b0};
            `MAPSTART_ON:       {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b1, map_x, map_y, map_plot, map_colour, `WAIT_MAPDONE, 1'b0};
            `WAIT_MAPDONE:      {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b1, map_x, map_y, map_plot, map_colour, map_done? `MAP_DONE : `WAIT_MAPDONE, 1'b0};         
            
            `GET_COMID:         {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, map_x, map_y, map_plot, map_colour, KEY[0]? `WAIT_COMID : `GET_COMID, 1'b0};         
            `WAIT_COMID:        {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, map_x, map_y, map_plot, map_colour, gotinput? `GET_XIN : `WAIT_COMID, 1'b0};         
            
            `GET_XIN:           {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, map_x, map_y, map_plot, map_colour, KEY[0]? `WAIT_XIN : `GET_XIN, 1'b0};         
            `WAIT_XIN:          {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, map_x, map_y, map_plot, map_colour, got_xin? `GET_YIN : `WAIT_XIN, 1'b0};         
            `GET_YIN:           {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, map_x, map_y, map_plot, map_colour, KEY[0]? `WAIT_YIN : `GET_YIN, 1'b0};         
            `WAIT_YIN:          {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, map_x, map_y, map_plot, map_colour, got_yin? `GET_XOUT : `WAIT_YIN, 1'b0};         
            `GET_XOUT:          {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, map_x, map_y, map_plot, map_colour, KEY[0]? `WAIT_XOUT: `GET_XOUT, 1'b0};         
            `WAIT_XOUT:         {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, map_x, map_y, map_plot, map_colour, got_xout? `GET_YOUT : `WAIT_XOUT, 1'b0};         
            `GET_YOUT:          {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, map_x, map_y, map_plot, map_colour, KEY[0]? `WAIT_YOUT : `GET_YOUT, 1'b0};         
            `WAIT_YOUT:         {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, map_x, map_y, map_plot, map_colour, got_yout? `ALL_DONE : `WAIT_YOUT, 1'b0};         
            
            `MAP_DONE:          {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, fill_x, fill_y, fill_plot, fill_colour, gamemasterTurn? `GET_COMID : `ALL_DONE, 1'b1};
            `ALL_DONE:          {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, fill_x, fill_y, fill_plot, fill_colour, `WAIT_NEWDATA, 1'b1};
            default:            {fill_start, grid_start, map_start, x, y, plot, colour, next_state, gamemasterDone} = {1'b0, 1'b0, 1'b0, fill_x, fill_y, fill_plot, fill_colour, `FILLSTART_ON, 1'b0};
        endcase        
    end

    
     always_ff @( posedge CLOCK_50 ) begin 
          if (present_state == `WAIT_NEWDATA) begin
              gotinput <= 0; LEDR <= 0; got_xin <= 0; got_yin <= 0; got_xout <= 0; got_yout <= 0; 
              HEX0 <= 7'b1111111; HEX1 <= 7'b1111111; HEX2 <= 7'b1111111; HEX3 <= 7'b1111111; HEX4 <= 7'b1111111;
          end
          else if (present_state == `GET_COMID) begin
              LEDR[0] <= 1;
          end
          else if (present_state == `WAIT_COMID) begin
              if(KEY[0] == 0) begin
                  comID <= SW[1:0];
                  gamemasterCommand <= SW[1:0];
                  LEDR[1] <= 1;
                  gotinput <= 1;
                  HEX0 <= ~gamemasterCommand;
              end
          end
          else if (present_state == `GET_XIN) begin
              LEDR[2] <= 1;
          end
          else if (present_state == `WAIT_XIN) begin
              if(KEY[0] == 0) begin
                  wallx_in <= SW[3:0];
                  LEDR[3] <= 1;
                  got_xin <= 1;
                  HEX1 <= ~wallx_in;
              end
          end
          else if (present_state == `GET_YIN) begin
              LEDR[4] <= 1;
          end
          else if (present_state == `WAIT_YIN) begin
              if(KEY[0] == 0) begin
                  wally_in <= SW[3:0];
                  LEDR[5] <= 1;
                  got_yin <= 1;
                  HEX2 <= ~wally_in;
              end
          end
          else if (present_state == `GET_XOUT) begin
              LEDR[6] <= 1;
          end
          else if (present_state == `WAIT_XOUT) begin
              if(KEY[0] == 0) begin
                  wallx_out <= SW[3:0];
                  LEDR[7] <= 1;
                  got_xout <= 1;
                  HEX3 <= ~wallx_out;
              end
          end
          else if (present_state == `GET_YOUT) begin
              LEDR[8] <= 1;
          end
          else if (present_state == `WAIT_YOUT) begin
              if(KEY[0] == 0) begin
                  wally_out <= SW[3:0];
                  LEDR[9] <= 1;
                  got_yout <= 1;
                  HEX4 <= ~wally_out;
              end
          end
          
     end

endmodule: gamemaster

//module that stores the 4-bit state the statemachine is in
module register_5bit(input logic [4:0] next_state, input logic reset, input logic clock, output logic [4:0] present_state);

    logic [4:0] next_state_reset;

    //always block that assigns values on the positive edge of the clock
    always_ff @(posedge clock)
        //when reset is enabled
        if (reset == 0)
            next_state_reset <= `WAIT_NEWDATA;
        else 
            next_state_reset <= next_state;

    assign present_state = next_state_reset;
            
endmodule
