extends Node2D

#Variable som holder websocket-addressen til serveren
var address = "nfs.codes:2052"

#Funktion til at skifte websocket-addressen til local server
func go_local():
	address = "localhost:2052"

#Starter en ny Websocketclient
var _client = WebSocketClient.new()

#Function som kaldes når man vil forbinde til serveren
func establish_connection():
	
	#Opretter en function til at håndtere når fobindelsen bliver lukket
	_client.connect("connection_closed", self, "_closed")
	
	#Opretter en function til at håndtere når fobindelsen bliver tabt
	_client.connect("connection_error", self, "_closed")
	
	#Opretter en function til at håndtere når der bliver oprettet forbindelse
	_client.connect("connection_established", self, "_connected")
	
	#Opretter en function til at håndtere når client modtager noget data
	_client.connect("data_received", self, "_on_data")
	
	#Opretter forbindelsen til serveren
	var err = _client.connect_to_url(str("ws://", address)) #
	
	#If-statement som tjekker om forbindelsen blev oprettet
	if err != OK:
		
		#Hvis err ikke får status-code 200/"OK" tilbage Printer vi det i konsol
		print("Unable to connect")
		
	else:
		
		#Når der bliver oprettet forbindelse bliver menuen fjernet
		var menu = get_node_or_null("/root/Game/Control/Menu")
		if menu != null:
			
			#sletter menu fra skærmen
			menu.queue_free()

#Function til at håndtere når fobindelsen bliver lukket
func _closed(was_clean = false):
	
	#Printer i konsol om forbindelsen blev lukket rigtigt
	print("Closed, clean: ", was_clean)
	
	#Sætter alt på pause
	set_process(false)

#Function til at håndtere når der bliver oprettet forbindelse
func _connected(_proto = ""):
	
	#Sender en test besked til serveren når forbindelsen er blevet oprettet
	_client.get_peer(1).put_packet('{"Test":"Packet"}'.to_utf8())

#Function til at håndtere når client modtager noget data
func _on_data():
	#Oversætter den modtaget streng fra utf8 til normal tekst of derefter til et Json object
	var data = JSON.parse(_client.get_peer(1).get_packet().get_string_from_utf8()).result
	
	#If-statements som tjekker event

	#Hvis event er id
	if data.event == "id": 
		#Skifter teksten på connection label til Waiting for another player...
		get_node("Control").get_node("connection").text = "Waiting for another player..."
		
		#Skifter Farven på connection label til hvid
		get_node("Control").get_node("connection").add_color_override("font_color", Color(255,255,255,255))
		
		#Fortæller Game scriptet at state skal være pause og Direction skal være id
		get_node("/root/Game").setup("pause", data.id)

	#Hvis event er start
	if data.event == "start":
		
		#Printer i konsol, hvilken retning du er og at spillet er startet
		print(get_node("/root/Game").get("DIR"), "| connected and started!")
		
		#Skifter teksten på connection label til Connected
		get_node("Control").get_node("connection").text = "Connected"
		
		#Skifter Farven på connection label til grøn
		get_node("Control").get_node("connection").add_color_override("font_color", Color(0,255,0,255))
		
		#Fortæller Game scriptet at state skal være game og Direction skal være id, hvilket starter spillet
		get_node("/root/Game").setup("game", get_node("/root/Game").get("DIR"))

	#Hvis event er spawn
	if data.event == "spawn":
		
		#Så bliver den modtaget karakter sat i vores queue
		get_node("/root/Game").Queue.append(data.character)

func _process(_delta):
	#Function som tjekker om der er kommet noget ny fra serveren
	_client.poll()
