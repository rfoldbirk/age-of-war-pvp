extends "res://Scripts/Characters/health.gd"

# i en karakter er der umildbart 4 vigtige objekter
onready var animSprite = get_node_or_null("AnimatedSprite") # vores animeret sprite
onready var collider = get_node("CollisionShape2D") # kollisionsboxen
onready var raycast = get_node_or_null("RayCast2D") # en raycaster, som vi bruger til at tjekke for kollisioner
onready var Sight = get_node_or_null("Sight") # og endnu en raycaster, som vi bruger til at kigge fremad med.

# disse variabler får deres værdier fra rummet    
var direction # i vores spil bruger vi denne variable til at kende forskel på fjende og ven ... 1=mod højre : -1=mod venstre
var Type # det er bare karakterens navn
var offsets # da de forskellige animationer har forskellige højder har vi manuelt sat forskellige offsets. Hver karakter har mange animationer og hver animation har sit eget offset. Du kan se dem i setup.gd
var hitFrame # den frame hvor angrebet bliver kalkuleret
var reach = 0 # bare en default værdi. Hvor langt karakteren kan slå ud med sit angreb

var setupDone = false # ... Den må ikke starte med at gøre noget før alt er sat op ordenligt. Derfor denne variable.__data__

# de fleste debiance variabler findes her
var not_in_the_middle_of_shooting = true # betyder bare at den ikke er i gang med at skyde
var not_in_the_middle_of_hitting = true # når den er true, betyder det at karakteren ikke er i gang med at angribe
var target_has_not_taken_dmg = true # sikre at målet ikke tager skade mere end én gang
var currentTarget # det nuværende mål
var may_not_move = false # hvis karakteren ikke må bevæge sig
var dont_play_walk_anim = false
# ærligt tal forklare variablerne sig selv...


func init(Name, Direction, Health = 15, Offsets={}, Hitframe = 20):
	Type = Name
	direction = Direction
	get_node(".").set_health(Health)
	offsets = Offsets
	hitFrame = Hitframe

	visible = true # sørger lige for at den er synlig
	collider.disabled = false # og at den kan kollidere :)

	if animSprite == null: # Baser har ikke brug for en animation
		animSprite = get_node("Sprite") # så i deres tilfælde snupper vi bare en normal sprite i stedet.

	if Type != 'base' or Type == null:
		animSprite.playing = true # hvis det ikker en base, går vi udfra at den kan animeres.
		set_animation('idle') # så vi sætter animationen til idle

	
	if (direction == 1): # yes... vi vender bare billederne om
		animSprite.flip_h = false
	else:
		animSprite.flip_h = true
	

	# det ser lidt rodet ud, men det eneste vi gør er at gange de forskellige raycasts retninger med direction
	# sådan at de vender korrekt
	get_node("RayCast2D").set_cast_to(Vector2(direction*get_node("RayCast2D").get_cast_to().x, 0))
	get_node("RayCast2D").set_position(Vector2(get_node("RayCast2D").position.x*direction, 0))
	get_node("Sight").set_cast_to(Vector2(direction*get_node("Sight").get_cast_to().x, 0))


	# tager deres rigtige rækkevidde.
	if get_node("/root/Game").get("Characters")[Type].has("reach"):
		reach = get_node("/root/Game").get("Characters")[Type]["reach"]

	setupDone = true






func _process(delta): # bliver kaldt hvert frame.
	# sikre at det ikke kører før det er meningen
	if Type == 'base' or !setupDone or get_node("/root/Game").get("state") != "game":
		return


	# offset så spritesne passer
	# som sagt har de forskellige animationer forskellige offsets.
	# det tager vi mig af her.
	animSprite.offset.x = offsets[ animSprite.animation.split('_')[1] ].x * direction
	animSprite.offset.y = offsets[ animSprite.animation.split('_')[1] ].y


	if get_node(".").dead: # hvis nu den var død, så skal vi ikke forsøge at bevæge den
		return

	# hit animationen er ikke sat til at loope, så derfor gør vi det manuelt
	if !not_in_the_middle_of_hitting or !not_in_the_middle_of_shooting:
		var amount_of_frames = animSprite.frames.get_frame_count(animSprite.animation) - 1
		if animSprite.frame == amount_of_frames: # når den er færdig med at angribe
			not_in_the_middle_of_hitting = true
			not_in_the_middle_of_shooting = true


		# når vi rammer den frame, hvor det meningen at målet skal tage skade.
		if animSprite.frame == hitFrame and target_has_not_taken_dmg and currentTarget:
			currentTarget.takeDamage(Type, animSprite) # Så giver vi skade
			target_has_not_taken_dmg = false # bare for at være sikker



	may_not_move = false # den er falsk, med mindre den bliver gjort til sand.


	# fjerner temporary collision exceptions
	Sight.clear_exceptions()
	Sight.add_exception(get_node(".")) # hvis man ikke tilføjer sig selv, står alt bare stille
	
	check_for_collisions() # en funktion som tjekker for kollisioner
		
	if !may_not_move and not_in_the_middle_of_hitting: # må godt bevæge sig
		position.x += direction * 120 * delta # rykker på karakteren med en hardcoded værdi :/
		if not_in_the_middle_of_shooting: # hvis f.eks. at den går og skyder samtidigt
			set_animation('walk') # så skal denne animation ikke afspilles
			# derfor har vi den variable
	pass # pass er faktisk ikke nødvendigt men det er nogle gange meget rart lige at se hvornår en funktion er færdig


