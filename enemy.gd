extends Area2D
# Walks back and forth. Jump on its head to squish it; touch it otherwise and you die.

var left_x = 0.0
var right_x = 0.0
var speed = 70.0
var dir = 1


func _ready():
	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(28, 28)
	cs.shape = shape
	cs.position = Vector2(0, -14)
	add_child(cs)

	var body = ColorRect.new()
	body.position = Vector2(-14, -28)
	body.size = Vector2(28, 28)
	body.color = Color(0.85, 0.15, 0.15)
	add_child(body)

	for ex in [-9, 3]:
		var eye = ColorRect.new()
		eye.position = Vector2(ex, -22)
		eye.size = Vector2(6, 6)
		eye.color = Color.WHITE
		add_child(eye)


func _physics_process(delta):
	position.x += dir * speed * delta
	if position.x > right_x:
		dir = -1
	elif position.x < left_x:
		dir = 1

	for b in get_overlapping_bodies():
		if b.is_in_group("player") and not b.dead:
			# Player feet above the top part of the enemy and falling = stomp
			if b.velocity.y > 0.0 and b.global_position.y + 20.0 < global_position.y - 12.0:
				b.bounce()
				queue_free()
				return
			else:
				b.die()
