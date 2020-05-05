const WebSocket = require('ws');

//Function som start en starter en websocket server på port 2052
const wss = new WebSocket.Server({
	port: 2052
});

//Printer i konsol at programmet køre
console.log("Running...")

var clients = {}

//Function som bliver kaldt når der oprettes en ny forbindelse til server
wss.on('connection', function connection(ws) {
	
	/*
	If-statement som tjekker at der kun maks er 2 client connected.
	Hvis der allerede er 2, smider den resten ud når de prøver at komme på
	*/
	if (Object.keys(clients).length > 1) {
		ws.send('{"Error":"Serveren er fuld!"}')
		ws.close()
		return
	}
	
	//Giver den nye client et id
	ws.id = id()

	//Gobalt variabel som gemmer id'et
	clients[ws.id] = ws.id

	//Function som bliver kaldt når en client sender en besked
	ws.on('message', function incoming(message) {
		try {

			//Oversætter beskeden til json så javascript kan forstå det
			data = JSON.parse(message.toString())

			//If-statement som tjekker om event er lig med "requestCharacter"
			if (data.event == "requestCharacter") {

				//Object til spawn af en figur i spillet
				var spawnobj = {
					event: "spawn",
					character: {
						name: data.name,
						direction: data.direction,
						spawnTime: data.spawnTime
					}
				}

				//Function som send spawn objected til alle clients
				wss.clients.forEach((client) => {
					
					//If-statement der tjekker at nuværende client har forbindelse
					if (client.readyState === WebSocket.OPEN) {

						//Hvis de har det laver den "spawnobj" til en string og sender den
						client.send(JSON.stringify(spawnobj));

					}
				});
			}
		//hvis der er sket en fejl bliver den vist i konsol
		} catch (err) {

			//Printer fejlen
			console.log(err)

			//Printer den besked clienten sendte
			console.log([message.toString()])
		}
	});

	//Function som bliver kaldt når en client mister/lukker forbindelsen til serveren
	ws.on('close', function incoming(message) {

		//If-statement som tjekker at det er en godkendt client
		if (Object.keys(clients).includes(ws.id)) {

			//Hvis det er en godkendt client, bliver den client slettet så der er plads til en ny
			delete clients[ws.id]

			//Printer i konsol at vi har mistet en spiller
			console.log("lost player");
		}
	});

	//If-statement som beslutter hvilken klient som får hvilken retning i spillet
	if (Object.keys(clients).length == 1) {

		//Hvis det er den eneste client på serveren får cliet id 1
		ws.send('{"event":"id","id":1}')

	} else {

		//Ellers får client id -1
		ws.send('{"event":"id","id":-1}')

		//Der er nu 2 spillere så vi sender en start besked til dem begge
		wss.clients.forEach((client) => {

			//If-statement der tjekker at nuværende client har forbindelse
			if (client.readyState === WebSocket.OPEN) {

				//Hvis client har forbindelse, så den start event
				client.send('{"event":"start"}');
			}
		});
	}
});

//Funktion som generer og returnere en random streng med en længde på 30
function id() {
	return [...Array(30)].map(() => Math.random().toString(36)[2]).join('')
}