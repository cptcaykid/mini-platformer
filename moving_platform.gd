extends AnimatableBody2D
# Slides left and right. The player rides it automatically.

var size = Vector2(100, 20)
var amplitude = 90.0
var speed = 1.5
var origin = Vector2.ZERO
var t = 0.0


func _ready():
	origin = position
	sync_to_physics = true

	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	cs.shape = shape
	add_child(cs)

	var vis = ColorRect.new()
	vis.position = -size / 2.0
	vis.size = size
	vis.color = Color(0.55, 0.40, 0.75)
	add_child(vis)


func _physics_process(delta):
	t += delta
	position = origin + Vector2(sin(t * speed) * amplitude, 0)
