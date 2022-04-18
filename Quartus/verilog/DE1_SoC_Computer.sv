

module DE1_SoC_Computer (
	////////////////////////////////////
	// FPGA Pins
	////////////////////////////////////

// Clock pins
input						CLOCK_50,
input						CLOCK2_50,
input						CLOCK3_50,
input						CLOCK4_50,

// ADC
inout						ADC_CS_N,
output					ADC_DIN,
input						ADC_DOUT,
output					ADC_SCLK,

// Audio
input						AUD_ADCDAT,
inout						AUD_ADCLRCK,
inout						AUD_BCLK,
output					AUD_DACDAT,
inout						AUD_DACLRCK,
output					AUD_XCK,

// SDRAM
output 		[12: 0]	DRAM_ADDR,
output		[ 1: 0]	DRAM_BA,
output					DRAM_CAS_N,
output					DRAM_CKE,
output					DRAM_CLK,
output					DRAM_CS_N,
inout			[15: 0]	DRAM_DQ,
output					DRAM_LDQM,
output					DRAM_RAS_N,
output					DRAM_UDQM,
output					DRAM_WE_N,

// I2C Bus for Configuration of the Audio and Video-In Chips
output					FPGA_I2C_SCLK,
inout						FPGA_I2C_SDAT,

// 40-pin headers
inout			[35: 0]	GPIO_0,
inout			[35: 0]	GPIO_1,

// Seven Segment Displays
output		[ 6: 0]	HEX0,
output		[ 6: 0]	HEX1,
output		[ 6: 0]	HEX2,
output		[ 6: 0]	HEX3,
output		[ 6: 0]	HEX4,
output		[ 6: 0]	HEX5,

// IR
input						IRDA_RXD,
output					IRDA_TXD,

// Pushbuttons
input			[ 3: 0]	KEY,

// LEDs
output		[ 9: 0]	LEDR,

// PS2 Ports
inout						PS2_CLK,
inout						PS2_DAT,

inout						PS2_CLK2,
inout						PS2_DAT2,

// Slider Switches
input			[ 9: 0]	SW,

// Video-In
input						TD_CLK27,
input			[ 7: 0]	TD_DATA,
input						TD_HS,
output					TD_RESET_N,
input						TD_VS,

// VGA
output		[ 7: 0]	VGA_B,
output					VGA_BLANK_N,
output					VGA_CLK,
output		[ 7: 0]	VGA_G,
output					VGA_HS,
output		[ 7: 0]	VGA_R,
output					VGA_SYNC_N,
output					VGA_VS,



////////////////////////////////////
// HPS Pins
////////////////////////////////////
	
// DDR3 SDRAM
output		[14: 0]	HPS_DDR3_ADDR,
output		[ 2: 0]  HPS_DDR3_BA,
output					HPS_DDR3_CAS_N,
output					HPS_DDR3_CKE,
output					HPS_DDR3_CK_N,
output					HPS_DDR3_CK_P,
output					HPS_DDR3_CS_N,
output		[ 3: 0]	HPS_DDR3_DM,
inout			[31: 0]	HPS_DDR3_DQ,
inout			[ 3: 0]	HPS_DDR3_DQS_N,
inout			[ 3: 0]	HPS_DDR3_DQS_P,
output					HPS_DDR3_ODT,
output					HPS_DDR3_RAS_N,
output					HPS_DDR3_RESET_N,
input						HPS_DDR3_RZQ,
output					HPS_DDR3_WE_N,

// Ethernet
output					HPS_ENET_GTX_CLK,
inout						HPS_ENET_INT_N,
output					HPS_ENET_MDC,
inout						HPS_ENET_MDIO,
input						HPS_ENET_RX_CLK,
input			[ 3: 0]	HPS_ENET_RX_DATA,
input						HPS_ENET_RX_DV,
output		[ 3: 0]	HPS_ENET_TX_DATA,
output					HPS_ENET_TX_EN,

// Flash
inout			[ 3: 0]	HPS_FLASH_DATA,
output					HPS_FLASH_DCLK,
output					HPS_FLASH_NCSO,

// Accelerometer
inout						HPS_GSENSOR_INT,

// General Purpose I/O
inout			[ 1: 0]	HPS_GPIO,

// I2C
inout						HPS_I2C_CONTROL,
inout						HPS_I2C1_SCLK,
inout						HPS_I2C1_SDAT,
inout						HPS_I2C2_SCLK,
inout						HPS_I2C2_SDAT,

// Pushbutton
inout						HPS_KEY,

// LED
inout						HPS_LED,

// SD Card
output					HPS_SD_CLK,
inout						HPS_SD_CMD,
inout			[ 3: 0]	HPS_SD_DATA,

// SPI
output					HPS_SPIM_CLK,
input						HPS_SPIM_MISO,
output					HPS_SPIM_MOSI,
inout						HPS_SPIM_SS,

// UART
input						HPS_UART_RX,
output					HPS_UART_TX,

// USB
inout						HPS_CONV_USB_N,
input						HPS_USB_CLKOUT,
inout			[ 7: 0]	HPS_USB_DATA,
input						HPS_USB_DIR,
input						HPS_USB_NXT,
output					HPS_USB_STP // ,
	
	// new clock
//	PLL0_REFCLK, 
//	PLL0_RESET,
//	MASTERclk
);

