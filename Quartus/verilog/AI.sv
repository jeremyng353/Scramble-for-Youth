typedef struct {
	reg [3:0] x;
	reg [3:0] y;
	reg alive; // 1 if alive, 0 if dead	
	reg [3:0] moveDist;
	reg [3:0] attackDist;
	reg [3:0] attackDam;
} pieceInfo;

typedef struct {
	pieceInfo piece1;
	pieceInfo piece2;
	pieceInfo piece3;
	pieceInfo piece4;
	pieceInfo piece5;
}  playerInfo;


// return data type
typedef struct {
	reg [2:0] MovePiece; // which piece is being moved, 1-5
	reg [13:0] MoveLocX; // where to move/attack at 0-13
	reg [13:0] MoveLocY; 
	reg MoveAttOrMov; // 0 is move, 1 is attack
} MoveInfo;

// input command to game master
typedef struct {
	reg [783:0] mapData; // same structure as game master
	playerInfo AIplayer; // Info for the player AI
	reg [2:0] AIPlayerNum; // what player is the AI? 1,2,3,4
} AIcommand;




`define  RESET_AI					8'd0
`define 	NEW_MOVE					8'd1
`define 	MAKE_MOVE 				8'd5
`define  NEW_PIECE				8'd2
`define 	GET_PIECE_INFO			8'd3
`define  CHECK_PIECE_INFO		8'd4
`define  START_MOVE_TESTING	8'd6
`define  CHECK_LOC_VALID 		8'd7
`define  NEXT_LOC					8'd8
`define  START_CHECK_PATH		8'd9
`define  CHECK_CHANGE_X			8'd10
`define 	CHANGE_X					8'd11
`define  CHECK_LOCATION_X		8'd12
`define  CHANGE_Y					8'd13
`define  CHECK_LOCATION_Y		8'd14
`define  CALC_SCORE_MOVE		8'd15
`define  COMPARE_MOVE_SCORE  	8'd16
`define 	MAKE_MOVE_2				8'd17

