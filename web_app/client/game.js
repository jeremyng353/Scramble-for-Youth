import {Map} from "./map.js";

class Game {
    constructor(mapWidth, tileSize, playerUnits, socket, canvas, ctx, playerNum, map, aiCounter) {
        this.map = new Map(mapWidth, tileSize, ctx, playerNum, playerUnits);
        this.mapWidth = mapWidth;

        this.playerUnits = playerUnits;         // 2d array, indexed by player number
        this.playerPoints = [];
        for (let i = 1; i <= 4; i++) {
            this.playerPoints[i] = 0;
        }
        
        this.socket = socket;

        this.round = 1;
        this.won = false;
        this.aiCounter = aiCounter;
        this.aiMoveCounter = 0;

        // moved down here to allow time for server's response
        this.map.map = map;
        this.map.calculateViewRange(this.playerUnits);
        
        this.socket.addEventListener("message", (event) => {
            let data = JSON.parse(event.data).data;
            console.log(`received ${data.type}`);
            if (data.playerNum != this.playerNum){
            switch (data.type) {
                case "status-message":
                    $("#status-message").text(data.message);
                    break;
                    
                case "game-state":
                    this.map.map = data.map;
                    data.playerUnits[0] = [];
                    this.playerUnits = data.playerUnits;
                    this.playerPoints = data.playerPoints;
                    this.playerTurn = data.playerTurn;
                    this.map.drawMap(this.playerUnits);
                    this.updatePoints();
                    if (data.winnerNum) {
                        this.gameOver(data.winnerNum);
                    }
                    if (this.playerTurn == this.playerNum) {
                        this.startTurn();
                    }
                    break;

                case "attack":
                    if (data.playerNum == this.playerNum) {
                        this.updateLeftUI(data.unitNum + 1, -1 * data.damage);
                    }
                    break;

                case "player-turn":
                    $("#player-turn").text(`Player ${data.playerNum}'s turn.`);
                    break;

                case "round":
                    this.round = data.roundNum;
                    $("#game-round").text(`Round ${this.round}`);
                    break;

                case "gm-win":
                    this.gmWin();
                    break;
            }
        }
        })

        // game master listener
        // game logic is done on client side for the game master, so the game state isn't sent to other clients again
        this.socket.addEventListener("message", (event) => {
            if (this.playerTurn == 5) {
                let data = JSON.parse(event.data).data;
                switch(data.type) {
                    case "lightning":
                        if (this.map.map[data.coords.i][data.coords.j].player != 0) {
                            this.attack(
                                {"atkDmg": 3},
                                this.playerUnits[this.map.map[data.coords.i][data.coords.j].player][this.map.map[data.coords.i][data.coords.j].id],
                                {"i": data.coords.i, "j": data.coords.j}
                            );
                        }
                        
                        break;

                    case "hurricane":
                        if (this.map.map[data.initCoords.i][data.initCoords.j].player != 0 && 
                            this.map.map[data.finalCoords.i][data.finalCoords.j].player != 0 &&
                            this.map.map[data.finalCoords.i][data.finalCoords.j].type != 2) {
                                this.map.lastUnitSelected = {"i": data.initCoords.i, "j": data.initCoords.j};
                                let statusMessage = `A hurricane moved Player ${this.map.map[data.initCoords.i][data.initCoords.j].player}'s unit ${this.map.map[data.initCoords.i][data.initCoords.j].id + 1}!`;
                                $("#status-message").text(statusMessage);
                                this.map.moveUnit(
                                    data.finalCoords, 
                                    this.map.map[data.initCoords.i][data.initCoords.j].player,
                                    this.map.map[data.initCoords.i][data.initCoords.j].id
                                );
                                let wind = new Audio("assets/wind.wav");
                                wind.play();
                                // TODO: i don't think that the status message needs to be sent since every client handles
                                //       the gm on its own, but change this if problems arise
                                // this.sendGameState("status-message", statusMessage);
                        }
                        break;

                    case "moveWall":
                        if (this.map.map[data.initCoords.i][data.initCoords.j].type == 2 && 
                            this.map.map[data.finalCoords.i][data.finalCoords.j].type == 0 &&
                            this.map.map[data.finalCoords.i][data.finalCoords.j].player == 0) {
                                this.map.map[data.initCoords.i][data.initCoords.j].type = 0;
                                this.map.map[data.finalCoords.i][data.finalCoords.j].type = 2;
                                let statusMessage = `A wall was moved.`;
                                $("#status-message").text(statusMessage);
                                let brick = new Audio("assets/brick.wav");
                                brick.play();
                                // TODO: i don't think that the status message needs to be sent since every client handles
                                //       the gm on its own, but change this if problems arise
                                // this.sendGameState("status-message", statusMessage);
                        }
                        break;
                }
                this.map.drawMap(this.playerUnits);
                this.endTurn();
            }
        })

        // ai listener
        this.socket.addEventListener("message", (event) => {
            console.log("WERE HERE");
            /*
                {
                    "type": "move" or "attack",
                    "coords": {"i": x, "j": y},
                    "unitID": unitID
                }
            */
           console.log(`ai num ${this.playerTurn > 4 - this.aiCounter}`);
            if (this.playerTurn > 4 - this.aiCounter) {
                let data = JSON.parse(event.data).data;
                switch(data.type) {
                    case "aiMove": 
                        // TODO: check if move is in range
                        console.log("move");
                        for (let i = 0; i < this.mapWidth; i++) {
                            for (let j = 0; j < this.mapWidth; j++) {
                                if (this.map.map[i][j].player == this.playerTurn && this.map.map[i][j].id == data.unitID) {
                                    this.map.lastUnitSelected = {"i": i, "j": j};
                                }
                            }
                        }
                        this.map.moveUnit(data.coords, this.playerTurn, data.unitID)
                        break;

                    case "aiAttack":
                        // TODO: check if attack is in rage
                        console.log("attack")
                        this.attack(this.playerUnits[this.playerTurn][data.unitID], this.playerUnits[this.playerTurn][data.unitID], data.coords);
                        break;
                }
                if (data.type == "aiMove" || data.type == "aiAttack"){
                    this.map.drawMap(this.playerUnits);
                    this.aiMoveCounter++;
                    if (this.aiMoveCounter == 3) {
                        this.aiMoveCounter = 0;
                        this.endTurn(true);
                    }
                }
            }
        })

        this.canvas = canvas;
        this.ctx = ctx;

        // game constants
        this.movesPerTurn = 3;
        this.pointsToWin = 7; 

        // local player values
        this.moveCounter = 0;
        this.playerNum = playerNum;
        
        // game state values
        this.moving = 0;
        this.attacking = 0;
        this.playerTurn = 1;
        this.selectedUnit = {};
        this.selectedUnitCoords = {};
        this.accelerometerListener = false;
        this.accelerometerListenerActive = false;

        // UI value
        this.highlighted = false;
        this.highlightedTileCoords;

        this.enableLeftUI();
    }

