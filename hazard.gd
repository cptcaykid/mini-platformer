extends Area2D
# A row of spikes. Origin is the bottom-left corner.

var width = 64.0


func _ready():
	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(width - 8.0, 12.0)
	cs.shape = shape
	cs.position = Vector2(width / 2.0, -6.0)
	add_child(cs)

	var count = int(width / 16.0)
	for i in count:
		var tri = Polygon2D.new()
		tri.polygon = PackedVector2Array([
			Vector2(i * 16, 0),
			Vector2(i * 16 + 8, -16),
			Vector2((i + 1) * 16, 0),
		])
		tri.color = Color(0.75, 0.75, 0.80)
		add_child(tri)


func _physics_process(_delta):
	for b in get_overlapping_bodies():
		if b.is_in_group("player"):
			b.die()
