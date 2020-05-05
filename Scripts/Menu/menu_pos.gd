extends Control

onready var GAME = get_node("/root/Game")
onready var MENU = GAME.get_node_or_null("/Control/Menu")

func _process(_delta): # sikre at menuen følger kameraet
	var camPos = get_parent().get_node("Camera2D").get_camera_screen_center()
	set_position(Vector2(camPos.x-1200, camPos.y-900))
	pass



func _on_TextureButton_mouse_entered(ch):
	var price = GAME.get("Characters")[ch]["price"]
	get_node("./Price").text = str(ch, ": ", price, "$")
	# viser prisen på karakterene når man holder musen over dem.

func _on_TextureButton_pressed(ch):
	# når man trykker på en af de tre knapper bliver denne funktion kaldt
	# knapperne sender et signal med hver deres parameter

	# jeg tjekker lige om spillet er i gang.
	if GAME.get("state") == "game":
		var dir = GAME.get("DIR")
		GAME.requestCharacter(ch, dir) # så kalder anmoder jeg om en karakter

func _on_menu_btn_pressed(ch):
	# man kan vælge om man vil spille lokalt eller online
	if ch == "local":
		GAME.go_local()

	GAME.establish_connection() # opretter forbindelse til serveren


func _on_Button_pressed():
	# starter en nummer to klient
	var _program = OS.execute(OS.get_executable_path(), OS.get_cmdline_args(), false, [])
