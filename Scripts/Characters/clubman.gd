extends "res://Scripts/Characters/movement.gd"

var dir = -1

# Called when the node enters the scene tree for the first time.
func init():
	myName = "clubman"
	direction = dir
	offsets = {
		"idle": {
			"1": Vector2(0, 0), 
			"-1": Vector2(0, 0),
		},
		"hit": {
			"1": Vector2(-3.815, -7), 
			"-1": Vector2(1.753, -7),
		},
		"walk": {
			"1": Vector2(2.4, 0), 
			"-1": Vector2(2.4, 0),
		},
		"die": {
			"1": Vector2(0, 0), 
			"-1": Vector2(0, 0),
		},
		"collider": [
			-6.154,
			5.437
		]
	}

	hitFrame = 20
	get_node('.').set_health(15)
	setupMovement()
	pass # Replace with function body.

