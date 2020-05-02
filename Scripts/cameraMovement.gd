extends Camera2D

func _process(_delta):
	var pos = get_global_mouse_position()
	# Jeg behøver ikke at skrive $Camera2D, fordi scriptet sidder på kameraet. 
	# Det betyder at jeg kan tilgå dens egenskaber direkte :)
	position.x = pos.x
	pass
