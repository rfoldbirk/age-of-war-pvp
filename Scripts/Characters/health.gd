extends KinematicBody2D


var maxHealth: float = 100 # skal være en float ellers
var health: float = 100 # kommer det ikke til at virke
var dead = false
var healthBarSize = 20
var healthSet = false

func set_health(hp):
	if !healthSet: # 	   første gang denne funktion bliver kaldt
		healthSet = true # bliver begge variabler indstillet.
		health = hp

	maxHealth = hp

	if get_node(".").get("Type") == "base":
		healthBarSize = 500

func takeDamage(name_of_character):
	var Characters = get_node("/root/Game").get("Characters")

	if !Characters.has(name_of_character):
		return false
		
	health -= Characters[name_of_character]["damage"]

	if get_node(".").get("direction") == -1 and get_node(".").get("Type") == "base":
		get_node("/root/Game").requestCharacter("dinorider", -1)

	# opdatering af healt bar
	var gui = get_node_or_null("Gui")
	if gui != null:
		var bar = get_node("Gui/hp_bar")
		var a: float = health / maxHealth * healthBarSize
		bar.set_size(Vector2(a, bar.get_size().y))
		

	if health <= 0:
		if !dead and get_node(".").get("Type") != "base":
			# gælder for alle karakterer bortset fra baserne.
			get_node("./AnimatedSprite").animation = str(get_node(".").get("Type"), "_die")
			get_node(".").get_node("CollisionShape2D").disabled = true
			get_node(".").get_node("Gui").visible = false
			dead = true
		else:
			get_node("/root/Game").set_state("result")

	return true
