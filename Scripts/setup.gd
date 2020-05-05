extends "res://Scripts/ws.gd"

var state = "pause"
var DIR = 2
var MONEY = 150

var MONEY_GIVING_TIMER = 0

onready var countdown = get_node("/root/Game/Control/Countdown")
onready var moneylbl = get_node("/root/Game/Control/Money")

func setup(s, d):
	state = s
	DIR = d

const Characters = {
	"base": {
		"health": 500
	},
	"Club Man": {
		"offsets": {
			"idle": Vector2(35.871, 0),
			"hit": Vector2(49.361, -37.567),
			"walk": Vector2(23.057, 0),
			"die": Vector2(-48.414, 231.029),
			"collisionBox": {
				"size": Vector2(0, 0),
				"offset": Vector2(0, 0)
			}
		},
		"price": 25,
		"hitframe": 20,
		"health": 140,
		"spawnTime": 0.1,
		"damage": {
			"hit": 25
		},
		"reach": {
			"hit": 100
		}
	},
	"Slingshot Man": {
		"offsets": {
			"idle": Vector2(5.022, -1.891),
			"hit": Vector2(47.156, -25.156),
			"walk": Vector2(5.022, -1.891),
			"die": Vector2(-57.071, 300.882),
			"walk&shoot": Vector2(62, -4),
			"stand&shoot": Vector2(81, -2),
			"collisionBox": {
				"size": Vector2(0, 0),
				"offset": Vector2(0, 0)
			}
		},
		"price": 50,
		"hitframe": 20,
		"health": 90,
		"spawnTime": 1,
		"damage": {
			"hit": 10,
			"shoot": 70
		},
		"reach": {
			"hit": 100,
			"shoot": 1000
		}
	},
	"Dino Rider": {
		"offsets": {
			"idle": Vector2(35.871, -72.082),
			"hit": Vector2(88.292, -68.761),
			"walk": Vector2(36.369, -68.761),
			"die": Vector2(-108.957, -58.535),
			"collisionBox": {
				"size": Vector2(0, 0),
				"offset": Vector2(0, 0)
			}
		},
		"price": 100,
		"hitframe": 20,
		"health": 190,
		"spawnTime": 2.5,
		"damage": {
			"hit": 40
		},
		"reach": {
			"hit": 190
		}
	}
}


# Called when the node enters the scene tree for the first time.
func _ready():
	print(OS.get_system_time_msecs())

	get_node("Characters").visible = false
	get_node("Characters").get_node("CollisionShape2D").disabled = true
	get_node("Characters/AnimatedSprite").position = Vector2.ZERO

	var second_base = get_node("base").duplicate()
	second_base.position.x = 1000
	add_child(second_base)

	get_node("base").init("base", 1, Characters["base"]["health"])
	second_base.init("base", -1, Characters["base"]["health"])

	update_money(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if state != "game":
		return

	var client_btn = get_node_or_null("/root/Game/Control/second_client")
	if client_btn != null:
		client_btn.queue_free()

	MONEY_GIVING_TIMER += _delta

	if MONEY_GIVING_TIMER >= 1:
		MONEY_GIVING_TIMER = 0
		if MONEY > 150:
			update_money(-1)
		elif MONEY < 150:
			update_money(1)

	if Queue.size() == 0:
		return

	var item = Queue[0]
	
	var time = OS.get_system_time_msecs()

	if time >= item.spawnTime:
		print('Spawning: ', item.name)
		Queue.pop_front()
		spawnCharacter(item.name, item.direction)
		countdown.text = ""
	else:
		var timeLeft = item.spawnTime - time
		if item.direction == DIR:
			countdown.text = str(stepify(timeLeft/1000, 1)+1)
	

func canSpawn(direction):
	var children = get_children()
	var base

	for i in children:
		if i.get("direction") == direction and i.get("Type") == "base":
			base = i

	if base == null:
		return false

	var raycast = base.get_node("RayCast2D")
	if !raycast.is_colliding():
		return true

	return false


var Queue = []

func update_money(amount):
	if MONEY + amount < 0:
		return false
	MONEY += amount
	moneylbl.text = str(MONEY, "$")
	return true

func get_total_spawntime(d):
	var t = 0
	for i in Queue:
		if d == i.direction:
			t += Characters[i.name]["spawnTime"]

	return t


func requestCharacter(name="Club Man", direction=1):
	if !update_money(-Characters[name]["price"]):
		return

	_client.get_peer(1).put_packet(JSON.print({
		"event":"requestCharacter",
		"name": name,
		"direction": direction,
		"spawnTime": OS.get_system_time_msecs() + (get_total_spawntime(direction) + Characters[name]["spawnTime"]) * 1000
	}).to_utf8())


func spawnCharacter(name, direction, x=0):
	var Man = get_node("Characters").duplicate()
	if direction == 1:
		Man.position.x = -2523.308 + (x*direction)
	else:
		Man.position.x = 476.563 + (x*direction)

	add_child(Man)
	Man.init(name, direction, Characters[name]["health"], Characters[name]["offsets"], Characters[name]["hitframe"])
