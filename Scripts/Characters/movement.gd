extends "res://Scripts/Characters/health.gd"

onready var animSprite = get_node_or_null("AnimatedSprite")
onready var collider = get_node("CollisionShape2D")

# disse variabler får deres værdier fra rummet    
var direction
var Type
var offsets
var hitFrame
var width

var setupDone = false

func setupMovement():
	# print("Oprettede: ", Type)

	visible = true
	get_node("CollisionShape2D").disabled = false

	if animSprite == null:
		animSprite = get_node("Sprite")

	if Type != 'base' or Type == null:
		animSprite.playing = true
		animSprite.animation = str(Type, '_idle')

	
	if (direction == 1):
		animSprite.flip_h = false
		
	else:
		animSprite.flip_h = true

	if Type != 'base':
		collider.position.x = direction * offsets.collisionBox.offset.x
		collider.position.y = direction * offsets.collisionBox.offset.y
	
	get_node("RayCast2D").set_cast_to(Vector2(direction*get_node("RayCast2D").get_cast_to().x, 0))


	width = get_node("/root/Game").get("Characters")[Type]["width"]

	setupDone = true


var deb = true
var hitDeb = true
var hasNotHitDeb = true
var currentTarget
var mayNotMove = false

onready var raycast = get_node_or_null("RayCast2D")

func _process(delta):
	if Type == 'base' or !setupDone or get_node("/root/Game").get("state") != "game":
		return
		

	# offset så spritesne passer
	animSprite.offset.x = offsets[ animSprite.animation.split('_')[1] ].x * direction
	animSprite.offset.y = offsets[ animSprite.animation.split('_')[1] ].y


	if get_node(".").dead:
		return

	# hit animationen er ikke sat til at loope
	if !hitDeb:
		var amount_of_frames = animSprite.frames.get_frame_count(animSprite.animation) - 1
		if animSprite.frame == amount_of_frames:
			hitDeb = true

		if animSprite.frame == hitFrame and hasNotHitDeb:
			currentTarget.takeDamage(Type)
			hasNotHitDeb = false


	mayNotMove = false

	if raycast.is_colliding():
		var target = raycast.get_collider()
		var sprite = target.get_node_or_null("Sprite")
		if sprite == null:
			sprite = target.get_node_or_null("AnimatedSprite")

		var distance = position.x - raycast.get_collision_point().x
		if distance < 0:
			distance = -distance

		distance -= width/2

		var enemy = false

		if sprite.flip_h != get_node("AnimatedSprite").flip_h:
			enemy = true	

		if target.Type == "base":
			distance -= 0
			

		if distance < width:
			mayNotMove = true
			if hitDeb:
				if enemy:
					animSprite.animation = str(Type, '_hit')
					animSprite.frame = 0 # for en sikkerhedsskyld sørger jeg for at animationen starter helt fra begyndelsen
					hitDeb = false # sikre at denne 'event' ikke bliver trigget alt for hurtigt
					hasNotHitDeb = true
					currentTarget = target
				else:
					animSprite.animation = str(Type, '_idle')
		
			

	if !mayNotMove and hitDeb: # må godt bevæge sig
		position.x += direction * 120 * delta
		animSprite.animation = str(Type, '_walk')

	# else:
	# 	# var collisionObject = move_and_collide(Vector2(direction * 1, 0))

		# if collisionObject != null and deb:
		# 	#deb = false
		# 	cantMove(collisionObject)
			
		# else:
		# 	# hvis den ikke kolliderer med noget, skal den bare afspille gå animationen.
		# 	if hitDeb:
		# 		animSprite.animation = str(Type, '_walk')
	
	pass




func cantMove(collisionObject):
	if hitDeb:
		animSprite.animation = str(Type, '_idle')

	var target = collisionObject.collider
	var sprite = target.get_node_or_null("Sprite")

	if sprite == null:
		sprite = target.get_node_or_null("AnimatedSprite")

	if target == null or sprite == null:
		return

	if sprite.flip_h != get_node("AnimatedSprite").flip_h && hitDeb:
		# det betyder at vi er stødt ind i en fjende
		animSprite.animation = str(Type, '_hit')
		animSprite.frame = 0 # for en sikkerhedsskyld sørger jeg for at animationen starter helt fra begyndelsen
		hitDeb = false # sikre at denne 'event' ikke bliver trigget alt for hurtigt
		hasNotHitDeb = true
		currentTarget = target
