import {Game} from "./game.js";
import {Unit} from "./unit.js";

const canvas = document.getElementById("game");
const ctx = canvas.getContext("2d");
const origin = window.location.origin;

// map constants
const mapWidth = 14;
const tileSize = 32;

// player specific data
let playerNum = -1;
let skillPoints = [];
for (let i = 0; i < 6; i++) {
    skillPoints[i] = 5;
}

let playerUnits = [];
let id = Math.random();
let game;
let socket;

async function begin(){
  let res = await fetch(`/negotiate?id=${id}`);
  let data = await res.json();
  socket = new WebSocket(data.url);
  console.log(`${id}`);
  console.log(`${data.url}`);
  socket.onopen = () => console.log('connected');
}

begin();


let playersInGame = 1;
let aiCounter = 0;

/*
	SPRINT 3
	4. implement audio
		a. moving: grass shuffling sound
		b. attacking: striking sound, maybe metal sound
		c. getting a point: ding sound
    8. make home page look better (background img)
     
	SPRINT 4
	2. change background color of game view
	3. improve ui
		a. border around messages, light blue curved box background
		c. animations
		d. player turn section
	5. make sure that all players can see readied players in lobby even if join late
    7. bugfix highlight disappearing on clicking when range
    8. nerf moverange
*/

/*
    TODO
    2. change bg to a png
    4. change wall color
    6. improve home page
    7. implement gm in the lobby (how to tell if a socket connection is the gm)
    10. play again button POSSIBLY REMOVE THIS
    11. show a tutorial
    12. change player name in points table if ai
*/

/*
    KNOWN BUGS
    1. players joining after anything is done (readying up, ai added) won't see the reflected changes
*/

window.onload = () => {  
    // join lobby
    console.log(window.innerHeight);
    document.getElementById("start-button").addEventListener("click", () => {
        toggleScreen("home-page", false);
        toggleScreen("lobby-screen", true); 

        fetch(origin + "/lobby").then(res => res.json()).then(data => {
            $("#gm-name").text(data.gmName);
            playerNum = data.playerNum;

            unitCustomizationHTML(); 

            btnEventListeners();
			console.log(`playerNum: ${playerNum}`);

            playerUnits[playerNum] = [];

            for (let i = 1; i <= playerNum; i++) {
                appendPlayer(i, i == playerNum);
            }

            socket.send(JSON.stringify({
                "type": "lobby",
                "playerNum": playerNum
            }));
            
            socket.addEventListener("message", (event) => {
                let data = JSON.parse(event.data).data;
                console.log(JSON.stringify(data));
                console.log(data.type);
                
                if (data.type == "lobby") {
                  if (data.playerNum != playerNum){
                      appendPlayer(data.playerNum, false);
                  }
                  playersInGame = data.playerNum;
                } else if (data.type == "lobby-ready") {
                    if (data.allReady) {
                        setTimeout(() => {
                            toggleScreen("lobby-screen", false);
                            toggleScreen("unit-customization", true); 
                        }, 200)
                    } else {
                      if (data.playerNum != playerNum){
                        lobbyReady(data.playerNum, data.displayCheck);
                      }
                    }
                } else if (data.type == "unit-ready") {
					if (data.allReady) {
						data.playerUnits[0] = [];
						playerUnits = data.playerUnits;
						game = new Game(mapWidth, tileSize, playerUnits, socket, canvas, ctx, playerNum, data.map, aiCounter);
						createLeftUI(playerUnits);
						if (playerNum == 1) {
							game.startTurn();
						}
						toggleScreen("unit-customization", false);
						toggleScreen("game-view", true);
					}
				} else if (data.type == "add-ai" && data.playerNum != playerNum) {
                    playersInGame = data.playersInGame;
                    aiCounter = data.aiCounter;
                    $("#player-container").append(`
                    <div class="row">
                        <div class="col-10">
                            Player ${playersInGame} (AI)
                        </div>
                        <div id="player-${playersInGame}" class="col-2"></div>
                    </div>`);
                } else if (data.type == "remove-ai" && data.playerNum != playerNum){
                    playersInGame = data.playersInGame;
                    aiCounter = data.aiCounter;
                    $("#player-container").children().last().remove();
                }
            })

            let displayCheck = false;
            document.getElementById("ready-btn").addEventListener("click", () => {
                displayCheck = !displayCheck;
                lobbyReady(playerNum, displayCheck);
                
                socket.send(JSON.stringify({
                    "type": "lobby-ready",
                    "playerNum": playerNum,
                    "displayCheck": displayCheck
                }));
            })
        });
    });

	let unitReady = false;
	document.getElementById("unit-ready-btn").addEventListener("click", () => {
		unitReady = !unitReady;
        unitReady ? $("#unit-ready-btn").addClass("active") : $("#unit-ready-btn").removeClass("active");
		createUnits();
        unitCheck(unitReady);
		socket.send(JSON.stringify({
			"type": "unit-ready",
			"playerNum": playerNum,
			"displayCheck": unitReady,
			"playerUnits": playerUnits[playerNum]
		}));
	});

    document.getElementById("add-ai-btn").addEventListener("click", () => {
        if (playersInGame < 4) {
            playersInGame++;
            aiCounter++;
            $("#player-container").append(`
                <div class="row">
                    <div class="col-10">
                        Player ${playersInGame} (AI)
                    </div>
                    <div id="player-${playersInGame}" class="col-2"></div>
                </div>`);
    
            socket.send(JSON.stringify({
                "type": "add-ai",
                "playersInGame": playersInGame,
                "aiCounter": aiCounter,
                "playerNum": playerNum
            }));
        }
        
	})

    document.getElementById("remove-ai-btn").addEventListener("click", () => {
        if (aiCounter > 0) {
            playersInGame--;
            aiCounter--;
            $("#player-container").children().last().remove();
            socket.send(JSON.stringify({
                "type": "remove-ai",
                "playersInGame": playersInGame,
                "aiCounter": aiCounter,
                "playerNum": playerNum
            }));
        }
	})



    canvas.height = mapWidth * tileSize;
    canvas.width = mapWidth * tileSize;
}