//=======================================================
//  STRUCT declarations - there are more inside AI.sv
//=======================================================

// struct for returning data to linux on the DE1
typedef struct {
	reg [31:0] cmd;
	reg [31:0] dat1;
	reg [31:0] dat2;
	reg [31:0] dat3;
	reg [31:0] dat4;
	reg [31:0] dat5;
	reg [31:0] dat6;
	reg [31:0] dat7;
	reg [31:0] dat8;
	reg [31:0] dat9;
	reg [31:0] dat10;
	reg [31:0] dat11;
	reg [31:0] dat12;
} CommandDataOut;

// input command to game master
//typedef struct {
//	reg [783:0] mapData; // same structure as game master
//	playerInfo AIplayer; // Info for the player AI
//	reg [1:0] AIPlayerNum; // waht player is the AI?
//} AIcommand;


// OUTPUT of game master
typedef struct {
	reg [3:0] commandID;
	reg [13:0] locationX;
	reg [13:0] locationY;
} gameMasterCommand;

//=======================================================
//  REG/WIRE declarations
//=======================================================

// command sent by linux on de1
reg [31:0] cmd_id = 0;

// Power and ground for accelerometer
assign GPIO_0[0] = 1'b1;
assign GPIO_0[1] = 1'b0;

// Accelerometer related
reg awk_i2c_error;
reg reqAccel = 0; 
reg doneAccel = 0;
reg newdata = 0;
reg master_reset = 0;
reg [7:0] i2c_output; 

// for summing data from accel
reg [3:0] sumAccelDataState = 0;
reg [31:0] accelSum = 0;
reg [15:0] accelCounter = 0;
 
// for testing 
assign HEX3[3:0] = ~sumAccelDataState;
assign HEX5[6:0] = ~commandCount[6:0];
assign LEDR[9] = awk_i2c_error;

// reset
assign master_reset = ~KEY[0];

reg AI_reset = 0;
reg [783:0] mapData; // data to send to game master ---------------------------------------------------
reg gamemasterTurn;
reg turnCount;

// absolute value of accelerometer output
reg [7:0] accelDataAdjusted = 0;
 
 // taking the absolute value of the accelerometer data
 always_comb begin
 	if (i2c_output[7] == 1) begin
		accelDataAdjusted <= (~i2c_output[7:0] + 1);
	end
	else begin
		accelDataAdjusted <= i2c_output[7:0];
	end
 end
//


AccelerometerInterface AccelInterface(
	.clk(CLOCK_50), 
	.reset(master_reset),	// resets on 1
	.sda(GPIO_0[2]),
	.scl(GPIO_0[3]),
	.error(awk_i2c_error), // 1 if error in talking with accelerometer 
	.new_data(newdata), // turns to 1 when data_out updates. 
	.data_out(i2c_output) // data received from the accelerometer. Only gaureenteed to be accurate for 1 clk cycle
);
//