    startTurn() {
        // check if any units can be revived
        $("#player-turn").text(`Player ${this.playerNum}'s turn.`);
        this.socket.send(JSON.stringify({
            "type": "player-turn",
            "playerNum": this.playerNum
        }))
        let statusMessage;
        statusMessage = this.playerTurn == 1 ? $("#status-message").text() : "";
        console.log(JSON.stringify(this.playerUnits[this.playerTurn]));
        this.playerUnits[this.playerTurn].forEach(unit => {
            if (!unit.alive) {
                unit.respawnTimer++;
                if (unit.respawnTimer == 2) {
                    unit.respawnTimer = 0;
                    unit.alive = true;
                    unit.hp = unit.maxHp;
                    this.updateLeftUI(unit.id + 1, unit.maxHp);
                    this.map.respawn(unit, this.playerUnits);
                    statusMessage = statusMessage.concat(`Player ${this.playerTurn}'s unit ${unit.id + 1} respawned.\n`);
                    this.sendGameState("game-state");
                }
                this.copyChanges(unit);
            }
        })

        $("#status-message").text(statusMessage);
        this.sendGameState("status-message", statusMessage);

        document.getElementById("turn-btn").style.display = "block";
        $("#turn-btn").on("click", () => {this.endTurn();})

        // use => to maintain the scope of 'this' to be the defining scope and jquery to disable anonymous eventlisteners
        $("#game").on("click", (event) => {
            console.log(`player ${this.playerTurn}'s turn`);

            if (event.button == 0) {
                let highlight = false;
                if (this.playerTurn == this.playerNum) {
                    let tileData = this.map.findTile(event);
                    let tileCoords = {"i": tileData.i, "j": tileData.j};

                    console.log(`tileCoords: ${JSON.stringify(tileCoords)}`);
                    console.log(`map description at tileCoords: ${JSON.stringify(this.map.map[tileCoords.i][tileCoords.j])}`);

                    if (this.moveCounter >= this.movesPerTurn) {
                        $("#status-message").text("No moves remaining.");
                        $("#end-turn").addClass("shake");
                        setTimeout(() => {
                            $("#end-turn").removeClass("shake");
                        }, 500)
                    } else if (tileData.tile.player != 0 && 
                        this.playerUnits[this.map.map[tileCoords.i][tileCoords.j].player][this.map.map[tileCoords.i][tileCoords.j].id].moved) {
                            $("#status-message").text("This unit moved already.");
                    } else {
                        if (tileData.tile.player == this.playerTurn) {
                            if (this.moving || this.attacking) {
                                // cancel attack/move
                                this.map.disableRange(() => {this.moving = 0; this.attacking = 0});
                            } else {
                                // show move range
                                this.moving = 1;
                                this.selectedUnit = this.playerUnits[this.map.map[tileCoords.i][tileCoords.j].player][this.map.map[tileCoords.i][tileCoords.j].id];
                                this.selectedUnitCoords = tileCoords;
                                this.map.enableRange(tileCoords, this.selectedUnit.moveRange, this.playerTurn, "move");
                                highlight = true;
                            }
                        } else {
                            if (this.moving) {
                                if (tileData.tile.type != 2 && tileData.tile.player == 0 && tileData.tile.moveRange) {
                                    // move to selected tile
                                    this.highlightedTileCoords = tileCoords;
                                    this.map.moveUnit(tileCoords, this.playerTurn, this.selectedUnit.id);
                                    this.map.disableRange(() => {this.moving = 0; this.attacking = 0});
                                    let grass = new Audio("assets/grass.wav");
                                    grass.play();
                                    this.finishMove(this.selectedUnit);  
                                } else if (tileData.tile.type != 0) {
                                    $("#status-message").text("That tile is occupied.");
                                } else if (tileData.tile.type == 2) {
                                    $("#status-message").text("That tile is a wall.");
                                }
                            } else if (this.attacking) {
                                if (tileData.tile.atkRange && tileData.tile.player != 0 && tileData.tile.player != this.playerTurn) {
                                    // attack selected tile
                                    let defendingUnit = this.playerUnits[this.map.map[tileCoords.i][tileCoords.j].player][this.map.map[tileCoords.i][tileCoords.j].id];
                                    /*  accelerometer attack
                                    this.attackAccelerometer(this.selectedUnit, defendingUnit, tileCoords, this.selectedUnitCoords);
                                    */
                                    this.attack(
                                        this.selectedUnit, 
                                        defendingUnit,
                                        tileCoords  
                                    )
                                    
                                    this.socket.send(JSON.stringify({
                                        "type": "attack",
                                        "playerNum": defendingUnit.player,
                                        "damage": this.selectedUnit.atkDmg,
                                        "unitNum": defendingUnit.id
                                    }))
                                    
                                    this.map.disableRange(() => {this.moving = 0; this.attacking = 0});
                                    this.finishMove(this.selectedUnit);
                                }
                            }
                            console.log(`moveCounter: ${this.moveCounter}`);
                        }
                
                        // change values on map array and then rerender
                        this.map.drawMap(this.playerUnits);
                        if (highlight) {
                            this.map.highlightUnit(tileCoords, true);
                        }
                    }
                }
            }
        });

        $("#game").on("contextmenu", (event) => {
            event.preventDefault();
            if (event.button == 2 && !this.moving) {
                let tileData = this.map.findTile(event);
                let tileCoords = {"i": tileData.i, "j": tileData.j};
                if (this.moveCounter >= this.movesPerTurn) {
                    $("#status-message").text("No moves remaining.");
                    $("#end-turn").addClass("shake");
                    setTimeout(() => {
                        $("#end-turn").removeClass("shake");
                    }, 500)
                } else if (tileData.tile.player != 0 && 
                    this.playerUnits[this.map.map[tileCoords.i][tileCoords.j].player][this.map.map[tileCoords.i][tileCoords.j].id].moved) {
                        $("#status-message").text("This unit moved already.");
                } else {                
                    if (tileData.tile.player == this.playerTurn) {
                        this.attacking = 1;
                        let tileCoords = {"i": tileData.i, "j": tileData.j};
                        this.selectedUnit = this.playerUnits[this.map.map[tileCoords.i][tileCoords.j].player][this.map.map[tileCoords.i][tileCoords.j].id];
                        this.selectedUnitCoords = tileCoords;
                        this.map.enableRange(tileCoords, this.selectedUnit.atkRange, this.playerTurn, "attack");
                        this.map.drawMap(this.playerUnits);
                        this.map.highlightUnit(tileCoords, true);
                    }
                }
            }
        });
    }

