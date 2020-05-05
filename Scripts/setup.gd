extends "res://Scripts/ws.gd"

var state = "pause"
var DIR = 2 # denne klients retning... bliver alligevel overskrevet
var MONEY = 150 # klientens penge

var MONEY_GIVING_TIMER = 0

var Queue = []

# to labels
onready var countdown = get_node("/root/Game/Control/Countdown")
onready var moneylbl = get_node("/root/Game/Control/Money")

func setup(s, d): # bliver kaldt fra ws.gd
	state = s
	DIR = d


# et stort objekt med alle karakterene og deres egenskaber
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
	# igennem spillet kloner vi faktisk bare en forudlavet karakter
	# vi gør ham usynlig og slukker hans kollisionbox så de andre karakterer ikke løber ind i en usynlig mand.
	get_node("Characters").visible = false
	get_node("Characters").get_node("CollisionShape2D").disabled = true
	get_node("Characters/AnimatedSprite").position = Vector2.ZERO

	# vi laver også en klon af den venstre base og placere den i højre side af banen.
	var second_base = get_node("base").duplicate()
	second_base.position.x = 1000
	add_child(second_base) # tilføjer den til objektet Game

	get_node("base").init("base", 1, Characters["base"]["health"])
	second_base.init("base", -1, Characters["base"]["health"])

	update_money(0) # en funktion som tilføjer og derefter opdaterer skriften



func _process(_delta):
	if state != "game":
		return

	MONEY_GIVING_TIMER += _delta # man får en månt hvert sekund

	if MONEY_GIVING_TIMER >= 1:
		MONEY_GIVING_TIMER = 0
		if MONEY > 150: # til gengæld mister man penge hvis man er over 150.
			update_money(-1)
		elif MONEY < 150:
			update_money(1)

	if Queue.size() == 0:
		return

	var item = Queue[0]
	
	var time = OS.get_system_time_msecs()

	# vi sætter en tid i fremtiden hvor karakterene må spawne.
	# derefter tjekker vi konstant om det er tid til at spawne dem

	if time >= item.spawnTime:
		Queue.pop_front() # fjerner den fra køen
		spawnCharacter(item.name, item.direction)
		countdown.text = "" # fjerner nedtællingen
	else:
		# hvis der er mere tid tilbage regner vi ud hvor meget tid der er tilbage
		if item.direction == DIR: # hvis det er en af vores egne mænd:
			var timeLeft = item.spawnTime - time
			countdown.text = str(stepify(timeLeft/1000, 1)+1) # runder vi ned op plusser med en, så vi kan se hvor mange sekunder der er tilbage.
	



func update_money(amount):
	# hvis slutbeløbet ryger under nul, er transaktionen ikke tilladet

	if MONEY + amount < 0:
		return false

	# ellers er det fint
	MONEY += amount
	moneylbl.text = str(MONEY, "$")
	return true


func get_total_spawntime(d):
	# bruges til at beregne hvor meget ekstra spawntid der skal være for et bestemt hold
	# den tjekker de karakterer, som allerede er i køen og hvis retningen er den rigtige bliver de tilføjet i regnestykket
	var t = 0
	for i in Queue:
		if d == i.direction:
			t += Characters[i.name]["spawnTime"]

	return t


func requestCharacter(name="Club Man", direction=1):
	if !update_money(-Characters[name]["price"]):
		return

	# serveren bliver altså kun underrettet hvis der er penge nok

	_client.get_peer(1).put_packet(JSON.print({
		"event":"requestCharacter",
		"name": name,
		"direction": direction,
		"spawnTime": OS.get_system_time_msecs() + (get_total_spawntime(direction) + Characters[name]["spawnTime"]) * 1000
	}).to_utf8())


# funktionen bliver kaldt når der kommer signal fra serveren.
func spawnCharacter(name, direction, x=0): # x blev udlukkende brugt til debugging
	var Man = get_node("Characters").duplicate()
	if direction == 1:
		Man.position.x = -2523.308 + (x*direction)
	else:
		Man.position.x = 476.563 + (x*direction)

	add_child(Man)

	# kalder karakterens init funktion så den kan begynde at kæmpe
	Man.init(name, direction, Characters[name]["health"], Characters[name]["offsets"], Characters[name]["hitframe"])
