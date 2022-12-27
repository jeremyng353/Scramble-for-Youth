# Scramble for Youth

Scramble for Youth is a multiplayer turn-based board game where four players try to reach the center of the board to collect bottles from the Fountain of Youth. Each player controls five units, and on their turn, each unit can either move or attack. For every unit in the center, that unit's player gets a bottle. First player to reach seven bottles wins. There is one additional role: the game master. The game master tries to prevent players from getting seven bottles by moving walls, sending lightning strikes, and creating hurricanes to intercept the players. If none of the players win by the end of seven rounds, the game master wins.

## Quickstart

1. Use the package manager [npm](https://www.npmjs.com/) to install required dependencies.

```
npm i
```

2. Set up a local MongoDB database named `web-messenger` at `mongodb://localhost:27017`.

3. Run the server.

```
node server.js
```

## Game Mechanics
### Unit Customization
Players are able to customize their units by putting skill points into health, attack damage, attack range, and movement range. Each unit is limited to five skill points.

### Fog of War
Players are only able to see parts of the board that are within a certain range of their units.

### Game Master
The game master tries to prevent players from reaching the center of the board by creating obstructions such as walls and natural disasters that can cause damage to player units or move them to a different place.

### Controls
Left click on a unit to move and right click to attack. 

## Hardware Components
Scramble for Youth is intended to be played with several hardware components hooked up to a DE1-SoC, such as using an accelerometer to determine the exact range of an attack, interfacing through a VGA monitor to play as the game master, and having the AI logic in hardware. However, assuming users don't have access to such hardware, the logic has been edited to exclude these components.

## Software Details
The server was hosted on an Azure server, which utilized Azure Web PubSub sockets to handle server-client communications. 

## Project Structure
```
scramble-for-youth/
├── README.md               # overview of the project
├── .gitignore              # ignored files
├── De1-Linux/              # software logic on DE1-SoC
├── gm_client/              # interface between high-level and low-level code
├── Quartus/                # hardware logic on DE1-SoC
│   ├── GAMEMASTERTEST/     # hardware logic for game master UI
│   └── verilog/            # code for homogenizing the training datasets
└── web_app/                # code for web app
    ├── client/             # client code
    └── server.js           # server code
```
