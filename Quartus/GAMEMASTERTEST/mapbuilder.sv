//define codes for blocks in the map
`define NOTHING 4'b0000 //WHITE
`define PLAYER1 4'b0001 //BLUE
`define PLAYER2 4'b0010 //YELLOW
`define PLAYER3 4'b0011 //GREEN
`define PLAYER4 4'b0100 //RED
`define WALL 4'b0101 //BLACK
`define OBJECTIVE 4'b0110 //PINK

module mapbuilder(input logic clk, input logic rst_n, input logic [783:0] mapData,
                  input logic start, output logic done,
                  output logic [8:0] vga_x, output logic [7:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);


    //creating indices of iteration
    logic [8:0] x1;
    logic [7:0] y1, row_pos;
    logic p_start, p_done, p_plot, p_reset;
    logic [2:0] r1_colour;
    logic [55:0] rowdata;

    //creating state wires for state machine
    logic [2:0] present_state, next_state;


    pieces putpieces(.clk(clk), .rst_n(p_reset), .rowdata(rowdata),
               .origin_x(9'd90), .origin_y(row_pos),  
               .start(p_start), .done(p_done), .x1(x1), .y1(y1), 
               .vga_colour(r1_colour), .vga_plot(p_plot));


     enum {INIT, ROW1, ROW2, ROW3, ROW4, ROW5, ROW6, ROW7, ROW8, ROW9, ROW10, ROW11, ROW12, ROW13, ROW14, DONE} CURR_STATE;

     always_ff @ (posedge clk or negedge rst_n) begin
          if (!rst_n) CURR_STATE <= INIT;
          else begin
               case (CURR_STATE)
                    INIT: begin
                         done <= 1'b0; vga_plot <= 1'b0; row_pos = 8'd40; p_reset <= 1;
                         if (start) begin 
                              vga_x <= x1; vga_y <= y1; vga_plot <= 0; vga_colour <= 3'b111; CURR_STATE <= ROW1; end
                         else begin 
                              p_start <= 0; CURR_STATE <= INIT; end
                    end
                    ROW1: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[55:0]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW2; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW2: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[111:56]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW3; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW3: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[167:112]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW4; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW4: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[223:168]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW5; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW5: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[279:224]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW6; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW6: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[335:280]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW7; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW7: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[391:336]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW8; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW8: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[447:392]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW9; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW9: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[503:448]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW10; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW10: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[559:504]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW11; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW11: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[615:560]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW12; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW12: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[671:616]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW13; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW13: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[727:672]; 
                         if (p_done) begin 
                              CURR_STATE <= ROW14; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end

                    ROW14: begin
                         p_reset <= 1; p_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= p_plot; rowdata <= mapData[783:728]; 
                         if (p_done) begin 
                              CURR_STATE <= DONE; 
                              row_pos += 10;
                              p_start <= 0;
                              p_reset <= 0;
                         end
                    end
                    
                    DONE: begin
                         done <= 1; p_reset <= 0;
                         if (start) begin CURR_STATE <= INIT; end
                    end
                    default: begin vga_x <= 0; vga_y <= 0; vga_plot <= 0; vga_colour <= 3'b111; end
               endcase
          end
     end

endmodule

//puts pieces in row 
//should return x1 and y1 after adding the vlaue of origin_x and origin_y
module pieces(input logic clk, input logic rst_n, input logic [55:0] rowdata,
              input logic [8:0] origin_x, input logic [7:0] origin_y,
              input logic start, output logic done,
              output logic [8:0] x1, output logic [7:0] y1,
              output logic [2:0] vga_colour, output logic vga_plot);

     logic signed [8:0] x, sq_x;
     logic signed [7:0] y, sq_y;
     logic [8:0] offset_x;
     logic sq1_rst;
     logic [3:0] i;
     logic [3:0] pieceID1, pieceID2, pieceID3, pieceID4, pieceID5, pieceID6, pieceID7, 
               pieceID8, pieceID9, pieceID10, pieceID11, pieceID12, pieceID13, pieceID14;
     logic [2:0] colour;

     assign x1 = x + origin_x + 2;
     assign y1 = y + origin_y + 2;
     assign pieceID1 = rowdata[3:0];
     assign pieceID2 = rowdata[7:4];
     assign pieceID3 = rowdata[11:8];
     assign pieceID4 = rowdata[15:12];
     assign pieceID5 = rowdata[19:16];
     assign pieceID6 = rowdata[23:20];
     assign pieceID7 = rowdata[27:24];
     assign pieceID8 = rowdata[31:28];
     assign pieceID9 = rowdata[35:32];
     assign pieceID10 = rowdata[39:36];
     assign pieceID11 = rowdata[43:40];
     assign pieceID12 = rowdata[47:44];
     assign pieceID13 = rowdata[51:48];
     assign pieceID14 = rowdata[55:52];

     //assign LEDR = {pieceID2, pieceID1};

    fillsquare sq1(.clk(clk), .rst_n(sq1_rst), .colour(colour), 
               .start(sq1_start), .done(sq1_done), .vga_x(sq_x), .vga_y(sq_y), 
               .vga_colour(sq1_colour), .vga_plot(sq1_plot));


     enum {INIT, ONE, DRAW, TWO, THREE, FOUR, FIVE, SIX, SEVEN,
     EIGHT, NINE, TEN, ELEVEN, TWELVE, THIRTEEN, FOURTEEN, DONE} CURR_STATE;

     // Implicit Datapath Method
     always_ff @ (posedge clk or negedge rst_n) begin
          if (!rst_n) begin
               CURR_STATE <= INIT;
          end
          else begin
               case (CURR_STATE)
                    INIT: begin
                         done <= 0;
                         sq1_rst <= 0; colour <= 3'b111; offset_x <= 0; i<= 0;
                         if (start) begin CURR_STATE <= ONE; end
                         else CURR_STATE <= INIT;
                    end
                    ONE: begin
                         CURR_STATE <= DRAW; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID1) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= TWO; end

                            endcase
                    end
                    DRAW: begin
                         sq1_start <= 1; x <= sq_x + offset_x; y <= sq_y; vga_colour <= colour; vga_plot <= sq1_plot; 
                         if(sq1_done) begin
                              sq1_rst <= 0;
                              case(i) 
                              0: CURR_STATE <= TWO;
                              1: CURR_STATE <= THREE;
                              2: CURR_STATE <= FOUR;
                              3: CURR_STATE <= FIVE;
                              4: CURR_STATE <= SIX;
                              5: CURR_STATE <= SEVEN;
                              6: CURR_STATE <= EIGHT;
                              7: CURR_STATE <= NINE;
                              8: CURR_STATE <= TEN;
                              9: CURR_STATE <= ELEVEN;
                              10: CURR_STATE <= TWELVE;
                              11: CURR_STATE <= THIRTEEN;
                              12: CURR_STATE <= FOURTEEN;
                              13: CURR_STATE <= DONE;
                              default:  CURR_STATE <= DONE;
                              endcase
                         end
                    end

                    TWO: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID2) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= THREE; end

                            endcase

                    end

                    THREE: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID3) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= FOUR; end

                            endcase
                         
                    end

                    FOUR: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID4) 
                                `NOTHING: begin colour <= 3'b111;  end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= FIVE; end

                            endcase
                         
                    end

                    FIVE: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID5) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= SIX; end

                            endcase
                         
                    end

                    SIX: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID6) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= SEVEN; end

                            endcase
                         
                    end

                    SEVEN: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID7) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= EIGHT; end

                            endcase
                         
                    end

                    EIGHT: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID8) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= NINE; end

                            endcase
                         
                    end
                    NINE: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID9) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= TEN; end

                            endcase
                         
                    end

                    TEN: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID10) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= ELEVEN; end

                            endcase
                         
                    end

                    ELEVEN: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID11) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= TWELVE; end

                            endcase
                         
                    end

                    TWELVE: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID12) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= THIRTEEN; end

                            endcase
                         
                    end

                    THIRTEEN: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID13) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= FOURTEEN; end

                            endcase
                         
                    end

                    FOURTEEN: begin
                         CURR_STATE <= DRAW; offset_x += 10; i+= 1; sq1_start <= 0; sq1_rst <= 1;
                            case(pieceID14) 
                                `NOTHING: begin colour <= 3'b111; end

                                `PLAYER1: begin colour <= 3'b001; end

                                `PLAYER2: begin colour <= 3'b110; end

                                `PLAYER3: begin colour <= 3'b010; end

                                `PLAYER4: begin colour <= 3'b100; end

                                `WALL: begin colour <= 3'b000; end

                                `OBJECTIVE: begin colour <= 3'b101; end

                              default: begin colour <= 3'b011; CURR_STATE <= DONE; end

                            endcase
                         
                    end
                    
                    DONE: begin
                         done <= 1; i <= 0; offset_x <= 0; sq1_rst <= 1; sq1_start <= 0;
                         if (start) begin CURR_STATE <= INIT; end
                    end
                    default: CURR_STATE <= INIT;
               endcase
          end
     end

endmodule

