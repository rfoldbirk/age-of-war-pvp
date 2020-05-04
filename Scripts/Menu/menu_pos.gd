extends Control

func _process(_delta):
	var camPos = get_parent().get_node("Camera2D").get_camera_screen_center()
	set_position(Vector2(camPos.x-1200, camPos.y-900))
	pass
