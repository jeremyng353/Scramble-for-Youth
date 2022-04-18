# Scramble for Youth 

## Introduction
Scramble for Youth is a multiplayer turn-based board game where four players try to reach the center of the board to collect bottles from the Fountain of Youth. Each player controls five units, and on their turn, each unit can either move or attack. For every unit in the center, that unit's player gets a bottle. First player to reach seven bottles wins. There is one additional role: the game master. The game master tries to prevent players from getting seven bottles by moving walls, sending lightning strikes, and creating hurricanes to intercept the players. If none of the players win by the end of seven rounds, the game master wins.

## Getting Started
Simply pull the repository and run 'node web_app/server.js' in bash.

## Unit Customization
Players are able to customize their units by putting skill points into health, attack damage, attack range, and movement range. Each unit is limited to five skill points.

## Controls
Left click on a unit to move and right click to attack. 

## Hardware Components
Scramble for Youth is intended to be played with several hardware components hooked up to a DE1-SoC, such as using an accelerometer to determine the exact range of an attack, interfacing through a VGA monitor to play as the game master, and having the AI logic in hardware. However, assuming users don't have access to such hardware, the logic has been edited to exclude these components.