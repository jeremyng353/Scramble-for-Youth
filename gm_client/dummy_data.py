from random import random
import urllib.request, json
import websocket, asyncio
from ctypes import *
import rel

id = random()
urlStr = 'https://scrambleforyouth.azurewebsites.net/negotiate?id=' + str(id)
with urllib.request.urlopen(urlStr) as url:
    data = json.loads(url.read().decode())

ws = websocket.WebSocket()
ws.connect(data['url'])


dummyData = [35, 5, 10, 13, 0, 4, 11, 13, 0, 3, 11, 11, 0]


def on_message(ws, message):
    print("MESSAGE RECEIVED")
    data = json.loads(message)['data']
    # print(data['type'])
    # print(data["playerTurn" if 'playerTurn' in data else "type"])
    
    print(data['type'])
    if 'playerTurn' in data:
        print(data['playerTurn'])
    if data['type'] == "game-state" and data['playerTurn'] == 4 and data['playerNum'] != 4:
        print("sending data")
        for i in range(0, 3):
            if (dummyData[(i + 1) * 4]):
                type1 = "aiAttack"
            else:
                type1 = "aiMove"
            moveData = '{"type":"'+ type1 + '","coords":{"i":' + str(dummyData[i * 4 + 2]) + ',"j":' + str(dummyData[i * 4 + 3]) + '},"unitID":' + str(dummyData[i * 4 + 1] - 1) + ',"playerNum":4}'
            print("move" + str(i))
            ws.send(moveData)
        

def on_error(ws, error):
    print("ERROR")

def on_close(ws, close_status_code, close_msg):
    print("### closed ###")

def on_open(ws):
    print("Opened connection")

if __name__ == "__main__":
    id = random()
    urlStr = 'https://scrambleforyouth.azurewebsites.net/negotiate?id=' + str(id)     
    with urllib.request.urlopen(urlStr) as url:
        data = json.loads(url.read().decode())
    websocket.enableTrace(True)
    ws = websocket.WebSocketApp(data['url'],
                              on_open=on_open,
                              on_message=on_message,
                              on_error=on_error,
                              on_close=on_close)

    ws.run_forever(dispatcher=rel)  # Set dispatcher to automatic reconnection
    rel.signal(2, rel.abort)  # Keyboard Interrupt
    rel.dispatch()