extends Node2D

var _client = WebSocketClient.new()

func _ready():
    print("test")
    _client.connect("connection_closed", self, "_closed")
    _client.connect("connection_error", self, "_closed")
    _client.connect("connection_established", self, "_connected")
    _client.connect("data_received", self, "_on_data")

    var err = _client.connect_to_url("ws://localhost:3000")
    if err != OK:
        print("Unable to connect")

func _closed(was_clean = false):
    print("Closed, clean: ", was_clean)
    set_process(false)

func _connected(proto = ""):
    print("Connected with protocol: ", proto)
    _client.get_peer(1).put_packet("Test packet".to_utf8())

func _on_data():
    print("Got data from server: ", _client.get_peer(1).get_packet().get_string_from_utf8())

func _process(_delta):
    _client.poll()