function appendPlayer(playerNum, you) {
    let text = `Player ${playerNum}`;
    if (you) {
        text = text.concat(" (you)");
    }

    $("#player-container").append(`
        <div class="row">
            <div class="col-10">
                ${text}
            </div>
            <div id="player-${playerNum}" class="col-2"></div>
        </div>`);
}

function lobbyReady(playerNum, display) {
    display ? $(`#player-${playerNum}`).append(
        `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-check2" viewBox="0 0 16 16">
            <path d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z"/>
        </svg>`
    ) : $(`#player-${playerNum}`).children().remove();
}

function unitCheck(display) {
    display ? $(`#unit-customization`).append(
        `
        <div id="unit-check">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-check2" viewBox="0 0 16 16">
            <path d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z"/>
          </svg>
        </div>`
    ) : $(`#unit-customization`).children().last().remove();
}

// inspiration from https://github.com/david-reid/cwd-startscreen-session
function toggleScreen(id, toggle) {
    let element = document.getElementById(id);
    element.style.display = toggle ? "block" : "none";
}

function unitCustomizationHTML() {
    let src = "assets/";
    switch(playerNum) {
        case 1:
            src += "blueDudeBig.png";
            break;

        case 2:
            src += "greenDudeBig.png";
            break;

        case 3:
            src += "orangeDudeBig.png";
            break;

        case 4:
            src += "redDudeBig.png";
            break;
    }

    for (let i = 5; i > 0; i--) {
        $("#myTabContent").prepend(`<div class="tab-pane fade" id="unit-${i}" role="tabpanel" aria-labelledby="unit-${i}-tab">
        <div class="container" style="margin-top: 10px">
          <div class="row">
            <div class="col-3">
              <img src="${src}">
              <div class="profile-pic"></div>
              <div class="unit-name">Unit ${i}</div>
            </div>
            <div class="col-9">
              <div class="container">
              <div style="text-align:right">Remaining Points: 5</div>
                <div class="row p-2">
                  <div class="col">
                    Health
                    <div class="progress">
					  <div class="border-container">
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
					  </div>
                      <div class="progress-bar bg-success stat-bar" role="progressbar" style="width: 50%" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                  </div>
                  <div class="col-md-auto">
                    <button type="button" class="btn btn-success minus-btn 50">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-dash" viewBox="0 0 16 16">
                        <path d="M4 8a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7A.5.5 0 0 1 4 8z"/>
                      </svg>
                    </button>
                    <button type="button" class="btn btn-success plus-btn 50">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-plus" viewBox="0 0 16 16">
                        <path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"/>
                      </svg>
                    </button>
                  </div>
                </div>
                <div class="row p-2">
                  <div class="col">
                  Attack
                    <div class="progress">
					  <div class="border-container">
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
					  </div>
                      <div class="progress-bar bg-success stat-bar" role="progressbar" style="width: 20%" aria-valuenow="20" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                  </div>
                  <div class="col-md-auto">
                    <button type="button" class="btn btn-success minus-btn 20">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-dash" viewBox="0 0 16 16">
                        <path d="M4 8a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7A.5.5 0 0 1 4 8z"/>
                      </svg>
                    </button>
                    <button type="button" class="btn btn-success plus-btn 20">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-plus" viewBox="0 0 16 16">
                        <path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"/>
                      </svg>
                    </button>
                  </div>
                </div>
                <div class="row p-2">
                  <div class="col">
                  Attack Range
                    <div class="progress">
					  <div class="border-container">
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
					  </div>
					  <div class="progress-bar bg-success stat-bar" role="progressbar" style="width: 30%" aria-valuenow="30" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                  </div>
                  <div class="col-md-auto">
                    <button type="button" class="btn btn-success minus-btn 30">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-dash" viewBox="0 0 16 16">
                        <path d="M4 8a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7A.5.5 0 0 1 4 8z"/>
                      </svg>
                    </button>
                    <button type="button" class="btn btn-success plus-btn 30">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-plus" viewBox="0 0 16 16">
                        <path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"/>
                      </svg>
                    </button>
                  </div>
                </div>
                <div class="row p-2">
                  <div class="col">
                    Movement Range
                    <div class="progress">
					  <div class="border-container">
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
						<div class="tenth-separator"></div>
					  </div>
                      <div class="progress-bar bg-success stat-bar" role="progressbar" style="width: 30%" aria-valuenow="30" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                  </div>
                  <div class="col-md-auto">
                    <button type="button" class="btn btn-success minus-btn 30">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-dash" viewBox="0 0 16 16">
                        <path d="M4 8a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7A.5.5 0 0 1 4 8z"/>
                      </svg>
                    </button>
                    <button type="button" class="btn btn-success plus-btn 30">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-plus" viewBox="0 0 16 16">
                        <path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"/>
                      </svg>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>`);
        if (i == 1) {
            $("#unit-1").addClass("show");
            $("#unit-1").addClass("active");
        }
    }
}

