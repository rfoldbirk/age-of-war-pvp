extends "res://Scripts/Characters/health.gd"

onready var animSprite = get_node_or_null("AnimatedSprite")
onready var collider = get_node("CollisionShape2D")

# disse variabler får deres værdier fra rummet 👽🌌🤷
var direction
var myName
var offsets
var hitFrame

var setupDone = false

func setupMovement():
	# print("Oprettede: ", myName)

	visible = true
	get_node("CollisionShape2D").disabled = false

	if animSprite == null:
		animSprite = get_node("Sprite")

	if myName != 'base' or myName == null:
		animSprite.playing = true
		animSprite.animation = str(myName, '_idle')

	
	if (direction == 1):
		animSprite.flip_h = false
		if myName != 'base':
			collider.position.x = offsets.collider[0]
	else:
		animSprite.flip_h = true
		if myName != 'base':
			collider.position.x = offsets.collider[1]

	setupDone = true


var deb = true
var hitDeb = true
var hasNotHitDeb = true
var currentTarget


func _process(_delta):
	if myName == 'base' or !setupDone or get_node(".").dead:
		return
		

	# offset så spritesne passer
	animSprite.offset = offsets[ animSprite.animation.split('_')[1] ] [str(direction)]

	# hit animationen er ikke sat til at loope
	if !hitDeb:
		var amount_of_frames = animSprite.frames.get_frame_count(animSprite.animation) - 1
		if animSprite.frame == amount_of_frames:
			hitDeb = true

		if animSprite.frame == hitFrame and hasNotHitDeb:
			currentTarget.takeDamage(myName)
			hasNotHitDeb = false

	var collisionObject = move_and_collide(Vector2(direction * 1, 0))
	if collisionObject != null and deb:
		#deb = false

		if hitDeb:
			animSprite.animation = str(myName, '_idle')

		var target = collisionObject.collider
		var sprite = target.get_node_or_null("Sprite")

		if sprite == null:
			sprite = target.get_node_or_null("AnimatedSprite")

		if target == null or sprite == null:
			return

		if sprite.flip_h != get_node("AnimatedSprite").flip_h && hitDeb:
			# det betyder at vi er stødt ind i en fjende
			animSprite.animation = str(myName, '_hit')
			animSprite.frame = 0 # for en sikkerhedsskyld sørger jeg for at animationen starter helt fra begyndelsen
			hitDeb = false # sikre at denne 'event' ikke bliver trigget alt for hurtigt
			hasNotHitDeb = true
			currentTarget = target
	else:
		# hvis den ikke kolliderer med noget, skal den bare køre gå animationen.
		if hitDeb:
			animSprite.animation = str(myName, '_walk')

	pass
