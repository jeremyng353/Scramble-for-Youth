class Map {
    constructor(mapWidth, tileSize, ctx, playerNum, playerUnits) {
        this.mapWidth = mapWidth;
        this.tileSize = tileSize;

        this.ctx = ctx;
        this.playerNum = playerNum;

        // internal id is 0-4, while front-facing id is 1-5, so +1 whenever displaying status message
        this.map = [];
        this.spawnLocations = [
            [{}],
            [{"i": 0, "j": 0}], 
            [{"i": 0, "j": 12}],
            [{"i": 12, "j": 0}],
            [{"i": 12, "j": 12}],
        ]

        for (let i = 1; i < 5; i++) {
            for (let j = 1; j < 5; j++) {
                switch(j) {
                    case 1:
                        this.spawnLocations[i][j] = {"i": this.spawnLocations[i][0].i, "j": this.spawnLocations[i][0].j + 1};
                        break;
                        
                    case 2:
                        this.spawnLocations[i][j] = {"i": this.spawnLocations[i][0].i + 1, "j": this.spawnLocations[i][0].j};
                        break;

                    case 3:
                        this.spawnLocations[i][j] = {"i": this.spawnLocations[i][0].i + 1, "j": this.spawnLocations[i][0].j + 1};
                        break;
                }
            }
        }

        this.spawnLocations[1].push({"i": 2, "j": 0});
        this.spawnLocations[2].push({"i": 11, "j": 0});
        this.spawnLocations[3].push({"i": 2, "j": 13});
        this.spawnLocations[4].push({"i": 11, "j": 13});

        this.viewMap = [];
        for (let i = 0; i < this.mapWidth; i++) {
            this.viewMap[i] = [];
            for (let j = 0; j < this.mapWidth; j++) {
                this.viewMap[i][j] = false;
            }
        }

        this.emptySpace = image("emptySpace.png");
        this.blueDude = image("blueDude.png");
        this.greenDude = image("greenDude.png");
        this.orangeDude = image("orangeDude.png");
        this.redDude = image("redDude.png");
        this.blueTile = image("blueTile.png");
        this.greenTile = image("greenTile.png");
        this.orangeTile = image("orangeTile.png");
        this.redTile = image("redTile.png");
        this.blueDudeHighlight = image("blueDudeHighlight.png");
        this.greenDudeHighlight = image("greenDudeHighlight.png");
        this.orangeDudeHighlight = image("orangeDudeHighlight.png");
        this.redDudeHighlight = image("redDudeHighlight.png");
        this.wall = image("wall.png");
        this.objective = image("objective.png");
        this.moveRange = image("moveRange.png");
        this.atkRange = image("atkRange.png");
        this.cloud = image("cloud.png");

        this.moveRange.onload = () => {
            setTimeout(() => {
                this.drawMap(playerUnits);
            }, 150);
        }
    }

    drawMap(playerUnits) {
        console.log("drawing map");
        this.calculateViewRange(playerUnits);
        for (let i = 0; i < this.mapWidth; i++) {
            for (let j = 0; j < this.mapWidth; j++) {
                // reset the tile
                this.ctx.drawImage(
                    this.emptySpace,
                    i * this.tileSize,
                    j * this.tileSize,
                    this.tileSize,
                    this.tileSize
                );

                let tile = this.map[i][j];
                let image;
                switch (tile.type) {
                    case 0:
                        image = this.emptySpace;
                        break;

                    case 1:
                        if (i < this.mapWidth / 2 && j < this.mapWidth / 2) {
                            image = this.blueTile;
                        } else if (i < this.mapWidth / 2 && j > this.mapWidth / 2) {
                            image = this.greenTile;
                        } else if (i > this.mapWidth / 2 && j < this.mapWidth / 2) {
                            image = this.orangeTile;
                        } else {
                            image = this.redTile;
                        }
                        break;

                    case 2:
                        image = this.wall;
                        break;

                    case 3:
                        image = this.objective;
                        break;
                }

                if (image) {
                    this.ctx.drawImage(
                        image,
                        i * this.tileSize,
                        j * this.tileSize,
                        this.tileSize,
                        this.tileSize
                    );
                }

                if (tile.player) {
                    switch(tile.player) {
                        case 1: 
                            this.ctx.drawImage(
                                this.blueDude,
                                i * this.tileSize,
                                j * this.tileSize,
                                this.tileSize,
                                this.tileSize
                            );
                            break;

                        case 2:
                            this.ctx.drawImage(
                                this.greenDude,
                                i * this.tileSize,
                                j * this.tileSize,
                                this.tileSize,
                                this.tileSize
                            );
                            break;

                        case 3: 
                            this.ctx.drawImage(
                                this.orangeDude,
                                i * this.tileSize,
                                j * this.tileSize,
                                this.tileSize,
                                this.tileSize
                            );
                            break;

                        case 4:
                            this.ctx.drawImage(
                                this.redDude,
                                i * this.tileSize,
                                j * this.tileSize,
                                this.tileSize,
                                this.tileSize
                            );
                            break;      
                    }
                }

                if (!this.viewMap[i][j]) {
                    this.ctx.drawImage(
                        this.cloud,
                        i * this.tileSize,
                        j * this.tileSize,
                        this.tileSize,
                        this.tileSize
                    );
                }

                if (tile.moveRange) {
                    this.ctx.drawImage(
                        this.moveRange,
                        i * this.tileSize,
                        j * this.tileSize,
                        this.tileSize,
                        this.tileSize
                    );
                }

                if (tile.atkRange) {
                    this.ctx.drawImage(
                        this.atkRange,
                        i * this.tileSize,
                        j * this.tileSize,
                        this.tileSize,
                        this.tileSize
                    );
                }
            }
        }
    }

    enableRange(unitCoords, range, playerTurn, rangeType) {
        this.lastUnitSelected = unitCoords;

        // BFS
        let nextCoords = [unitCoords];
        let rangeCounter = 0;
        while (nextCoords.length != 0 && rangeCounter != range) {
            let tempCoords = [...nextCoords];
            nextCoords = [];
            tempCoords.forEach(coords => {
                for (let i = -1; i <= 1; i++) {
                    for (let j = -1; j <= 1; j++) {
                        if (Math.abs(i + j) == 1) {
                            let final_i = coords.i + i;
                            let final_j = coords.j + j;
                            if (final_i >= 0 && final_i < this.mapWidth && final_j >= 0 && final_j < this.mapWidth) {
                                let tile = this.map[final_i][final_j];
                                let range = rangeType == "move" ? tile.moveRange : tile.atkRange;
                                if (tile.player != playerTurn && !range && tile.type != 2) {
                                    if (rangeType == "move" && tile.player == 0) {
                                        tile.moveRange = true;
                                        nextCoords.push({"i": final_i, "j": final_j});
                                    } else if (rangeType == "attack") {
                                        tile.atkRange = true;
                                        nextCoords.push({"i": final_i, "j": final_j});
                                    }
                                }
                            }
                        }
                    }
                }
            })
            rangeCounter++;
        }
    }

    disableRange(callback) {
        for (let i = 0; i < this.mapWidth; i++) {
            for (let j = 0; j < this.mapWidth; j++) {
                this.map[i][j].moveRange = false;
                this.map[i][j].atkRange = false;
            }
        }

        if (callback) {
            callback();
        }
    }

    moveUnit(targetCoords, playerTurn, id) {
        this.map[this.lastUnitSelected.i][this.lastUnitSelected.j].player = 0;
        this.map[this.lastUnitSelected.i][this.lastUnitSelected.j].id = 0;
        this.map[targetCoords.i][targetCoords.j].player = playerTurn;
        this.map[targetCoords.i][targetCoords.j].id = id;
    }

    respawn(unit, playerUnits) {
        this.spawnLocations[unit.player].forEach(coords => {
            let tile = this.map[coords.i][coords.j];
            if (tile.player == 0) {
                tile.player = unit.player;
                tile.id = unit.id;
                this.drawMap(playerUnits);
            }
        });
    }

    findTile(event) {
        let i = Math.floor((event.pageX - $("#game").offset().left) / this.tileSize)
        let j = Math.floor((event.pageY - $("#game").offset().top) / this.tileSize); 
        return {"tile": this.map[i][j], "i": i, "j": j};
    }

    removeUnit(tileCoords) {
        this.map[tileCoords.i][tileCoords.j] = {"type": this.map[tileCoords.i][tileCoords.j].type, "player": 0, "id": 0, "range": false};
    }

    updatePoints(playerPoints) {
        this.map.forEach(arr => {
            arr.forEach(tile => {
                if (tile.type == 3 && tile.player != 0) {
                    // "Hand Bells, F, Single.wav" by InspectorJ
                    let bell = new Audio("assets/bell.wav");
                    bell.play();
                    console.log("increasing points");
                    playerPoints[tile.player]++;
                }
            })
        })
    }

    highlightUnit(tileCoords, highlight) {
        let image;
        let tile = this.map[tileCoords.i][tileCoords.j]
        console.log(tileCoords);
        console.log(JSON.stringify(tile));
        console.log(tile.player);
        switch(tile.player) {
            case 1: 
                image = highlight ? this.blueDudeHighlight : this.blueDude;
                break;

            case 2: 
                image = highlight ? this.greenDudeHighlight : this.greenDude;
                break;

            case 3: 
                image = highlight ? this.orangeDudeHighlight : this.orangeDude;
                break;

            case 4: 
                image = highlight ? this.redDudeHighlight : this.redDude;
                break;
        }

        if (!highlight) {
            // reset tile
            let resetImage;
            console.log(tile.type);
            switch (tile.type) {
                case 0:
                    resetImage = this.emptySpace;
                    break;

                case 2:
                    resetImage = this.wall;
                    break;

                case 3:
                    resetImage = this.objective;
                    break;
            }

            this.ctx.drawImage(
                resetImage,
                tileCoords.i * this.tileSize,
                tileCoords.j * this.tileSize,
                this.tileSize,
                this.tileSize
            );
        }

        this.ctx.drawImage(
            image,
            tileCoords.i * this.tileSize,
            tileCoords.j * this.tileSize,
            this.tileSize,
            this.tileSize
        );
        
    }

    calculateViewRange(playerUnits) {
        for (let k = 0; k < 2; k++) {
            for (let i = 0; i < this.mapWidth; i++) {
                for (let j = 0; j < this.mapWidth; j++) {
                    if (k == 0) {
                        let counter = 0;
                        if (i < 3 || i > 10) {
                            counter++;
                        }
            
                        if (j < 3 || j > 10) {
                            counter++;
                        }
            
                        this.viewMap[i][j] = counter == 2;
    
                        for (let x = 6; x <= 7; x++) {
                            for (let y = 6; y <= 7; y++) {
                                this.viewMap[x][y] = true;
                            }
                        }
                    } else {                   
                        if (this.map[i][j].player == this.playerNum) {
                            let nextCoords = [{"i": i, "j": j}];
                            let rangeCounter = 0;
                            let range = playerUnits[this.playerNum][this.map[i][j].id].moveRange;
                            while (nextCoords.length != 0 && rangeCounter != range) {
                                let tempCoords = [...nextCoords];
                                nextCoords = [];
                                tempCoords.forEach(coords => {
                                    for (let x = -1; x <= 1; x++) {
                                        for (let y = -1; y <= 1; y++) {
                                            if (Math.abs(x + y) == 1) {
                                                let final_i = coords.i + x;
                                                let final_j = coords.j + y;
                                                if (final_i >= 0 && final_i < this.mapWidth && final_j >= 0 && final_j < this.mapWidth) {
                                                    this.viewMap[final_i][final_j] = true;
                                                    if (this.map[final_i][final_j].type != 2) {
                                                        nextCoords.push({"i": final_i, "j": final_j});
                                                    }
                                                }
                                            }
                                        }
                                    }
                                })
                                rangeCounter++;
                            }
                        }
                    }
                }
            }
        }
    }
}

function image(filename) {
    const img = new Image(32, 32);
    img.src = `assets/${filename}`;
    return img;
}

export {Map};