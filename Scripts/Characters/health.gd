extends KinematicBody2D


var maxHealth: float = 100 # skal være en float ellers kommer det ikke til at virke
var health: float = 100 # ditto
var dead = false # det giver vel ldit sig selv.
var healthBarSize = 20 # størrelsen på en normal health bar
var healthSet = false # sikre at man ikke lige pludselig kommer til at heale en karakter

var alpha: float = 1 # når karakterene dør bliver denne variable gradvist mindre
# indtil den er 0. Når det sker fjerner vi karakteren fra spillet.

# vi snupper lige karakter objektet fram setup.gd, da vi skal tilgå den et par gange
onready var Characters = get_node("/root/Game").get("Characters")


# Idéen er at alle karakterer kalder denne funktion første gang de bliver sat ind i spillet
func set_health(hp):
	if !healthSet: # 	   første gang denne funktion bliver kaldt
		healthSet = true # bliver begge variabler indstillet.
		health = hp

	maxHealth = hp

	# baserne har en længere healthbar for at vise at de har mere liv.
	# get_node(".") Tager bare den 'node' som scriptet sidder på. Altså enten en karakter eller en base.
	if get_node(".").get("Type") == "base":
		healthBarSize = 500


# denne funktion bliver kaldt når en anden karakter slår den her karakter.
func takeDamage(name_of_character, animSprite):

	# bare lige for en sikkerhedsskyld sikre vi mig at karakteren findes
	if !Characters.has(name_of_character):
		return false

	var damage = Characters[name_of_character]["damage"]["hit"]

	# hvis angriberen har ekstra skade når den skyder fra lang afstand så
	if Characters[name_of_character]["damage"].has("shoot"):
		var anim = animSprite.animation.split("_")[1]
		# hvis angriberen er i gang med at gå, giver det muligvis ekstra skade!
		if anim != null and anim == "walk&shoot" or anim == "stand&shoot" or anim == "walk":
			damage = Characters[name_of_character]["damage"]["shoot"]
		
	health -= damage # vi trækker skaden fra.

	# opdatering af health bar
	var gui = get_node_or_null("Gui")
	if gui != null:
		var bar = get_node("Gui/hp_bar")
		var a: float = health / maxHealth * healthBarSize
		bar.set_size(Vector2(a, bar.get_size().y))
		# du tænker måske: hvorfor ændre du dog på x værdien, når basernes healthbar vender op af???
		#  -> vi har bare drejet dem 270 grader ;)
		

	if health <= 0: # hvis den ikke har mere liv tilbage
		if !dead and get_node(".").get("Type") != "base":
			# gælder for alle karakterer bortset fra baserne.
			# vi vælger animationen dø, gør kollisionboxen uduelig og gør healthbaren usynligt.
			get_node(".").set_animation("die")
			get_node(".").get_node("CollisionShape2D").disabled = true
			get_node(".").get_node("Gui").visible = false
			dead = true
	

		# specielt for baser!
		if get_node(".").get("Type") == "base":
			if get_node("/root/Game").get("DIR") == get_node(".").get("direction"):
				# Det er hvis man selv taber
				OS.alert("DU HAR TABT!", "ØV BØV")
			else:
				# Og hvis man vinder!
				OS.alert("Du tværede ham den anden!", "Tillykke")

			# uanset hvad slutter spillet efter man har trykket ok :)
			get_tree().quit()

	return true


func _process(delta):
	# idéen er at lade karakteren 'fade' ud når den dør
	if dead:
		alpha -= delta # så det ser ens ud uanset framerate
		if alpha < 0:
			# Når den er helt usynlig tjekker vi lige om det var en fjende 
			if get_node(".").get("direction") != get_node("/root/Game").get("DIR"):
				# Og hvis det var en fjende giver vi lige os selv flere penge!
				var won_money = Characters[get_node(".").get("Type")]["price"] * 2
				# ganger bare prisen af den dræbte karakter med 2
				get_node("/root/Game").update_money(won_money)
				# update_money() ligger i setup.gd hvis du skulle være i tvivl ;)

			get_node(".").queue_free() # sletter karakteren fra spillet når det er sikkert.
		
		# ændringen af farven gennemsigtigheden.
		get_node("AnimatedSprite").modulate = Color(1, 1, 1, alpha)