    finishMove(unit) {
        this.moveCounter++;
        unit.moved = true;
        this.sendGameState("game-state");
    }

    endTurn(ai) {
        this.map.disableRange(() => {this.moving = 0; this.attacking = 0});
        if (this.highlighted) {
            this.map.highlightUnit(this.highlightedTileCoords, false);
        }
        this.moveCounter = 0;
        console.log(JSON.stringify(this.playerUnits));
        this.playerUnits.forEach(arr => {
            arr.forEach(unit => unit.moved = false);
        })

        this.map.updatePoints(this.playerPoints);
        
        this.updatePoints();

        let winnerNum;
        for (let i = 1; i <= 4; i++) {
            if (this.playerPoints[i] >= this.pointsToWin) {
                this.gameOver(i);
                winnerNum = i;
                this.won = true;
            }
        }

        if (!this.won) {
            if (this.round == 7 && this.playerTurn == 4) {
                this.socket.send(JSON.stringify({
                    "type": "gm-win",
                }))
                this.gmWin();
            }
        }

        /*  TODO: uncomment this once gm is implemented
        if (!this.won) {
            if (this.round == 7 && this.playerTurn == 4) {
                this.socket.send(JSON.stringify({
                    "type": "gm-win",
                }))
                this.gmWin();
            }
        }
        */

        /*  TODO: uncomment this once gm is implemented

        if (this.playerTurn == 5) {
            this.playerTurn = 1;
            this.round++;
            $("#game-round").text(`Round ${this.round}`);
            this.socket.send(JSON.stringify({
                "type": "round",
                "roundNum": this.round
            }))
        } else {
            this.playerTurn++;
        }
        */

        if (this.playerTurn == 4) {
            this.playerTurn = 1;
            this.round++;
            $("#game-round").text(`Round ${this.round}`);
            this.socket.send(JSON.stringify({
                "type": "round",
                "roundNum": this.round
            }))
        } else {
            this.playerTurn++;
        }
        
        if (!ai) {
            this.sendGameState("game-state", "", winnerNum);
        }
        
        $("#game").off();
        $("#turn-btn").off();
        document.getElementById("turn-btn").style.display = "none";
    }