`define 	START_ATTACK_TESTING		8'd18
`define  CHECK_LOC_VALID_ATK 		8'd19
`define  NEXT_LOC_ATK				8'd20
`define  CALC_SCORE_MOVE_ATK		8'd21
`define  COMPARE_MOVE_SCORE_ATK 	8'd22

//`define 	START_X_ATK				8'd19
//`define 	START_Y_ATK				8'd20
//`define 	ATK_NEXT_X				8'd21
//`define 	ATK_NEXT_Y				8'd22
//`define 	CHECK_SPOT_ATK			8'd23
//`define 	ATK_SCORE				8'd24
//`define 	ATK_COMPARE_SCORE		8'd25
`define 	END						8'd200


module AI(
	input clk,
	input reset, // use reset to start
	input AIcommand AIcmd,
	output MoveInfo Move1Info,
	output MoveInfo Move2Info,
	output MoveInfo Move3Info,
	output reg done
);
reg[3:0] error; // basic error signal 

reg[783:0] currMapData; // local version so it can be changed

reg addMove = 0; // turn to 1 for 1 clk cycle to add the move
reg [7:0] AI_state = 0;


MoveInfo newMove; // move to insert 
reg[1:0] moveNum = 0;
reg[2:0] currPiece = 0; // piece being tested right now. 1-5
reg[4:0] pieceUsed = 0; // bitwise if a piece has used it turn already. ie [0] = 1 means piece 1 has moved 


// Getting data from MapData
reg[3:0] locInfo; // the data for a specific location
reg[3:0] getX;
reg[3:0] getY;
reg[9:0] index; // 2^10 = 1024, so enough room for every index in mapData
assign index = (getX + getY * 14) * 4;
assign locInfo = currMapData[index +: 4];


reg[5:0] destX; // the destination being tested 
reg[5:0] destY;
reg[5:0] currX; // locations for testing path finding
reg[5:0] currY;
//reg[5:0] distance;
reg Xadd; // 1 if adding 1 when changing X
reg Yadd; // 1 if adding 1 when changing Y


reg [7:0] currBestScore = 0;
reg [7:0] score = 0;

// used in combination logic and in sequential
reg[5:0] abs_diffX; // these 2 use X+1 and Y+1 because thats the place it is checking
reg[5:0] abs_diffY;
reg[5:0] abs_diffX2; // these 2 check the current X and Y
reg[5:0] abs_diffY2;
reg[5:0] deltaMove;


pieceInfo currPieceInfo; // info of piece currently being used


// info for attacks
reg atk_Y; // is 0 if currently updated along X values, 1 if updating along Y values
// also used in combinational logic
reg[5:0] distXdiff; 
reg[5:0] distYdiff;


always @(posedge clk) begin
	// update MoveInfo to the next
	if (addMove) begin
		Move1Info <= Move2Info;
		Move2Info <= Move3Info;
		Move3Info <= newMove;
	end
	
	// main state machine
	if (reset) begin
		AI_state <= `RESET_AI;
		newMove.MovePiece <= 3'b111; // 
		error <= 0; // basic error signal
		done <= 0;
	end
	else begin 
		case (AI_state) 
			`RESET_AI: begin
				currMapData <= AIcmd.mapData; 
				currPiece <= 0;
				AI_state <= `NEW_MOVE;
				moveNum <= 0;
				addMove <= 0;
				pieceUsed <= 0;
				done <= 0;
			end
			`MAKE_MOVE: begin
				addMove <= 1;
				if (newMove.MovePiece != 3'b111) begin// make sure a move was actually made
					//pieceUsed[currPiece - 1 +: 1] <= 1'b1;
					pieceUsed <= pieceUsed | (5'b00001 << (newMove.MovePiece-1));
					// remove the old location of the piece in currMapData
					if (newMove.MoveAttOrMov == 0) begin // only for moves, not attacks
						if (newMove.MovePiece == 1) 
							currMapData <= currMapData & ((~(784'b0))/*all 1s*/ & 
															((~(784'b0)) - (784'b1111 << (4 * (14 * AIcmd.AIplayer.piece1.y + AIcmd.AIplayer.piece1.x))))); 
						else if (newMove.MovePiece == 2)
							currMapData <= currMapData & ((~(784'b0))/*all 1s*/ & 
															((~(784'b0)) - (784'b1111 << (4 * (14 * AIcmd.AIplayer.piece2.y + AIcmd.AIplayer.piece2.x))))); 
						else if (newMove.MovePiece == 3)
							currMapData <= currMapData & ((~(784'b0))/*all 1s*/ & 
															((~(784'b0)) - (784'b1111 << (4 * (14 * AIcmd.AIplayer.piece3.y + AIcmd.AIplayer.piece3.x))))); 
						else if (newMove.MovePiece == 4)
							currMapData <= currMapData & ((~(784'b0))/*all 1s*/ & 
															((~(784'b0)) - (784'b1111 << (4 * (14 * AIcmd.AIplayer.piece4.y + AIcmd.AIplayer.piece4.x))))); 
						else
							currMapData <= currMapData & ((~(784'b0))/*all 1s*/ & 
															((~(784'b0)) - (784'b1111 << (4 * (14 * AIcmd.AIplayer.piece5.y + AIcmd.AIplayer.piece5.x))))); 
						AI_state <= `MAKE_MOVE_2;
					end
					else
						AI_state <= `NEW_MOVE;
				end
				else
					AI_state <= `NEW_MOVE;
			end
			`MAKE_MOVE_2: begin
				addMove <= 0;
				// move in new location of the piece into the data
				currMapData <= currMapData | ({781'b0, AIcmd.AIPlayerNum} << (4 *(14 * newMove.MoveLocY + newMove.MoveLocX)));
				AI_state <= `NEW_MOVE;
			end
			`NEW_MOVE: begin
				moveNum <= moveNum + 1;
				addMove <= 0;
				newMove.MovePiece <= 3'b111; // if the value is still 7, then it never updated
				currBestScore <= 0;
				currPiece <= 0;
				if (moveNum == 3)
					AI_state <= `END;
				else
					AI_state <= `NEW_PIECE;
			end
			`NEW_PIECE: begin
				currPiece <= currPiece + 1;
				if (currPiece == 5) // all pieces done
					AI_state <= `MAKE_MOVE;
				else 
					AI_state <= `GET_PIECE_INFO;
			end
			`GET_PIECE_INFO: begin
				case(currPiece)
					1: currPieceInfo <= AIcmd.AIplayer.piece1;
					2: currPieceInfo <= AIcmd.AIplayer.piece2;
					3: currPieceInfo <= AIcmd.AIplayer.piece3;
					4: currPieceInfo <= AIcmd.AIplayer.piece4;
					5: currPieceInfo <= AIcmd.AIplayer.piece5;
					default: error <= 1; 
				endcase
				AI_state <= `CHECK_PIECE_INFO;
			end
			`CHECK_PIECE_INFO: begin
				if (currPieceInfo.alive == 0 || pieceUsed[currPiece - 1 +: 1] == 1) 
					AI_state <= `NEW_PIECE; // piece can't be used, go to next piece
				else
					AI_state <= `START_MOVE_TESTING;
			end
			
			// testing move
			`START_MOVE_TESTING: begin
				// extra bits added so extra space for when calculation move off the board
				destX <= {2'b0, currPieceInfo.x} - currPieceInfo.moveDist; // start searching on the leftmost spot
				destY <= {2'b0, currPieceInfo.y};
				getX <= {2'b0, currPieceInfo.x} - currPieceInfo.moveDist;
				getY <= {2'b0, currPieceInfo.y};
				AI_state <= `CHECK_LOC_VALID;
			end
			`CHECK_LOC_VALID: begin
				// if not on the board then every location has been checked
				if (abs_diffX2 + abs_diffY2 > currPieceInfo.moveDist) begin
					AI_state <= `START_ATTACK_TESTING; 
				end
				// else, if not valid, check a new spot
				else if (destX[5] == 1  || destY[5] == 1 || // check if negative
					 destX >= 14 || destY >= 14 || // check if >= 14
					 (destX == currPieceInfo.x && destY == currPieceInfo.y) || // location is same spot as piece started in
					 locInfo != 0)   // checks if place is already occupied
					AI_state <= `NEXT_LOC;
				// otherwise see if there is a path there
				else
					AI_state <= `START_CHECK_PATH;
			end
			`NEXT_LOC: begin
				if (abs_diffX + abs_diffY > currPieceInfo.moveDist) begin
					destX <= destX - (currPieceInfo.moveDist - 1);
					destY <= destY - currPieceInfo.moveDist;
					getX <= destX - (currPieceInfo.moveDist - 1);
					getY <= destY - currPieceInfo.moveDist;
				end
				else begin
					destX <= destX + 1;
					destY <= destY + 1;
					getX <= destX + 1;
					getY <= destY + 1;
				end
				AI_state <= `CHECK_LOC_VALID;
			end
			
			
			// check if the path if valid or not
			`START_CHECK_PATH: begin
				currX <= destX;
				currY <= destY;
				AI_state <= `CHECK_CHANGE_X;
			end
			`CHECK_CHANGE_X: begin
				if(currX == currPieceInfo.x && currY == currPieceInfo.y)
					AI_state <= `CALC_SCORE_MOVE; // successful pathfinding, now find how how much it was worth
				else if(currX != currPieceInfo.x)
					AI_state <= `CHANGE_X;
				else // change Y
					AI_state <= `CHANGE_Y;
			end
			`CHANGE_X: begin
				if (currX > currPieceInfo.x) begin
					currX <= currX - 1;
					getX <= currX - 1;
					getY <= currY;
					Xadd <= 0;
				end
				else begin
					currX <= currX + 1;
					getX <= currX + 1;
					getY <= currY;
					Xadd <= 1;
				end
				AI_state <= `CHECK_LOCATION_X;
			end
			`CHECK_LOCATION_X: begin
				if(currX == currPieceInfo.x && currY == currPieceInfo.y)
					AI_state <= `CALC_SCORE_MOVE; // successful pathfinding, now find how how much it was worth				
				else if (locInfo == 0) // go to beginning to make another move
					AI_state <= `CHECK_CHANGE_X;
				else begin // undo the move
					if (currY == currPieceInfo.y)
						AI_state <= `NEXT_LOC;
					else begin
						if (Xadd)
							currX <= currX - 1;
						else
							currX <= currX + 1;
						AI_state <= `CHANGE_Y;
					end
				end
			end
			`CHANGE_Y: begin
				if (currY > currPieceInfo.y) begin
					currY <= currY - 1;
					getX <= currX;
					getY <= currY - 1;
				end
				else begin
					currY <= currY + 1;
					getX <= currX;
					getY <= currY + 1;
				end
				AI_state <= `CHECK_LOCATION_Y;
			end
			`CHECK_LOCATION_Y: begin
				if(currX == currPieceInfo.x && currY == currPieceInfo.y)
					AI_state <= `CALC_SCORE_MOVE; // successful pathfinding, now find how how much it was worth				
				else if (locInfo == 0) // go to beginning to make another move
					AI_state <= `CHECK_CHANGE_X;
				else begin // blocked, not a valid move, try a new location
					AI_state <= `NEXT_LOC;
				end
			end
			
			
			// benefit calculation
			`CALC_SCORE_MOVE: begin
				if ((destX == 6 || destX == 7) && (destY == 6 || destY == 7)) // in the point area
					score <= 20;
				else if (deltaMove[5] == 0) // not negative
					score <= deltaMove; // 1 point for each movement towards the center
				else
					score <= 0; // worse
				AI_state <= `COMPARE_MOVE_SCORE; 
			end
			`COMPARE_MOVE_SCORE: begin
				if (score > currBestScore) begin
					currBestScore <= score;
					newMove.MovePiece <= currPiece;
					newMove.MoveLocX <= destX;
					newMove.MoveLocY <= destY; 
					newMove.MoveAttOrMov <= 0; // 0 is move
				end
				AI_state <= `NEXT_LOC; 
			end

			
			
			// =====================================================================================================================
			//	ATACKS --------------------------------------------------------------------------------------------------------------
			// =====================================================================================================================
			// look at attacks 

			
			`START_ATTACK_TESTING: begin
				// extra bits added so extra space for when calculation move off the board
				destX <= {2'b0, currPieceInfo.x} - currPieceInfo.attackDist; // start searching on the leftmost spot
				destY <= {2'b0, currPieceInfo.y};
				getX <= {2'b0, currPieceInfo.x} - currPieceInfo.attackDist;
				getY <= {2'b0, currPieceInfo.y};
				AI_state <= `CHECK_LOC_VALID_ATK;
			end
			`CHECK_LOC_VALID_ATK: begin
				// if not on the board then every location has been checked
				if (abs_diffX2 + abs_diffY2 > currPieceInfo.attackDist) begin
					AI_state <= `NEW_PIECE; 
				end
				// else, if not valid, check a new spot
				else if (destX[5] == 1  || destY[5] == 1 || // check if negative
					 destX >= 14 || destY >= 14 || // check if >= 14
					 (destX == currPieceInfo.x && destY == currPieceInfo.y)) // location is same spot as piece started in
					AI_state <= `NEXT_LOC_ATK;
				// otherwise, see if there is an enemy there
				else if (locInfo != AIcmd.AIPlayerNum && // not on the same team, but still another player's piece
					 (locInfo == 1 || locInfo == 2 || locInfo == 3 || locInfo == 4))
					 AI_state <= `CALC_SCORE_MOVE_ATK;
				// otherwise, check new location
				else
					AI_state <= `NEXT_LOC_ATK;
			end
			`NEXT_LOC_ATK: begin
				if (abs_diffX + abs_diffY > currPieceInfo.attackDist) begin
					destX <= destX - (currPieceInfo.attackDist - 1);
					destY <= destY - currPieceInfo.attackDist;
					getX <= destX - (currPieceInfo.attackDist - 1);
					getY <= destY - currPieceInfo.attackDist;
				end
				else begin
					destX <= destX + 1;
					destY <= destY + 1;
					getX <= destX + 1;
					getY <= destY + 1;
				end
				AI_state <= `CHECK_LOC_VALID_ATK;
			end
						
			// benefit calculation for attacking
			`CALC_SCORE_MOVE_ATK: begin
				if ((destX == 6 || destX == 7) && (destY == 6 || destY == 7)) // attacking into the point area is worth a lot
					score <= 30;
				// more points for attacking near the center
				else 
					score <= ((distXdiff + distYdiff) >> 2) * currPieceInfo.attackDam; // << 2 to divide by 4
				AI_state <= `COMPARE_MOVE_SCORE_ATK;
			end
			`COMPARE_MOVE_SCORE_ATK: begin
				if (score > currBestScore) begin
					currBestScore <= score;
					newMove.MovePiece <= currPiece;
					newMove.MoveLocX <= destX;
					newMove.MoveLocY <= destY; 
					newMove.MoveAttOrMov <= 1; // 1 is attack
				end
				AI_state <= `NEXT_LOC_ATK; 
			end			
			
			
			
			`END: begin
				// does nothing, just waits for reset to happen
				done <= 1;
			end
		
		endcase
	end
	

end
//

reg[5:0] destXPlusOne;
reg[5:0] destYPlusOne;
reg[5:0] neg_destXPlusOne;
reg[5:0] neg_destYPlusOne;
reg[5:0] diffX;
reg[5:0] diffY;
reg[5:0] diffX2;
reg[5:0] diffY2;

// score calculation helper

reg[5:0] distXdiffOrigin; 
reg[5:0] distYdiffOrigin;


always_comb begin
	// find distance between (destX+1)/(DistY+1) and currPieceInfo.x/currPieceInfo.y
	// accounting for negatives using 2s complement
	
	destXPlusOne = destX + 1;
	destYPlusOne = destY + 1;
	
	diffX = destXPlusOne - currPieceInfo.x;
	diffY = destYPlusOne - currPieceInfo.y;
	
	if(diffX[5] == 1)
		abs_diffX = (~diffX) + 1;
	else
		abs_diffX = diffX;
	
	if(diffY[5] == 1)
		abs_diffY = (~diffY) + 1;
	else
		abs_diffY = diffY;
	
	
	diffX2 = destX - currPieceInfo.x;
	diffY2 = destY - currPieceInfo.y;
	
	if(diffX2[5] == 1)
		abs_diffX2 = (~diffX2) + 1;
	else
		abs_diffX2 = diffX2;
	
	if(diffY2[5] == 1)
		abs_diffY2 = (~diffY2) + 1;
	else
		abs_diffY2 = diffY2;
		
		

	// score calculation helper
	if (destX >= 7) 
		distXdiff = destX - 7;
	else 
		distXdiff = 6 - destX;
	if (destY >= 7) 
		distYdiff = destY - 7;
	else
		distYdiff = 6 - destY;
		
	
	if (destX >= 7) 
		distXdiffOrigin = currPieceInfo.x - 7;
	else 
		distXdiffOrigin = 6 - currPieceInfo.x;
	if (destY >= 7) 
		distYdiffOrigin = currPieceInfo.y - 7;
	else
		distYdiffOrigin = 6 - currPieceInfo.y;	
	
	deltaMove = distXdiffOrigin + distYdiffOrigin - distXdiff - distYdiff;

end

//






endmodule