func check_for_collisions():
	var obj = get_collision() # en funktion som returner en kollision og noget dejlig information

	if obj.result:
		var target = obj.target
		var enemy = obj.enemy
		var distance = obj.distance

		var may_look_forward = false

		if distance < reach["hit"]: # hvis den er inden for slå distance
			may_not_move = true # så må den jo ikke bevæge sig længere
			if not_in_the_middle_of_hitting:
				if enemy:
					# sætter bare en masse variabler og afspiller animationen
					set_animation('hit', true)
					not_in_the_middle_of_hitting = false # sikre at denne 'event' ikke bliver trigget alt for hurtigt
					target_has_not_taken_dmg = true
					currentTarget = target
				else: # hvis det bare er en ven den står bag
					may_not_move = true
					if reach.has("shoot"): # hvis den kan skyde, beder vi den om at kigge længere fremad.
						may_look_forward = true
					else:
						set_animation('idle')
					
		elif reach.has("shoot"): # hvis den har muligheden for at skyde
			if distance < reach["shoot"]: # hvis den er inden for den rigtige distance
				may_look_forward = true

		
		if may_look_forward:
			# først tjekker vi lige om den er i gang med noget andet
			if may_not_move and animSprite.animation.split("_")[1] == "walk&shoot":
				var lastFrame = animSprite.frame # hvis den er i gang med at gå og skyde, men egentlig bør den stå stille og skyde
				set_animation("stand&shoot") # det fikser jeg her
				animSprite.frame = lastFrame # sørger for at den forsætter hvor den slap


			if not_in_the_middle_of_shooting: # hvis den ikke er i gang...
				var col = look_forward() # col for collison :D
				if col.result:
					not_in_the_middle_of_shooting = false
					target_has_not_taken_dmg = true
					currentTarget = col.target

					if may_not_move:
						set_animation("stand&shoot", true)
					else:
						set_animation("walk&shoot", true)
				else:
					if may_not_move:
						set_animation("idle")
				
	else:
		# og hvis ikke der sker nogen form for kollision så...
		not_in_the_middle_of_hitting = true
		not_in_the_middle_of_shooting = true

	pass


func look_forward(iteration=0):
	# sørger lige for at det ikke fortsætter for evigt
	iteration += 1
	if iteration > 2:
		return {"result": false}

	# det eneste denne funktion gør er at den kigger frem via en raycaster
	# og hvis den støder ind i noget tjekker den om det er en fjende.
	# hvis det bare er en ven tilføjer den den ven til en liste over emner strålen skal ignore
	# anden gang den kigger fremad ser den måske en fjende
	# det gør det altså muligt at skyde på en fjende selvom man står bag en ven.

	var col = get_collision(Sight)
	if !col.result:
		return {"result": false}

	
	if col.enemy:
		return col
	else:
		Sight.add_exception(col.target)
		return look_forward(iteration)


func get_collision(custom_ray = raycast): # man vælger selv hvilken raycaster man bruger, men det normale er raycast og ikke Sight
	if custom_ray.is_colliding():
		var target = custom_ray.get_collider()
		var sprite = target.get_node_or_null("Sprite")
		if sprite == null:
			sprite = target.get_node_or_null("AnimatedSprite")

		var distance = position.x - custom_ray.get_collision_point().x
		if distance < 0:
			distance = -distance

		distance -= reach["hit"]/2

		var enemy = false

		if sprite.flip_h != get_node("AnimatedSprite").flip_h:
			enemy = true

		# det eneste denne funktion faktisk gør er at beregne distancen,
		# tjekke om det er ven eller fjende, og ellers returnerer den
		# bare et dejlig nemt objekt (dictionary, hvis det skal være helt rigtigt)

		return {
			"result": true,
			"target": target,
			"enemy": enemy,
			"sprite": sprite,
			"distance": distance
		}
	else:
		# hvis der ikke sker nogen kollision
		return { "result": false }
	



# Du kan bruge denne funktion til at skifte animation på karakteren
func set_animation(anim_name="idle", reset_frame=false):
	# alle de forskellige animationer er navngivet således:
	# navn = karakternavn + '_' + animation type
	# Derfor når jeg skal have fat i den rigtige animation,
	# skal jeg blot strikke karakterens navn og den slags animation jeg gerne vil have sammen.
	animSprite.animation = str(Type, '_', anim_name)
	if reset_frame:
		animSprite.frame = 0