function createUnits() {
    let vals = [];
	let counter = 0;
	let id = 0;

	for (let ele of document.getElementsByClassName("stat-bar")) {
		vals.push(parseInt(ele.style.width) / 10);
		counter++;
		if (counter == 4) {
			playerUnits[playerNum][id] = new Unit(playerNum, id, ...vals);
			counter = 0;
			id++;
			vals = [];
		}
	}
}

function createLeftUI(playerUnits) {
  console.log('RUNNING');
	let counter = -1;
	console.log(JSON.stringify(playerUnits[playerNum]));
	$(".unit").append(() => {
		counter++;
		return `
			Unit ${counter + 1}
			<div class="progress">
			  <div class="border-container">
				<div class="tenth-separator"></div>
				<div class="tenth-separator"></div>
				<div class="tenth-separator"></div>
				<div class="tenth-separator"></div>
				<div class="tenth-separator"></div>
				<div class="tenth-separator"></div>
				<div class="tenth-separator"></div>
				<div class="tenth-separator"></div>
				<div class="tenth-separator"></div>
				<div class="tenth-separator"></div>
			  </div>
			  <div class="progress-bar bg-success stat-bar" role="progressbar" style="width: ${playerUnits[playerNum][counter].maxHp * 10}%" aria-valuenow="${playerUnits[playerNum][counter].maxHp * 10}" aria-valuemin="0" aria-valuemax="100"></div>
			</div>
            <div>atk: ${playerUnits[playerNum][counter].atkDmg}</div>
            <div style="display: flex; justify-content: space-between">
              <div>atkRange: ${playerUnits[playerNum][counter].atkRange}</div>
              <div>moveRange: ${playerUnits[playerNum][counter].moveRange}</div>
            </div>`
	})
}

function btnEventListeners() {
    for (let ele of document.getElementsByClassName("plus-btn")) {
        ele.addEventListener("click", () => {
            let progressBar = ele.parentElement.previousElementSibling.firstElementChild.lastElementChild;
            // let remainingPoints = skillPoints[ele.parentElement.parentElement.parentElement.parentElement.previousElementSibling.children[1].textContent.match(/[0-9]/)];
            let unitNum = ele.parentElement.parentElement.parentElement.parentElement.previousElementSibling.lastElementChild.textContent.match(/[0-9]/);
            let remainingPoints = skillPoints[unitNum];
            console.log(`unitNum: ${unitNum}`);
            console.log(`remaining pts: ${remainingPoints}`);
            if (progressBar.ariaValueNow != 100 && remainingPoints > 0) {
                progressBar.ariaValueNow = String(parseInt(progressBar.ariaValueNow) + 10);
                progressBar.style.width = String(parseInt(progressBar.style.width.match(/[0-9]*/)) + 10) + "%";
                skillPoints[unitNum]--;
                ele.parentElement.parentElement.parentElement.firstElementChild.textContent = `Remaining Points: ${skillPoints[unitNum]}`;
            }
        })
    }

    for (let ele of document.getElementsByClassName("minus-btn")) {
        ele.addEventListener("click", () => {
            let progressBar = ele.parentElement.previousElementSibling.firstElementChild.lastElementChild;
            let unitNum = ele.parentElement.parentElement.parentElement.parentElement.previousElementSibling.lastElementChild.textContent.match(/[0-9]/);
            if (progressBar.ariaValueNow != ele.classList[3]) {
                progressBar.ariaValueNow = String(parseInt(progressBar.ariaValueNow) - 10);
                progressBar.style.width = String(parseInt(progressBar.style.width.match(/[0-9]*/)) - 10) + "%";
                // indexed by text of unit name (number)
                skillPoints[unitNum]++;
                ele.parentElement.parentElement.parentElement.firstElementChild.textContent = `Remaining Points: ${skillPoints[unitNum]}`;
            }
        })
    }
}