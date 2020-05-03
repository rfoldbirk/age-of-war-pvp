extends "res://Scripts/Characters/movement.gd"

# Called when the node enters the scene tree for the first time.
func init(Name, Direction, Health = 15, Offsets={}, Hitframe = 20):
	Type = Name
	direction = Direction
	offsets = Offsets

	hitFrame = Hitframe

	get_node('.').set_health(Health)
	setupMovement()