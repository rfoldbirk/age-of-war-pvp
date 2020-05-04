extends "res://Scripts/Characters/health.gd"

onready var animSprite = get_node_or_null("AnimatedSprite")
onready var collider = get_node("CollisionShape2D")
onready var raycast = get_node_or_null("RayCast2D")
onready var Sight = get_node_or_null("Sight")

# disse variabler får deres værdier fra rummet    
var direction
var Type
var offsets
var hitFrame
var reach = 0 # bare en default værdi

var setupDone = false

# de fleste debiance variabler findes her
var not_in_the_middle_of_shooting = true
var not_in_the_middle_of_hitting = true # når den er true, betyder det at karakteren ikke er i gang med at angribe
var target_has_not_taken_dmg = true # sikre at målet ikke tager skade mere end én gang
var currentTarget # det nuværende mål
var may_not_move = false # hvis karakteren ikke må bevæge sig
var dont_play_walk_anim = false
var temporary_collision_exceptions = []

func init(Name, Direction, Health = 15, Offsets={}, Hitframe = 20):
	# print("Oprettede: ", Type)

	Type = Name
	direction = Direction
	get_node(".").set_health(Health)
	offsets = Offsets
	hitFrame = Hitframe

	visible = true
	get_node("CollisionShape2D").disabled = false

	if animSprite == null:
		animSprite = get_node("Sprite")

	if Type != 'base' or Type == null:
		animSprite.playing = true
		set_animation('idle')

	
	if (direction == 1):
		animSprite.flip_h = false
		
	else:
		animSprite.flip_h = true

	if Type != 'base':
		collider.position.x = direction * offsets.collisionBox.offset.x
		collider.position.y = direction * offsets.collisionBox.offset.y
	
	get_node("RayCast2D").set_cast_to(Vector2(direction*get_node("RayCast2D").get_cast_to().x, 0))
	get_node("Sight").set_cast_to(Vector2(direction*get_node("Sight").get_cast_to().x, 0))


	if get_node("/root/Game").get("Characters")[Type].has("reach"):
		reach = get_node("/root/Game").get("Characters")[Type]["reach"]

	setupDone = true






func _process(delta):
	if Type == 'base' or !setupDone or get_node("/root/Game").get("state") != "game":
		return


	# offset så spritesne passer
	animSprite.offset.x = offsets[ animSprite.animation.split('_')[1] ].x * direction
	animSprite.offset.y = offsets[ animSprite.animation.split('_')[1] ].y


	if get_node(".").dead:
		return

	# * hit animationen er ikke sat til at loope
	if !not_in_the_middle_of_hitting or !not_in_the_middle_of_shooting:
		var amount_of_frames = animSprite.frames.get_frame_count(animSprite.animation) - 1
		if animSprite.frame == amount_of_frames:
			not_in_the_middle_of_hitting = true
			not_in_the_middle_of_shooting = true

		if animSprite.frame == hitFrame and target_has_not_taken_dmg and currentTarget:
			currentTarget.takeDamage(Type)
			target_has_not_taken_dmg = false


	may_not_move = false


	# * fjerner temporary collision exceptions
	Sight.clear_exceptions()
	Sight.add_exception(get_node(".")) # hvis man ikke tilføjer sig selv, står alt bare stille
	
	check_for_collisions()
		
	if !may_not_move and not_in_the_middle_of_hitting: # må godt bevæge sig
		position.x += direction * 120 * delta
		if not_in_the_middle_of_shooting:
			set_animation('walk')

	pass


func check_for_collisions():
	if raycast.is_colliding():
		var obj = get_collision()
		var target = obj.target
		var enemy = obj.enemy
		var sprite = obj.sprite
		var distance = obj.distance

		if sprite.flip_h != get_node("AnimatedSprite").flip_h:
			enemy = true	

		if target.Type == "base":
			distance -= 0
			
		var may_look_forward = false

		if distance < reach["hit"]:
			may_not_move = true
			if not_in_the_middle_of_hitting:
				if enemy:
					set_animation('hit', true)
					not_in_the_middle_of_hitting = false # sikre at denne 'event' ikke bliver trigget alt for hurtigt
					target_has_not_taken_dmg = true
					currentTarget = target
				else:
					may_not_move = true
					if reach.has("shoot"):
						may_look_forward = true
					else:
						set_animation('idle')
					
		elif reach.has("shoot"):
			if reach["shoot"]:
				may_look_forward = true

		
		if may_look_forward:
			if may_not_move and animSprite.animation.split("_")[1] == "walk&shoot":
				var lastFrame = animSprite.frame
				set_animation("stand&shoot")
				animSprite.frame = lastFrame


			if not_in_the_middle_of_shooting:
				var col = look_forward()
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
		not_in_the_middle_of_hitting = true
		not_in_the_middle_of_shooting = true

	pass


func look_forward(iteration=0):
	# sørger lige for at det ikke fortsætter for evigt
	iteration += 1
	if iteration > 5:
		return {"result": false}



	var col = get_collision(Sight)
	if !col.result:
		return {"result": false}

	
	if col.enemy:
		return col
	else:
		Sight.add_exception(col.target)
		return look_forward(iteration)


func get_collision(custom_ray = raycast):
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

		return {
			"result": true,
			"target": target,
			"enemy": enemy,
			"sprite": sprite,
			"distance": distance
		}
	else:
		return { "result": false }
	



# Du kan bruge denne funktion til at skifte animation på karakteren
func set_animation(anim_name="idle", reset_frame=false):
	animSprite.animation = str(Type, '_', anim_name)
	if reset_frame:
		animSprite.frame = 0
