const path = require('path');
const fs = require('fs');
const express = require('express');
const { WebPubSubServiceClient } = require('@azure/web-pubsub');
const { WebPubSubEventHandler } = require('@azure/web-pubsub-express');

function logRequest(req, res, next){
	console.log(`${new Date()}  ${req.ip} : ${req.method} ${req.path}`);
	next();
}

const host = 'localhost';
const port = 8080;
const clientApp = path.join(__dirname, 'client');
const hubName = 'sample_chat';

// lobby values
let readyCounter = 0;
let ready = 4;
let aiCounter = 0;

// game data
let map = [];
let playerTurn = 1;
let playerNum = 0;
let gameOver = false;
let playerPoints = {};
let playerUnits = [];
const mapWidth = 14;

let gmNames = [
    "Oppressive Overlord",
    "Brutal Bully",
    "tim",
    "Dispiriting Dictator",
    "Cruel Czar"
]
let gmName = gmNames[Math.round(Math.random() * 4)];

let spawnLocations = [
	[{}],
	[{"i": 0, "j": 0}], 
	[{"i": 0, "j": 12}],
	[{"i": 12, "j": 0}],
	[{"i": 12, "j": 12}],
]

for (let i = 1; i < 5; i++) {
	for (let j = 1; j < 4; j++) {
		switch(j) {
			case 1: 
				spawnLocations[i][j] = {"i": spawnLocations[i][0].i, "j": spawnLocations[i][0].j + 1};
				break;
				
			case 2:
				spawnLocations[i][j] = {"i": spawnLocations[i][0].i + 1, "j": spawnLocations[i][0].j};
				break;

			case 3:
				spawnLocations[i][j] = {"i": spawnLocations[i][0].i + 1, "j": spawnLocations[i][0].j + 1};
				break;
		}
	}
}

spawnLocations[1].push({"i": 2, "j": 0});
spawnLocations[2].push({"i": 2, "j": 13});
spawnLocations[3].push({"i": 11, "j": 0});
spawnLocations[4].push({"i": 11, "j": 13});

// initialize player points to 0
for (let i = 1; i <= 4; i++) {
	playerPoints[i] = 0;
}

/*
	TYPES
	0: empty space
	1: spawn squares
	2: wall
	3: objective
*/

// values for background tiles in the actual game map
for (let i = 0; i < mapWidth; i++) {
	map[i] = [];
	for (let j = 0; j < mapWidth; j++) {
		map[i][j] = {"type": 0, "player": 0, "id": 0, "moveRange": false, "atkRange": false};
	}
}

for (let k = 0; k < 4; k++) {
	let i;
	let j;
	switch(k) {
		case 0: 
			i = 0;
			j = 0;
			break;

		case 1:
			i = 0;
			j = 11;
			break;

		case 2:
			i = 11;
			j = 0;
			break;

		case 3:
			i = 11;
			j = 11;
	}

	for (let x = 0; x < 3; x++) {
		for (let y = 0; y < 3; y++) {
			map[i + x][j + y] = {"type": 1, "player": 0, "id": 0, "moveRange": false, "atkRange": false};
		}
	}
}

// unit squares
for (let i = 1; i < 5; i++) {
	let counter = 0;
	spawnLocations[i].forEach(coords => {
		map[coords.i][coords.j] = {"type": 1, "player": i, "id": counter, "moveRange": false, "atkRange": false};
		counter++;
	})
}

// objective squares
for (let i = mapWidth / 2 - 1; i <= mapWidth / 2; i++) {
	for (let j = mapWidth / 2 - 1; j <= mapWidth / 2; j++) {
		map[i][j] = {"type": 3, "player": 0, "id": 0, "moveRange": false, "atkRange": false};
	}
}

// randomly generate walls
for (let i = 4; i < 10; i++) {
	for (let j = 0; j < mapWidth; j++) {
		if (j != 6 && j != 7) {
			if (Math.random() < 0.2) {
				map[i][j].type = 2;
			}
		}
	}
}

for (let i = 0; i < mapWidth; i++) {
	for (let j = 4; j < 10; j++) {
		if (i < 4 || i > 10) {
			if (Math.random() < 0.2) {
				map[i][j].type = 2;
			}
		}
	}
}

// express app
let app = express();

app.use(express.json()) 						// to parse application/json
app.use(express.urlencoded({ extended: true })) // to parse application/x-www-form-urlencoded
app.use(logRequest);							// logging for debug

app.route("/game")
	.get((req, res, next) => {
		res.json({
			"map": map,
			"playerTurn": playerTurn,
			"gameOver": gameOver,
			"playerPoints": playerPoints
		});
	})
	.post((req, res, next) => {
		map = req.body.map;
	})

app.route("/lobby")
	.get((req, res, next) => {
		playerNum == 4 ? playerNum = 1 : playerNum++;
		res.json({
			"playerNum": playerNum,
			"gmName": gmName 
		});
	})

// azure web pubsub sockets
let connectionString = 'Endpoint=https://testwebsocketsm.webpubsub.azure.com;AccessKey=SvSfsuwmkQg1OrQexknsHbxO3h8rZPSYicYYwOEh2kU=;Version=1.0;';
let serviceClient = new WebPubSubServiceClient(connectionString, hubName);

let handler = new WebPubSubEventHandler(hubName, {
	path: '/eventhandler',
	onConnected: async req => {
		console.log(`${req.context.userId} connected`);
	},
	handleUserEvent: async (req, res) => {
		console.log(req.data);
		let JSONdata = JSON.parse(req.data);
		console.log(JSONdata.type);
		if (JSONdata.type == "add-ai" || JSONdata.type == "remove-ai") {
			JSONdata.type == "add-ai" ? aiCounter++ : aiCounter--;
		} else if (JSONdata.type == "lobby-ready" || JSONdata.type == "unit-ready") {
			JSONdata.displayCheck ? readyCounter++ : readyCounter--;
			if (JSONdata.type == "unit-ready") {
				playerUnits[JSONdata.playerNum] = JSONdata.playerUnits;
			}

			if (readyCounter == ready - aiCounter) {
				if (JSONdata.type == "unit-ready") {
					JSONdata.map = map;
				}
				JSONdata.allReady = true;
				JSONdata.playerUnits = playerUnits;
				readyCounter = 0;
				//await serviceClient.sendToAll({
				//	data: JSONdata
				//});
			}
		}

		await serviceClient.sendToAll({
			data: JSONdata
		});

	  	res.success();
	}
  });

app.use(handler.getMiddleware());

app.get('/negotiate', async (req, res) => {
	let id = req.query.id;
	if (!id) {
		res.status(400).send('missing user id');
		return;
	}
	let token = await serviceClient.getClientAccessToken({ userId: id });
	res.json({
		url: token.url
	});
});

// serve static files (client-side)
app.use('/', express.static(clientApp, { extensions: ['html'] }));
app.listen(port, () => {
	console.log(`${new Date()}  App Started. Listening on ${host}:${port}, serving ${clientApp}`);
}); 