    sendGameState(type, message, winnerNum) {
        console.log("sending game state");
        if (type == "status-message") {
            this.socket.send(JSON.stringify({
                "type": type,
                "message": message
            }));
        } else if (type == "game-state") {
            this.socket.send(JSON.stringify({
                "type": type,
                "map": this.map.map,
                "playerUnits": this.playerUnits,
                "playerPoints": this.playerPoints,
                "playerTurn": this.playerTurn,
                "winnerNum": winnerNum,
                "playerNum": this.playerNum,
                "ai": this.playerTurn > 4 - this.aiCounter
            }));
        }
    }

    attackAccelerometer(attacker, defender, tileCoords, selectedUnitCoords) {
        let slopeMagnitude = Math.sqrt(Math.pow(tileCoords.i - selectedUnitCoords.i, 2) + Math.pow(tileCoords.j - selectedUnitCoords.j, 2));
        let slope = {
            "i": (tileCoords.i - selectedUnitCoords.i) / slopeMagnitude,
            "j": (tileCoords.j - selectedUnitCoords.j) / slopeMagnitude
        }

        this.accelerometerListenerActive = true;
        
        if (!this.accelerometerListener) {
            this.socket.addEventListener("message", (event) => {
                let data = JSON.parse(event.data).data;
                if (data.type == "attack") {
                    let percentage = data.magnitude / 4500;
                    if (percentage > 1) {
                        percentage = 1;
                    }
    
                    let finalCoords = {
                        "i": Math.round(percentage * slope.i) + selectedUnitCoords.i,
                        "j": Math.round(percentage * slope.j) + selectedUnitCoords.j
                    }
    
                    if (this.map[finalCoords.i][final.j].player != this.playerTurn) {
                        this.attack(attacker, this.playerUnits[this.map[finalCoords.i][final.j].player][this.map[finalCoords.i][final.j].id], finalCoords);
                        this.socket.send(JSON.stringify({
                            "type": "attack",
                            "playerNum": defendingUnit.player,
                            "damage": this.selectedUnit.atkDmg,
                            "unitNum": defendingUnit.id
                        }))
                        
                        this.map.disableRange(() => {this.moving = 0; this.attacking = 0});
                        this.finishMove(attacker);
                    }

                    this.accelerometerListenerActive = false;
                }
            })
            this.accelerometerListener = true;
        }
    }

