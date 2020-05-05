extends KinematicBody2D


var maxHealth: float = 100 # skal være en float ellers kommer det ikke til at virke
var health: float = 100 # ditto
var dead = false # det giver vel ldit sig selv.
var healthBarSize = 20 # størrelsen på en normal health bar
var healthSet = false # sikre at man ikke lige pludselig kommer til at heale en karakter

var remove_timer = 0
var remove_timer_max = 10 # ca. hvor mange sekunder før lig bliver fjernet
var alpha: float = 1

onready var Characters = get_node("/root/Game").get("Characters")

func set_health(hp):
	if !healthSet: # 	   første gang denne funktion bliver kaldt
		healthSet = true # bliver begge variabler indstillet.
		health = hp

	maxHealth = hp

	if get_node(".").get("Type") == "base":
		healthBarSize = 500

func takeDamage(name_of_character):

	if !Characters.has(name_of_character):
		return false

	var damage = Characters[name_of_character]["damage"]["hit"]
	if Characters[name_of_character]["damage"].has("shoot") and get_node(".").get("Type") == "Club Man":
		var anim = get_node('.').get("animSprite").animation.split("_")[1]
		print(anim)
		if anim == "walk&shoot" or anim == "stand&shoot" or anim == "walk":
			damage = Characters[name_of_character]["damage"]["shoot"]
		
	health -= damage

	# opdatering af healt bar
	var gui = get_node_or_null("Gui")
	if gui != null:
		var bar = get_node("Gui/hp_bar")
		var a: float = health / maxHealth * healthBarSize
		bar.set_size(Vector2(a, bar.get_size().y))
		# du tænker måske: hvorfor ændre du dog på x værdien, når basernes healthbar vender op af???
		#  -> jeg har bare drejet dem 270 grader ;)
		

	if health <= 0:
		if !dead and get_node(".").get("Type") != "base":
			# gælder for alle karakterer bortset fra baserne.
			# jeg vælger animationen dø, gør kollisionboxen uduelig og gør healthbaren usynligt.
			get_node(".").set_animation("die")
			get_node(".").get_node("CollisionShape2D").disabled = true
			get_node(".").get_node("Gui").visible = false
			dead = true
	
		if get_node(".").get("Type") == "base":
			if get_node("/root/Game").get("DIR") == get_node(".").get("direction"):
				# mig selv
				OS.alert("DU HAR TABT!", "ØV BØV")
			else:
				OS.alert("Du tværede ham den anden!", "Tillykke")

			get_tree().quit()

	return true


func _process(delta):
	if dead:
		alpha -= delta
		if alpha < 0:
			# det er her de dør
			if get_node(".").get("direction") != get_node("/root/Game").get("DIR"):
				var won_money = Characters[get_node(".").get("Type")]["price"] * 2

				get_node("/root/Game").update_money(won_money)

			get_node(".").queue_free()
		get_node("AnimatedSprite").modulate = Color(1, 1, 1, alpha)