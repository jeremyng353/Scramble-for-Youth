SPRINT 2
1. support 5 units and multi-move turns
2. add walls and change range calculations
3. add objective tiles 
    a. count points
    b. objective image needs to stay in background when player is on it
4. max rounds
5. make canvas ui larger
    a. unit info to the left with a portrait image and hp, hover for additional stats
    b. tutorial messages/game messages to the right
        i. left click to choose target location, right click to cancel
        ii. player points
    c. next turn buttom bottom right
6. separate server and client logic (game logic and UI)
    a. use websocket to get data
7. unit respawn
8. change tilemap logic with how a tile can both be a unit and an objective (background vs foreground?)
    a. remove player from type, instead just check for player != 0 in drawMap

SPRINT 3
1. home page -> lobby -> unit customization -> game grid -> game over screen
2. incorporate accelerometer data into attack calculation
3. get better art + animations
4. randomize map creation
5. fog of war
    a. fog blocks
    b. attack animations in the fog when other players attack
6. game master logic
