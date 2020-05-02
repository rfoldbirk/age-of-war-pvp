extends "res://Scripts/Characters/movement.gd"

var dir = -1

# Called when the node enters the scene tree for the first time.
func init():
	myName = "clubman"
	direction = dir
	offsets = {
		"idle": Vector2(0, 0),
		"hit": Vector2(11.69, -39.92),
		"walk": Vector2(-12.952, 0),
		"die": Vector2(-103.414, 270.302),
		"collider": [
			0,
			0
		],
		"healthbar": Vector2(-77.211, -150.236)
	}

	hitFrame = 20
	get_node('.').set_health(15)
	setupMovement()
	pass # Replace with function body.

