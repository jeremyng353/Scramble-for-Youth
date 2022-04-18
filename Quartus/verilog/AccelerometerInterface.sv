// States
`define WAIT_I2C 					5'b00000
`define WRITE_LOCATION_I2C 	5'b00001
`define WAIT_WRITE_I2C			5'b00010
`define READ_I2C 					5'b00011
`define WAIT_READ_I2C			5'b00100
`define OUTPUT_I2C				5'b00101

`define WAIT_I2C2 				5'b01000
`define WRITE_LOCATION_I2C2 	5'b01001
`define WAIT_WRITE_I2C2			5'b01010
`define READ_I2C2 				5'b01011
`define WAIT_READ_I2C2			5'b01100
`define OUTPUT_I2C2				5'b01101

`define WAIT_I2C3 				5'b10000
`define WRITE_LOCATION_I2C3 	5'b10001
`define WAIT_WRITE_I2C3			5'b10010
`define READ_I2C3 				5'b10011
`define WAIT_READ_I2C3			5'b10100
`define OUTPUT_I2C3				5'b10101

module AccelerometerInterface(
	input clk, 
	input reset,	// resets on 1
	inout sda,
	inout scl,
	output error, // 1 if error in talking with accelerometer 
	output new_data, // turns to 1 when data_out updates. 
	output [7:0] data_out // data received from the accelerometer. Only gaureenteed to be accurate for 1 clk cycle
);


reg [5:0] i2c_state;

reg busy, ena, rw, ask_accelerometer;

reg [7:0] data_wr;


reg [31:0] counter;

// i2c protocol to interface with accelerometer. 
// IMPORTANT NOTE: I did not take i2c_master, I got it from the internet 
// Source: https://forum.digikey.com/t/i2c-master-vhdl/12797
i2c_master communication(.clk(clk), 
			  .reset_n(~reset), // resets on 0, opposite of how the given wire acts, so it is inverted
			  .ena(ena),
			  .addr(8'h1D), // accelerometer address
			  .rw(rw), // 1 for read
			  .data_wr(data_wr), 
			  .busy(busy),
			  .data_rd(data_out),
			  .ack_error(error),
			  .sda(sda), // GPIO 2
			  .scl(scl));// GPIO 3 



// state 
 always @ (posedge clk) begin
	if (reset) begin
		//reset_i2c <= 1'b0;
		ena <= 1'b0;
		rw = 1'b0;
		data_wr = 1'b0;
		i2c_state <= `WAIT_I2C3;
		//error <= 1'b0;
		new_data <= 1'b0;
		//sumAccelDataState <= 0;
	end
	else begin
		case (i2c_state) 
			// set to 8g
			`WAIT_I2C3: begin // default spot
				if (~busy)
					i2c_state <= `WRITE_LOCATION_I2C3;
			end
			`WRITE_LOCATION_I2C3: begin
				ena <= 1'b1;
				rw <= 1'b0;
				data_wr = 8'h0E; // location for XYZ_DATA_CFG
				if (busy) begin // wait for driver to see this command and become busy
					i2c_state <= `WAIT_WRITE_I2C3;
				end
			end
			`WAIT_WRITE_I2C3: begin
				rw <= 1'b0;
				data_wr = 8'h10; // set to 8 g
				if (busy == 1'b0) begin
					i2c_state <= `READ_I2C3;
					
				end
			end
			`READ_I2C3: begin
				rw <= 1'b0; 
				if (busy == 1'b1) begin
					i2c_state <= `WAIT_READ_I2C3;
				end
			end
			`WAIT_READ_I2C3: begin
				if (busy == 1'b1) begin
					i2c_state <= `OUTPUT_I2C3;
				end
			end
			`OUTPUT_I2C3: begin
				ena <= 1'b0;
				data_out <= data_out;
				i2c_state <= `WAIT_I2C2;
			end		
		
		
			// set to ACTIVE
			`WAIT_I2C2: begin // default spot
				if (~busy)
					i2c_state <= `WRITE_LOCATION_I2C2;
			end
			`WRITE_LOCATION_I2C2: begin
				ena <= 1'b1;
				rw <= 1'b0;
				data_wr = 8'h2A; // location for OUT_X_MSB
				if (busy) begin // wait for driver to see this command and become busy
					i2c_state <= `WAIT_WRITE_I2C2;
				end
			end
			`WAIT_WRITE_I2C2: begin
				rw <= 1'b0;
				data_wr = 8'h01;
				if (busy == 1'b0) begin
					i2c_state <= `READ_I2C2;
					
				end
			end
			`READ_I2C2: begin
				rw <= 1'b0; 
				if (busy == 1'b1) begin
					i2c_state <= `WAIT_READ_I2C2;
				end
			end
			`WAIT_READ_I2C2: begin
				if (busy == 1'b1) begin
					i2c_state <= `OUTPUT_I2C2;
				end
			end
			`OUTPUT_I2C2: begin
				ena <= 1'b0;
				data_out <= data_out;
				i2c_state <= `WAIT_I2C;
			end
			
			
			
			// loop that reads the data 
			`WAIT_I2C: begin // default spot
				new_data <= 0;
				if (ask_accelerometer && ~busy)
					i2c_state <= `WRITE_LOCATION_I2C;
			end
			`WRITE_LOCATION_I2C: begin
				ena <= 1'b1;
				rw <= 1'b0;
				data_wr = 8'h01; //SW[7:0]; // location for OUT_X_MSB
				if (busy) begin // wait for driver to see this command and become busy
					i2c_state <= `WAIT_WRITE_I2C;
				end
			end
			`WAIT_WRITE_I2C: begin
				rw <= 1'b1;
				if (busy == 1'b0) begin
					i2c_state <= `READ_I2C;
				end
			end
			`READ_I2C: begin
				rw <= 1'b1; 
				if (busy == 1'b1) begin
					i2c_state <= `WAIT_READ_I2C;
				end
			end
			`WAIT_READ_I2C: begin
				if (busy == 1'b1) begin
					i2c_state <= `OUTPUT_I2C;
				end
			end
			`OUTPUT_I2C: begin
				ena <= 1'b0;
				data_out <= data_out;
				new_data <= 1;
				i2c_state <= `WAIT_I2C;
			end
			default: begin
				//error = 1;
			end
		endcase
	end
end



 // state machine to ask for data from the accelerometer
 // asks 50 times a second
always @ (posedge clk) begin 
	if (counter == 1000000) begin
		counter <= 0;
		ask_accelerometer <= 0;//0;
	end
	else begin
		counter <= counter + 1;
	end
	if (counter == 999995) begin
		ask_accelerometer <= 1;
	end
end



endmodule