// State machine: sum data from the accelerometer when requested by reqAccel
 always @ (posedge CLOCK_50) begin
	if (master_reset) begin
		sumAccelDataState <= 0;
	end
	else begin
		case (sumAccelDataState) 
			4'b0000: begin
				doneAccel <= 0;
				accelCounter <= 0;
				accelSum <= 0;
				if (reqAccel) begin
					sumAccelDataState <= 4'b0001;
				end
			end
			4'b0001: begin // wait untill data is at a certain value
				if (accelDataAdjusted >= 8'b00010000 && newdata) begin
					sumAccelDataState <= 4'b0010;
				end
			end
			4'b0010: begin
				if (accelCounter >= 50) begin
					sumAccelDataState <= 4'b0011;
				end
				else if (newdata) begin
					accelSum <= accelSum + accelDataAdjusted;
					accelCounter <= accelCounter + 1;
				end
			end
			4'b0011: begin
				if (reqAccel == 0) begin
					doneAccel <= 0;
					sumAccelDataState <= 4'b0000;
				end
				else begin
					doneAccel <= 1;
				end
			end
		endcase
	end
	
	// show accelerometer output on leds
	if (newdata) begin
		LEDR[7:0] <= accelDataAdjusted;
	end
 end 
 
 
// IMPORTANT NOTE: 
// A lot of this verilog was taken from the internet.
// The code gotten from the internet allowed for data to be sent
// to and from linux on the de1. I changed how much data was being sent or received, 
// and from what sources the data came from or went to 
// source from internet: https://github.com/Jambie82/CycloneV_HPS_FIFO

//=======================================================
// HPS_to_FPGA FIFO state machine
//=======================================================
// --Check for data
//
// --Read data 
// --add one
// --write to SRAM
// --signal HPS data_ready
//=======================================================
// Controls for Qsys sram slave exported in system module
//=======================================================
wire [31:0] sram_readdata ;
reg [31:0] sram_writedata ;
reg [7:0] sram_address; 
reg sram_write ;
wire sram_clken = 1'b1;
wire sram_chipselect = 1'b1;
reg [7:0] state ;
reg initEnable = 0;

//=======================================================
// Controls for HPS_to_FPGA FIFO
//=======================================================

reg [31:0] hps_to_fpga_readdata ; 
reg hps_to_fpga_read ; // read command
wire [31:0] hps_to_fpga_out_csr_address = 32'd1 ; // fill_level  // should probably init to 0
reg[31:0] hps_to_fpga_out_csr_readdata ;
reg hps_to_fpga_out_csr_read ; // status regs read cmd
reg [7:0] HPS_to_FPGA_state ;
reg [31:0] data_buffer ;
reg data_buffer_valid ;

//=======================================================
// Controls for FPGA_to_HPS FIFO
//=======================================================

reg [31:0] fpga_to_hps_in_writedata ; 
reg fpga_to_hps_in_write ; // write command
wire [31:0] fpga_to_hps_in_csr_address = 32'd1 ; // fill_level  // should probably init to 0
reg[31:0] fpga_to_hps_in_csr_readdata ;
reg fpga_to_hps_in_csr_read ; // status regs read cmd
reg [7:0] FPGA_to_HPS_state ;
reg [7:0] Processing_state ;



CommandDataOut commandOut;  // to HPS

// AI info here
AIcommand AIcmd;
reg AI_done = 0;

reg [20:0] testingVar = 0;

MoveInfo Move1Info;
MoveInfo Move2Info;
MoveInfo Move3Info;
AI AIMoveMaker(.clk(CLOCK_50), .reset(AI_reset), .AIcmd(AIcmd),
					.Move1Info(Move1Info), .Move2Info(Move2Info), .Move3Info(Move3Info), .done(AI_done));



reg [7:0]  commandCount = 8'b0;
wire fastclock;  // this is the clock to drive the timing
reg start_digcount = 1'b0;
reg [3:0] digcount_speed = 4'b1;
reg [31:0]  timecounter = 32'd25000000;
reg oneSecClock = 1'b0;
reg doLedInvert = 1'b0;
reg doLedRun = 1'b0;
reg [11:0] LEDcount = 12'd0;
reg doLedSet = 1'b0;
reg [3:0] setLed;
reg setCondition;
reg wasInverted = 1'b0;



//=======================================================
// do the work outlined above
always @(posedge CLOCK_50) begin 

   // reset state machine and read/write controls
	if(initEnable == 0) begin
		sram_write <= 1'b0 ;
		commandCount <= 0 ;
		data_buffer_valid <= 1'b0;
		HPS_to_FPGA_state <= 8'd3 ;
		FPGA_to_HPS_state <= 8'd0 ; 
		Processing_state <= 8'd0 ; 
		initEnable = 1;
	end  // if(init_enable == 0)

	if (master_reset) begin
		commandCount <= 8'b0; // TEMP, MOVE THIS SOMEWHERE BETTER --------------------------------------------------------------
	end 
	
// changing this to - get 4 32-bit words (command-data)
//                  - act on the command-data	
//                  - send a response as 4 32-bit words

	// =================================
	// HPS_to_FPGA state machine
	//==================================
	// Is there data in HPS_to_FPGA FIFO
	// and the last transfer is complete
	// data_buffer_valid is only used by the FPGA to HPS FIFO !!
	if (HPS_to_FPGA_state == 8'd0 && !(hps_to_fpga_out_csr_readdata[1]) && !data_buffer_valid)  begin
		hps_to_fpga_read <= 1'b1 ;
		HPS_to_FPGA_state <= 8'd2 ; //
	end
	
	// delay before we read
	if (HPS_to_FPGA_state == 8'd2) begin
		// zero the read request BEFORE the data appears 
		// in the next state!
		hps_to_fpga_read <= 1'b0 ;
		HPS_to_FPGA_state <= 8'd4 ;
	end
	
	
	// delay  FOR THE TRIP BACK FROM STATE 4 TO STATE 0
	// this test checks to see if we need more fifo read time
	if (HPS_to_FPGA_state == 8'd3) begin
			HPS_to_FPGA_state <= 8'd0 ;
	end
	
	// read the word from the FIFO
	if ((HPS_to_FPGA_state == 8'd4) && (hps_to_fpga_read == 1'b0)) begin
		// NOTE: I changed stuff here. Data now goes to structures I want it to go to
		if (commandCount == 0) begin
			cmd_id <= hps_to_fpga_readdata ; // store the data
			commandCount <= 8'd1;
			hps_to_fpga_read <= 1'b0 ;
			HPS_to_FPGA_state <= 8'd3 ; 
		end
		
		
		// cmd_id = 10: accelerometer
		else if (cmd_id == 10) begin 
			// no extra data to read, ignore the given data. The dummy info does need to be given though
			commandCount <= 8'd0;
			hps_to_fpga_read <= 1'b0 ;
			HPS_to_FPGA_state <= 8'd3 ; 
			Processing_state <= 8'd5 ; 
		end
		
		
		// cmd_id = 21: GameMaster - receiving data to show on VGA and when it is the game master's turn
		else if (cmd_id == 21) begin
			if (commandCount == 1) begin // read whether its the game master's turn
				gamemasterTurn <= hps_to_fpga_readdata;
				commandCount <= commandCount + 1;
				hps_to_fpga_read <= 1'b0 ;
				HPS_to_FPGA_state <= 8'd3 ;
			end
			else if (commandCount == 2) begin // set map data to be clear on the first read for this vector
				mapData[783:783-31] <= hps_to_fpga_readdata ; // store the data
				mapData[783-32:0] <= 0;
				commandCount <= commandCount + 1;
				hps_to_fpga_read <= 1'b0 ;
				HPS_to_FPGA_state <= 8'd3 ;
			end
			else if (commandCount <= 29) begin // from commandCount 3->29
				if (commandCount[0] == 0) begin // read full data
					mapData[783:783-31] <= hps_to_fpga_readdata ; // store the data
					mapData[783-32:0] <= mapData[783:32];
					commandCount <= commandCount + 1;
					hps_to_fpga_read <= 1'b0 ;
					HPS_to_FPGA_state <= 8'd3 ;
				end
				else begin	// read only part of the data because thats the only place that actually has it
					mapData[783:783-23] <= hps_to_fpga_readdata[23:0]; // store the data
					mapData[783-24:0] <= mapData[783:24];
					commandCount <= commandCount + 1;
					hps_to_fpga_read <= 1'b0 ;
					HPS_to_FPGA_state <= 8'd3 ;
				end
			end
			else begin // commandCounter == 30
				turnCount <= hps_to_fpga_readdata; // store the data
				commandCount <= 0;
				hps_to_fpga_read <= 1'b0 ;
				HPS_to_FPGA_state <= 8'd3 ;
				Processing_state <= 8'd5 ; // done
			end
		end
				
			
		// cmd_id = 35: AI - asking for the AI to make a move
		else if (cmd_id == 35) begin
			if (commandCount == 1) begin // Value not used
				//NOTHING <= hps_to_fpga_readdata;
				commandCount <= commandCount + 1;
				hps_to_fpga_read <= 1'b0 ;
				HPS_to_FPGA_state <= 8'd3 ;
			end
			else if (commandCount == 2) begin // set map data to be clear on the first read for this vector
				AIcmd.mapData[783:783-31] <= hps_to_fpga_readdata ; // store the data
				AIcmd.mapData[783-32:0] <= 0;
				commandCount <= commandCount + 1;
				hps_to_fpga_read <= 1'b0 ;
				HPS_to_FPGA_state <= 8'd3 ;
			end
			else if (commandCount < 30) begin // from commandCount 3->29
				if (commandCount[0] == 0) begin // read full data
					AIcmd.mapData[783:783-31] <= hps_to_fpga_readdata ; // store the data
					AIcmd.mapData[783-32:0] <= AIcmd.mapData[783:32];
					commandCount <= commandCount + 1;
					hps_to_fpga_read <= 1'b0 ;
					HPS_to_FPGA_state <= 8'd3 ;
				end
				else begin	// read only part of the data because thats the only place that actually has it
					AIcmd.mapData[783:783-23] <= hps_to_fpga_readdata[23:0]; // store the data
					AIcmd.mapData[783-24:0] <= AIcmd.mapData[783:24];
					commandCount <= commandCount + 1;
					hps_to_fpga_read <= 1'b0 ;
					HPS_to_FPGA_state <= 8'd3 ;
				end
			end
			else begin // commandCounter > 29
				case(commandCount) 
					30: begin
						AIcmd.AIPlayerNum <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					
					// piece 1
					31: begin
						AIcmd.AIplayer.piece1.x <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					32: begin
						AIcmd.AIplayer.piece1.y <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					33: begin
						AIcmd.AIplayer.piece1.alive <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					34: begin
						AIcmd.AIplayer.piece1.moveDist <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					35: begin
						AIcmd.AIplayer.piece1.attackDist <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					36: begin
						AIcmd.AIplayer.piece1.attackDam <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					
					// piece 2
					37: begin
						AIcmd.AIplayer.piece2.x <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					38: begin
						AIcmd.AIplayer.piece2.y <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					39: begin
						AIcmd.AIplayer.piece2.alive <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					40: begin
						AIcmd.AIplayer.piece2.moveDist <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					41: begin
						AIcmd.AIplayer.piece2.attackDist <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					42: begin
						AIcmd.AIplayer.piece2.attackDam <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end

					// piece 3
					43: begin
						AIcmd.AIplayer.piece3.x <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					44: begin
						AIcmd.AIplayer.piece3.y <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					45: begin
						AIcmd.AIplayer.piece3.alive <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					46: begin
						AIcmd.AIplayer.piece3.moveDist <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					47: begin
						AIcmd.AIplayer.piece3.attackDist <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					48: begin
						AIcmd.AIplayer.piece3.attackDam <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end

					// piece 4
					49: begin
						AIcmd.AIplayer.piece4.x <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					50: begin
						AIcmd.AIplayer.piece4.y <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					51: begin
						AIcmd.AIplayer.piece4.alive <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					52: begin
						AIcmd.AIplayer.piece4.moveDist <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					53: begin
						AIcmd.AIplayer.piece4.attackDist <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					54: begin
						AIcmd.AIplayer.piece4.attackDam <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
						
					// piece 5
					55: begin
						AIcmd.AIplayer.piece5.x <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					56: begin
						AIcmd.AIplayer.piece5.y <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					57: begin
						AIcmd.AIplayer.piece5.alive <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					58: begin
						AIcmd.AIplayer.piece5.moveDist <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					59: begin
						AIcmd.AIplayer.piece5.attackDist <= hps_to_fpga_readdata ; // store the data
						commandCount <= commandCount + 1;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
					end
					60: begin
						AIcmd.AIplayer.piece5.attackDam <= hps_to_fpga_readdata ; // store the data
						commandCount <= 0;
						hps_to_fpga_read <= 1'b0 ;
						HPS_to_FPGA_state <= 8'd3 ;
						Processing_state <= 8'd5 ; // done

					end

					// shouldn't get here
					default: ;//error <= 1;
				endcase			
			end
			
		end
		// else an unrecognized command
		//else 
			//error <= 1;
	end
	
	
	// I made this to handle different commands
	// PROCESSING COMMAND
	
	// ACCEL REQUEST
	if (Processing_state == 8'd10) begin
		reqAccel <= 1;
		if (doneAccel == 1) begin
			commandOut.dat1 <= accelSum;
			Processing_state <= 8'd11;
		end
	end
	if (Processing_state == 8'd11) begin
		reqAccel <= 0;
		if (doneAccel == 0) begin
			Processing_state <= 8'd6 ; //return a data packet
		end
	end
	
	// PUT OTHER REQUESTS HERE
	
	// GAME MASTER REQUEST
	else if (Processing_state == 8'd20) begin
		Processing_state <= 8'd6; // not implemented yet
	end
	
	
	// AI REQUEST
	else if (Processing_state == 8'd30) begin
		AI_reset <= 1;
		testingVar <= 0;
		Processing_state <= 8'd31;
	end
	else if (Processing_state == 8'd31) begin
		AI_reset <= 0;
		testingVar <= testingVar + 1;
		if (AI_done && (AI_reset == 0)) // AI_reset == 0 makes it wait a cycle, so AI_done gets reset
			Processing_state <= 8'd32;
	end	
	else if (Processing_state == 8'd32) begin
		commandOut.dat1  <= Move1Info.MovePiece;
		commandOut.dat2  <= Move1Info.MoveLocX;
		commandOut.dat3  <= Move1Info.MoveLocY;
		commandOut.dat4  <= Move1Info.MoveAttOrMov;
		commandOut.dat5  <= Move2Info.MovePiece;
		commandOut.dat6  <= Move2Info.MoveLocX;
		commandOut.dat7  <= Move2Info.MoveLocY;
		commandOut.dat8  <= Move2Info.MoveAttOrMov;
		commandOut.dat9  <= Move3Info.MovePiece;
		commandOut.dat10 <= Move3Info.MoveLocX;
		commandOut.dat11 <= Move3Info.MoveLocY;
		commandOut.dat12 <= Move3Info.MoveAttOrMov;

//		commandOut.dat1 <= AIcmd.mapData[367:336]; // row 7
//		commandOut.dat2  <= AIcmd.AIPlayerNum;
//		commandOut.dat3  <= AIcmd.AIplayer.piece1.x;
//		commandOut.dat4  <= AIcmd.AIplayer.piece1.y;
//		commandOut.dat5  <= AIcmd.AIplayer.piece1.alive;
//		commandOut.dat6  <= AIcmd.AIplayer.piece1.moveDist;
//		commandOut.dat7  <= AIcmd.AIplayer.piece1.attackDist;
//		commandOut.dat8  <= AIcmd.AIplayer.piece1.attackDam;
//
//		commandOut.dat9  <= AIcmd.AIplayer.piece2.x;
//		commandOut.dat10  <= AIcmd.AIplayer.piece2.y;
//		commandOut.dat11  <= AIcmd.AIplayer.piece2.alive;
//		commandOut.dat12  <= testingVar;

		Processing_state <= 8'd6; // return data packet
	end	
	
	
//----------------------------------------------
// Processing State Machine below
// This is where commands are performed before the results
// are returned by the FPGA_toHPS state machine
	// process the command from the FIFO
	if (Processing_state == 8'd0) begin
	 // this is the 'Home' state, where processing is inactive
	 //  we dont really need an inactive state but if there were
	 //  some background tasks to be done, this is where we would do them
	end

//----------------------------
//  state 5
//----------------------------
	// process the command from the FIFO ------------------------------------------------------------------------------------------------ My stuff here
	if (Processing_state == 8'd5) begin
		if (cmd_id == 8'd10) 
			Processing_state <= 8'd10 ;// THIS STATE IS FOR THE ACCELEROMETER 
		
		else if (cmd_id == 8'd21) 
			Processing_state <= 8'd20 ;// THIS STATE IS FOR THE GAME MASTER 
			
		else if (cmd_id == 8'd35)
			Processing_state <= 8'd30 ;// THIS STATE IS FOR THE ACCELEROMETER 
			
		else begin
			Processing_state <= 8'd6 ; //return a data packet - error because not recognized command =
		end
		commandOut.cmd <= cmd_id;
		commandCount <= 0;
	end

//-------------------------------------------
//  state 6
//----------------------------------------	
	if ((Processing_state == 8'd6) && (FPGA_to_HPS_state == 0)) begin
		case(commandCount)
		8'd0:
		begin
			commandCount <= 8'd1;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd1:
		begin
			commandCount <= 8'd2;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd2:
		begin
			commandCount <= 8'd3;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd3:
		begin
			commandCount <= 8'd4;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd4:
		begin
			commandCount <= 8'd5;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd5:
		begin
			commandCount <= 8'd6;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd6:
		begin
			commandCount <= 8'd7;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd7:
		begin
			commandCount <= 8'd8;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd8:
		begin
			commandCount <= 8'd9;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd9:
		begin
			commandCount <= 8'd10;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd10:
		begin
			commandCount <= 8'd11;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd11:
		begin
			commandCount <= 8'd12;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		8'd12:
		begin
			commandCount <= 8'd13;
			data_buffer_valid <= 1'b1 ; // set the data ready flag - do this to signal HPS that return data is ready
			Processing_state <= 8'd7 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		
		8'd13:
		begin
			commandCount <= 8'd0;
			Processing_state <= 8'd0 ;  // wait for the outgoing FIFO to swallow that data 
		end	
		
		endcase
	end
	
	
	// this is just a wait state to let the FPGA to HPS FIFO move the data
	// data_buffer_valid is only used by the FPGA to HPS FIFO !!  
	//   !data_buffer_valid means the FPGA to HPS FIFO is ready for more data
//	if ((HPS_to_FPGA_state == 8'd7) && !data_buffer_valid)  begin
	if ((Processing_state == 8'd7) && !data_buffer_valid)  begin
			Processing_state <= 8'd6 ;  // data is gone, ready for more data 
//		HPS_to_FPGA_state <= 8'd6 ; 
//hex3_hex0[3:0] <= 4'd6;
	end

	// =================================
	// FPGA_to_HPS state machine
	//================================== 
	// is there space in the 
	// FPGA_to_HPS FIFO
	// and data is available
	if (FPGA_to_HPS_state==0 && !(fpga_to_hps_in_csr_readdata[0]) && data_buffer_valid) begin
		case(commandCount)
			1:
			begin
				fpga_to_hps_in_writedata <= commandOut.cmd ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			2:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat1 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			3:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat2 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			4:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat3 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			5:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat4 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			6:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat5 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			7:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat6 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			8:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat7 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			9:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat8 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			10:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat9 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			11:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat10 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			12:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat11 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			13:
			begin
				fpga_to_hps_in_writedata <= commandOut.dat12 ;	
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
			
			default:
			begin
				fpga_to_hps_in_writedata <= 9 ;	// crude error signal
				fpga_to_hps_in_write <= 1'b1 ;
				FPGA_to_HPS_state <= 8'd4 ;
			end
		endcase	
	end
	
	// finish the write to FPGA_to_HPS FIFO
	if ((FPGA_to_HPS_state == 4) && (fpga_to_hps_in_write == 1'b1)) begin
		fpga_to_hps_in_write <= 1'b0 ;
		data_buffer_valid <= 1'b0 ; // used the data, so clear flag
		FPGA_to_HPS_state <= 8'd8 ;
	end
	
	// another delay state to see if we need some write time too
	if ((FPGA_to_HPS_state == 8) && (data_buffer_valid == 1'b0))begin
		data_buffer_valid <= 1'b0 ; // used the data, so clear flag
			FPGA_to_HPS_state <= 8'd0 ;
	end
	
	
	//==================================
end // always @(posedge state_clock)


//=======================================================
//  Structural coding
//=======================================================
// From Qsys

Computer_System The_System (
	////////////////////////////////////
	// FPGA Side
	////////////////////////////////////

	// Global signals
	.system_pll_ref_clk_clk					(CLOCK_50),
	.system_pll_ref_reset_reset			(1'b0),
	
	// SRAM shared block with HPS
	.onchip_sram_s1_address               (sram_address),               
	.onchip_sram_s1_clken                 (sram_clken),                 
	.onchip_sram_s1_chipselect            (sram_chipselect),            
	.onchip_sram_s1_write                 (sram_write),                 
	.onchip_sram_s1_readdata              (sram_readdata),              
	.onchip_sram_s1_writedata             (sram_writedata),             
	.onchip_sram_s1_byteenable            (4'b1111), 

	// 50 MHz clock bridge
	.clock_bridge_0_in_clk_clk            (CLOCK_50), //(CLOCK_50), 
	
	// HPS to FPGA FIFO
	.fifo_hps_to_fpga_out_readdata      (hps_to_fpga_readdata),      //  fifo_hps_to_fpga_out.readdata
	.fifo_hps_to_fpga_out_read          (hps_to_fpga_read),          //   out.read
	.fifo_hps_to_fpga_out_waitrequest   (),                            //   out.waitrequest
	.fifo_hps_to_fpga_out_csr_address   (32'd1), //(hps_to_fpga_out_csr_address),   // fifo_hps_to_fpga_out_csr.address
	.fifo_hps_to_fpga_out_csr_read      (1'b1), //(hps_to_fpga_out_csr_read),      //   csr.read
	.fifo_hps_to_fpga_out_csr_writedata (),                              //   csr.writedata
	.fifo_hps_to_fpga_out_csr_write     (1'b0),                           //   csr.write
	.fifo_hps_to_fpga_out_csr_readdata  (hps_to_fpga_out_csr_readdata),		//   csr.readdata
	
	// FPGA to HPS FIFO
	.fifo_fpga_to_hps_in_writedata      (fpga_to_hps_in_writedata),      // fifo_fpga_to_hps_in.writedata
	.fifo_fpga_to_hps_in_write          (fpga_to_hps_in_write),          //                     .write
	.fifo_fpga_to_hps_in_csr_address    (32'd1), //(fpga_to_hps_in_csr_address),    //  fifo_fpga_to_hps_in_csr.address
	.fifo_fpga_to_hps_in_csr_read       (1'b1), //(fpga_to_hps_in_csr_read),       //                         .read
	.fifo_fpga_to_hps_in_csr_writedata  (),  //                         .writedata
	.fifo_fpga_to_hps_in_csr_write      (1'b0),      //                         .write
	.fifo_fpga_to_hps_in_csr_readdata   (fpga_to_hps_in_csr_readdata),    //                         .readdata
	
	////////////////////////////////////
	// HPS Side
	////////////////////////////////////
	// DDR3 SDRAM
	.memory_mem_a			(HPS_DDR3_ADDR),
	.memory_mem_ba			(HPS_DDR3_BA),
	.memory_mem_ck			(HPS_DDR3_CK_P),
	.memory_mem_ck_n		(HPS_DDR3_CK_N),
	.memory_mem_cke		(HPS_DDR3_CKE),
	.memory_mem_cs_n		(HPS_DDR3_CS_N),
	.memory_mem_ras_n		(HPS_DDR3_RAS_N),
	.memory_mem_cas_n		(HPS_DDR3_CAS_N),
	.memory_mem_we_n		(HPS_DDR3_WE_N),
	.memory_mem_reset_n	(HPS_DDR3_RESET_N),
	.memory_mem_dq			(HPS_DDR3_DQ),
	.memory_mem_dqs		(HPS_DDR3_DQS_P),
	.memory_mem_dqs_n		(HPS_DDR3_DQS_N),
	.memory_mem_odt		(HPS_DDR3_ODT),
	.memory_mem_dm			(HPS_DDR3_DM),
	.memory_oct_rzqin		(HPS_DDR3_RZQ),
		  
	// Ethernet
	.hps_io_hps_io_gpio_inst_GPIO35	(HPS_ENET_INT_N),
	.hps_io_hps_io_emac1_inst_TX_CLK	(HPS_ENET_GTX_CLK),
	.hps_io_hps_io_emac1_inst_TXD0	(HPS_ENET_TX_DATA[0]),
	.hps_io_hps_io_emac1_inst_TXD1	(HPS_ENET_TX_DATA[1]),
	.hps_io_hps_io_emac1_inst_TXD2	(HPS_ENET_TX_DATA[2]),
	.hps_io_hps_io_emac1_inst_TXD3	(HPS_ENET_TX_DATA[3]),
	.hps_io_hps_io_emac1_inst_RXD0	(HPS_ENET_RX_DATA[0]),
	.hps_io_hps_io_emac1_inst_MDIO	(HPS_ENET_MDIO),
	.hps_io_hps_io_emac1_inst_MDC		(HPS_ENET_MDC),
	.hps_io_hps_io_emac1_inst_RX_CTL	(HPS_ENET_RX_DV),
	.hps_io_hps_io_emac1_inst_TX_CTL	(HPS_ENET_TX_EN),
	.hps_io_hps_io_emac1_inst_RX_CLK	(HPS_ENET_RX_CLK),
	.hps_io_hps_io_emac1_inst_RXD1	(HPS_ENET_RX_DATA[1]),
	.hps_io_hps_io_emac1_inst_RXD2	(HPS_ENET_RX_DATA[2]),
	.hps_io_hps_io_emac1_inst_RXD3	(HPS_ENET_RX_DATA[3]),

	// Flash
	.hps_io_hps_io_qspi_inst_IO0	(HPS_FLASH_DATA[0]),
	.hps_io_hps_io_qspi_inst_IO1	(HPS_FLASH_DATA[1]),
	.hps_io_hps_io_qspi_inst_IO2	(HPS_FLASH_DATA[2]),
	.hps_io_hps_io_qspi_inst_IO3	(HPS_FLASH_DATA[3]),
	.hps_io_hps_io_qspi_inst_SS0	(HPS_FLASH_NCSO),
	.hps_io_hps_io_qspi_inst_CLK	(HPS_FLASH_DCLK),

	// Accelerometer
	.hps_io_hps_io_gpio_inst_GPIO61	(HPS_GSENSOR_INT),

	//.adc_sclk                        (ADC_SCLK),
	//.adc_cs_n                        (ADC_CS_N),
	//.adc_dout                        (ADC_DOUT),
	//.adc_din                         (ADC_DIN),

	// General Purpose I/O
	.hps_io_hps_io_gpio_inst_GPIO40	(HPS_GPIO[0]),
	.hps_io_hps_io_gpio_inst_GPIO41	(HPS_GPIO[1]),

	// I2C
	.hps_io_hps_io_gpio_inst_GPIO48	(HPS_I2C_CONTROL),
	.hps_io_hps_io_i2c0_inst_SDA		(HPS_I2C1_SDAT),
	.hps_io_hps_io_i2c0_inst_SCL		(HPS_I2C1_SCLK),
	.hps_io_hps_io_i2c1_inst_SDA		(HPS_I2C2_SDAT),
	.hps_io_hps_io_i2c1_inst_SCL		(HPS_I2C2_SCLK),

	// Pushbutton
	.hps_io_hps_io_gpio_inst_GPIO54	(HPS_KEY),

	// LED
	.hps_io_hps_io_gpio_inst_GPIO53	(HPS_LED),

	// SD Card
	.hps_io_hps_io_sdio_inst_CMD	(HPS_SD_CMD),
	.hps_io_hps_io_sdio_inst_D0	(HPS_SD_DATA[0]),
	.hps_io_hps_io_sdio_inst_D1	(HPS_SD_DATA[1]),
	.hps_io_hps_io_sdio_inst_CLK	(HPS_SD_CLK),
	.hps_io_hps_io_sdio_inst_D2	(HPS_SD_DATA[2]),
	.hps_io_hps_io_sdio_inst_D3	(HPS_SD_DATA[3]),

	// SPI
	.hps_io_hps_io_spim1_inst_CLK		(HPS_SPIM_CLK),
	.hps_io_hps_io_spim1_inst_MOSI	(HPS_SPIM_MOSI),
	.hps_io_hps_io_spim1_inst_MISO	(HPS_SPIM_MISO),
	.hps_io_hps_io_spim1_inst_SS0		(HPS_SPIM_SS),

	// UART
	.hps_io_hps_io_uart0_inst_RX	(HPS_UART_RX),
	.hps_io_hps_io_uart0_inst_TX	(HPS_UART_TX),

	// USB
	.hps_io_hps_io_gpio_inst_GPIO09	(HPS_CONV_USB_N),
	.hps_io_hps_io_usb1_inst_D0		(HPS_USB_DATA[0]),
	.hps_io_hps_io_usb1_inst_D1		(HPS_USB_DATA[1]),
	.hps_io_hps_io_usb1_inst_D2		(HPS_USB_DATA[2]),
	.hps_io_hps_io_usb1_inst_D3		(HPS_USB_DATA[3]),
	.hps_io_hps_io_usb1_inst_D4		(HPS_USB_DATA[4]),
	.hps_io_hps_io_usb1_inst_D5		(HPS_USB_DATA[5]),
	.hps_io_hps_io_usb1_inst_D6		(HPS_USB_DATA[6]),
	.hps_io_hps_io_usb1_inst_D7		(HPS_USB_DATA[7]),
	.hps_io_hps_io_usb1_inst_CLK		(HPS_USB_CLKOUT),
	.hps_io_hps_io_usb1_inst_STP		(HPS_USB_STP),
	.hps_io_hps_io_usb1_inst_DIR		(HPS_USB_DIR),
	.hps_io_hps_io_usb1_inst_NXT		(HPS_USB_NXT) //,
	
);
endmodule // end top level

