const WebSocket = require('ws');

const wss = new WebSocket.Server({
	port: 3000
});

console.log("Running...")

var clients = {}

wss.on('connection', function connection(ws) {
	console.log(clients)
	if (Object.keys(clients).length > 1) {
		ws.send('{"Error":"Serveren er fuld!"}')
		ws.close()
		return
	}
	ws.id = id()
	clients[ws.id] = ws.id
	ws.on('message', function incoming(message) {
		try {
			data = JSON.parse(message.toString())
			console.log(data)
			if (data.event == "requestCharacter") {
				var spawnobj = {
					event: "spawn",
					character: {
						name: data.name,
						direction: data.direction,
						spawnTime: data.spawnTime
					}
				}
				wss.clients.forEach((client) => {
					if (client.readyState === WebSocket.OPEN) {
						client.send(JSON.stringify(spawnobj));
					}
				});
			}
		} catch (err) {
			console.log(err)
			console.log([message.toString()])
		}
	});
	ws.on('close', function incoming(message) {
		if (Object.keys(clients).includes(ws.id)) {
			delete clients[ws.id]
			console.log("lost player");
		}
	});
	if (Object.keys(clients).length == 1) {
		ws.send('{"event":"id","id":1}')
	} else {
		ws.send('{"event":"id","id":-1}')
		wss.clients.forEach((client) => {
			if (client.readyState === WebSocket.OPEN) {
				client.send('{"event":"start"}');
			}
		});
	}
});


function id() {
	return [...Array(30)].map(() => Math.random().toString(36)[2]).join('')
}