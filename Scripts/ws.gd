extends Node2D

var _client = WebSocketClient.new()
func _ready():
	print(JSON.parse('{"jeg":"elsker","mande":{"bollor":"tis"}}').result)
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")

	var err = _client.connect_to_url("ws://nfs.codes:3000")
	if err != OK:
		print("Unable to connect")

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	_client.get_peer(1).put_packet('{"Test":"Packet"}'.to_utf8())

func _on_data():
	var data = JSON.parse(_client.get_peer(1).get_packet().get_string_from_utf8()).result
	if data.event == "id": 
		get_node("Control").get_node("connection").text = "Waiting for another player..."
		get_node("Control").get_node("connection").add_color_override("font_color", Color(255,255,255,255))
		get_node("/root/Game").setup("pause", data.id)
		print(data.id)
	if data.event == "start":
		print(get_node("/root/Game").get("DIR"), "| connected and started!")
		get_node("Control").get_node("connection").text = "Connected"
		get_node("Control").get_node("connection").add_color_override("font_color", Color(0,255,0,255))
		get_node("/root/Game").setup("game", get_node("/root/Game").get("DIR"))
	if data.event == "spawn":

		print(data)
		get_node("/root/Game").Queue.append(data.character)
	print("my id:", get_node("/root/Game").get("DIR"))

func _process(_delta):
	_client.poll()
