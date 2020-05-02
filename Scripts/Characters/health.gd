extends KinematicBody2D


const damageChart = {
	"clubman": 5
}

var maxHealth: float = 100
var health: float = 100
var dead = false

func set_health(hp):
	health = hp
	maxHealth = hp

func takeDamage(name_of_character):
	if !damageChart.has(name_of_character):
		return false
		
	health -= damageChart[name_of_character]


	# opdatering af healt bar
	var gui = get_node_or_null("Gui")
	if gui != null:
		var bar = get_node("Gui/hp_bar")
		var a: float = health / maxHealth * maxHealth
		bar.set_size(Vector2(a, 3))
		
	#print(get("myName"), " - ", health, "hp")

	if health <= 0:
		var animSprite = get_node('.').get("animSprite")
		var amount_of_frames = animSprite.frames.get_frame_count(animSprite.animation) - 1
		if animSprite.frame == amount_of_frames:
			get_node(".").visible = false

		if !dead:
			get_node("./AnimatedSprite").animation = str(get_node(".").get("myName"), "_die")
			get_node(".").get_node("CollisionShape2D").disabled = true
			get_node(".").get_node("Gui").visible = false
			dead = true

	return true
