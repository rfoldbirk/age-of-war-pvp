extends Control

onready var GAME = get_node("/root/Game")
onready var MENU = GAME.get_node("/Control/Menu")

func _process(_delta):
	var camPos = get_parent().get_node("Camera2D").get_camera_screen_center()
	set_position(Vector2(camPos.x-1200, camPos.y-900))
	pass



func _on_TextureButton_mouse_entered(ch):
	var price = GAME.get("Characters")[ch]["price"]
	get_node("./Price").text = str(ch, ": ", price, "$")

func _on_TextureButton_pressed(ch):
	if GAME.get("state") == "game":
		var dir = GAME.get("DIR")
		GAME.requestCharacter(ch, dir)


func _on_menu_btn_pressed(ch):
	if ch == "local":
		GAME.go_local()

	GAME.establish_connection()


func _on_Button_pressed():
	var _process = OS.execute(OS.get_executable_path(), OS.get_cmdline_args(), false, [])
