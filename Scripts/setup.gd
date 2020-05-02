extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("clubman").visible = false
	get_node("clubman").get_node("CollisionShape2D").disabled = true

	var second_base = get_node("base").duplicate()
	second_base.position.x = 0
	second_base.dir = -1
	add_child(second_base)
	second_base.init()

	var cman = get_node("clubman").duplicate()
	cman.position.x = -2000
	cman.dir = 1

	add_child(cman)
	cman.init()
	
	cman.set_health(20)

	var cman2 = get_node("clubman").duplicate()
	cman2.position.x = -1000
	cman2.dir = -1

	add_child(cman2)
	cman2.init()

	var cman3 = get_node("clubman").duplicate()
	cman3.position.x = -1300
	cman3.dir = -1

	add_child(cman3)
	cman3.init()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
