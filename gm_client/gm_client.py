from random import random
import urllib.request, json
import websocket
from ctypes import *

def on_message(ws, message):
    data = json.loads(message)['data']
    print(data['type'])
    
    if data['type'] == 'attack':
        print("ATTACK")
        #call accelerometer c function
        num_args_in = 2
        args_in = [10,0]
        args_in_p = (c_uint32*num_args_in)(*args_in)
        num_args_out = 13
        args_out = [0 for _ in range(num_args_out)]
        args_out_p = (c_uint32*num_args_out)(*args_out)

        sendData(c_uint32(num_args_in), args_in_p, c_uint32(num_args_out), args_out_p)

        args_out = list(args_out_p)

        data['magnitude'] = args_out[1]

        ws.send(json.dumps(data, separators=(',', ':')))
    
    elif data['type'] == 'game-state':
        print("GAME-STATE")

        playerUnitsData = data['playerUnits']

        rows = []
        players = [[] for _ in range(6)]
        for r in range(len(data['map'])):
            for c in range(len(data['map'][0])):
                mapData = data['map'][r][c]
                if c == 0 or c == 8:
                    rows.append(0)
                mapNum = 0

                if mapData['type'] == 2: #we have a wall
                    mapNum = 5
                else:
                    mapNum = mapData['player']

                if c < 8:
                    mapNum = mapNum << (4*c)
                else:
                    mapNum = mapNum << (4*(c-8))

                rows[-1] += mapNum

                if data['ai'] and data['playerTurn'] == mapData['player']:
                    players[mapData['id'] + 1].append(r)
                    players[mapData['id'] + 1].append(c)
                    players[mapData['id'] + 1].append(playerUnitsData[data['playerTurn']][mapData['id']]['alive'])
                    players[mapData['id'] + 1].append(playerUnitsData[data['playerTurn']][mapData['id']]['moveRange'])
                    players[mapData['id'] + 1].append(playerUnitsData[data['playerTurn']][mapData['id']]['atkRange'])
                    players[mapData['id'] + 1].append(playerUnitsData[data['playerTurn']][mapData['id']]['atkDmg'])  

        bitCheck = 1 if data['playerTurn'] == 5 else 0
        
        num_args_in = 30

        args_in = [21, bitCheck] + rows
        args_in_p = (c_uint32*num_args_in)(*args_in)
        num_args_out = 13
        args_out = [0 for _ in range(num_args_out)]
        args_out_p = (c_uint32*num_args_out)(*args_out)

        sendData(c_uint32(num_args_in), args_in_p, c_uint32(num_args_out), args_out_p)

        args_out = list(args_out_p)

        if bitCheck:
            data['type'] = 'lightning' if args_out[1] == 0 else 'hurricane'

            if data['type'] == 'lightning':
                data['coords'] = '{"i":' + str(args_out[2]) + ',"j":' + str(args_out[3]) + '}'
            else:
                data['init_coords'] = '{"init_i":' + str(args_out[2]) + ',"init_j":' + str(args_out[3]) + '}'
                data['final_coords'] = '{"init_i":' + str(args_out[4]) + ',"init_j":' + str(args_out[5]) + '}'
            
            ws.send(json.dumps(data, separators=(',', ':')))

        if data['ai']:
            if(data['playerNum'] != lastPlayerNum):
                lastPlayerNum = data['playerNum']
                num_args_in = 61

                args_in = [35, 0] + rows

                for i in range(1, 6):
                    args_in += [i]
                    args_in += players[i]

                args_in_p = (c_uint32*num_args_in)(*args_in)

                num_args_out = 13
                args_out = [0 for _ in range(num_args_out)]
                args_out_p = (c_uint32*num_args_out)(*args_out)

                sendData(c_uint32(num_args_in), args_in_p, c_uint32(num_args_out), args_out_p)

                args_out = list(args_out_p)

                for i in range(0, 3):
                    if (args_out[(i+1) * 4]):
                        type1 = "attack"
                    else:
                        type1 = "move"
                        
                    moveData = '{"type":'+ type1 + ',"coords":{"i":' + str(args_out[i * 4 + 2]) + ',"j":' + str(args_out[i * 4 + 3]) + '},"unitID":' + str(args_out[i * 4 + 1] - 1) + '}'
                    ws.send(moveData)
        

def on_error(ws, error):
    print("ERROR")

def on_close(ws, close_status_code, close_msg):
    print("### closed ###")

def on_open(ws):
    print("Opened connection")

if __name__ == "__main__":
    so_file = "/home/ubuntu/l2b-14/sendData.so"
    sendData = CDLL(so_file).sendData
    sendData.argtypes = [c_uint32, POINTER(c_uint32), c_uint32, POINTER(c_uint32)]
    sendData.restype = c_int

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

    ws.run_forever()