    attack(attacker, defender, tileCoords) {
        if (!defender && this.playerTurn != 5) {
            let statusMessage = `Player ${attacker.player}'s unit ${attacker.id + 1} missed!`;
            $("#status-message").text(statusMessage);
            this.sendGameState("status-message", statusMessage);
            return;
        }

        defender.hp -= attacker.atkDmg;
        let statusMessage = `Player ${defender.player}'s unit ${defender.id + 1} took ${attacker.atkDmg} damage`;
        if (this.playerTurn == 5) {
            statusMessage = statusMessage + " from lightning.";
            let lightning = new Audio("assets/lightning.wav");
            lightning.play();
        } else {
            statusMessage = statusMessage + ".";
            let pan = new Audio("assets/pan.wav");
            pan.play();
        }

        if (defender.hp <= 0) {
            defender.hp = 0;
            defender.alive = false;
            statusMessage = statusMessage.concat(` It died!`);
            this.map.removeUnit(tileCoords);
        }

        $("#status-message").text(statusMessage);
        this.sendGameState("status-message", statusMessage);

        this.copyChanges(defender);
    }

    // TODO: test if this function is even necessary since js passes objects by reference
    copyChanges(unit) {
        this.playerUnits[unit.player][unit.id] = unit;
    }

    updatePoints() {
        for (let i = 1; i < this.playerPoints.length; i++) {
            $(`#${i}`).text(`${this.playerPoints[i]}`);
        } 
    }

    updateLeftUI(unitNum, healthChange) {
        console.log(`healthChange: ${healthChange}`);
        for (let ele of document.getElementsByClassName("unit")) {
            if (ele.textContent.match(/[0-9]/)[0] == unitNum) {
                let newHp = parseInt(ele.firstElementChild.lastElementChild.style.width.match(/[0-9]*/)) + healthChange * 10;
                if (newHp < 0) {
                    newHp = 0;
                }
                ele.firstElementChild.lastElementChild.style.width = String(newHp) + "%";
                ele.firstElementChild.lastElementChild.ariaValueNow = newHp;
                return;
            }
        }
    }

    enableLeftUI() {
        for (let ele of document.getElementsByClassName("unit")) {
            ele.addEventListener("click", () => {
                if (this.highlighted) {
                    this.map.highlightUnit(this.highlightedTileCoords, false);
                    this.highlighted = false;
                }

                for (let i = 0; i < this.mapWidth; i++) {
                    for (let j = 0; j < this.mapWidth; j++) {
                        if (this.map.map[i][j].player == this.playerNum && this.map.map[i][j].id == ele.textContent.match(/[0-9]/)[0]) {
                            this.highlightedTileCoords = {"i": i, "j": j};
                            console.log(this.highlightedTileCoords);
                            this.map.highlightUnit(this.highlightedTileCoords, true);
                            this.highlighted = true;
                            return;
                        }
                    }
                }
            });
        }
    }

    gameOver(winnerNum) {
        $("#game-over").prepend(document.getElementById("player-points")).prepend(`<h1>Player ${winnerNum} won!</h1>`);
        document.getElementById("game-view").style.display = "none"
        document.getElementById("game-over").style.display = "block";
        this.won = true;
    }

    gmWin() {
        $("#game-over").prepend(document.getElementById("player-points")).prepend(`<h1>The game master won!</h1>`);
        document.getElementById("game-view").style.display = "none"
        document.getElementById("game-over").style.display = "block";
        this.won = true;
    }
}

export {Game};