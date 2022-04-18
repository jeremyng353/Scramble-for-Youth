module makegrid(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [8:0] vga_x, output logic [7:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);


    //creating indices of iteration
    logic [8:0] x1;
    logic [7:0] y1, row_pos;
    logic r1_start, r1_done, r1_plot, line;
    logic [2:0] r1_colour;

    //creating state wires for state machine
    logic [2:0] present_state, next_state;

     row r1(.clk(clk), .rst_n(rst_n), .colour(3'b0), .line(line),
               .origin_x(9'd90), .origin_y(row_pos),  
               .start(r1_start), .done(r1_done), .x1(x1), .y1(y1), 
               .vga_colour(r1_colour), .vga_plot(r1_plot));

     enum {INIT, ROW, LINE, DONE} CURR_STATE;

     always_ff @ (posedge clk or negedge rst_n) begin
          if (!rst_n) CURR_STATE <= INIT;
          else begin
               case (CURR_STATE)
                    INIT: begin
                         done <= 1'b0; vga_plot <= 1'b0; row_pos = 8'd40; line = 0;
                         if (start) begin 
                              vga_x <= x1; vga_y <= y1; vga_plot <= 0; vga_colour <= 3'b111; CURR_STATE <= ROW; end
                         else begin 
                              r1_start <= 0; CURR_STATE <= INIT; end
                    end
                    ROW: begin
                         r1_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= r1_plot; 
                         if (r1_done) begin 
                              r1_start <= 0; row_pos += 10; CURR_STATE <= ROW;
                              if(row_pos > 170) begin CURR_STATE <= LINE; end
                         end
                    end
                    LINE: begin
                         r1_start <= 1; vga_x <= x1; vga_y <= y1; vga_colour <= r1_colour; vga_plot <= r1_plot; line = 1;
                         if (r1_done) begin 
                              CURR_STATE <= DONE; 
                              r1_start <= 0;
                         end
                    end
                    
                    DONE: begin
                         done <= 1; 
                         if (start) begin CURR_STATE <= INIT; end
                    end
                    default: begin vga_x <= 0; vga_y <= 0; vga_plot <= 0; vga_colour <= 3'b111; end
               endcase
          end
     end

endmodule

//draws a row given for the grid given where the row starts 
module row(input logic clk, input logic rst_n, input logic [2:0] colour, input logic line,
              input logic [8:0] origin_x, input logic [7:0] origin_y,
              input logic start, output logic done,
              output logic [8:0] x1, output logic [7:0] y1,
              output logic [2:0] vga_colour, output logic vga_plot);

     logic signed [8:0] x;
     logic signed [7:0] y;
     logic [8:0] offset_x;
     logic plot;

     assign vga_colour = colour;
     assign x1 = x + origin_x;
     assign y1 = y + origin_y;
     assign vga_plot = plot;
     assign offset_x = 9'd10;

     enum {INIT, LINE, DOTS, DONE} CURR_STATE;

     // Implicit Datapath Method
     always_ff @ (posedge clk or negedge rst_n) begin
          if (!rst_n) begin
               CURR_STATE <= INIT;
               x <= 0; y <= 0; plot <= 0; 
          end
          else begin
               case (CURR_STATE)
                    INIT: begin
                         plot <= 0;
                         done <= 0;
                         x <= -1; y <= 0; 
                         if (start) begin CURR_STATE <= LINE; end
                         else CURR_STATE <= INIT;
                    end
                    LINE: begin
                         x++; plot <= 1; CURR_STATE <= LINE;
                         if (x > 140) begin x <= -offset_x; y++; plot <= 0; CURR_STATE <= DOTS; if(line) begin CURR_STATE <= DONE; end end
                    end
                    DOTS: begin
                         x <= x + offset_x; plot <= 1;
                         if (x > 130) begin 
                              x<= -offset_x; y++; plot <= 0; CURR_STATE <= DOTS; 
                              if(y%10 == 0) begin
                                   CURR_STATE <= DONE;
                              end
                         end
                    end
                    DONE: begin
                         done <= 1; 
                         if (start) begin CURR_STATE <= INIT; end
                    end
                    default: CURR_STATE <= INIT;
               endcase
          end
     end

endmodule

