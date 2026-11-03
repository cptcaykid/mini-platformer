extends Area2D
# Coin, checkpoint or goal flag, depending on `kind`.

signal touched(kind, node)

var kind = "coin"
var active = true
var flag: ColorRect


func _ready():
	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()

	if kind == "coin":
		shape.size = Vector2(22, 22)
		var gem = ColorRect.new()
		gem.position = Vector2(-7, -7)
		gem.size = Vector2(14, 14)
		gem.pivot_offset = Vector2(7, 7)
		gem.rotation = PI / 4.0
		gem.color = Color(1.0, 0.85, 0.1)
		add_child(gem)
	else:
		shape.size = Vector2(40, 64)
		cs.position = Vector2(0, -32)
		var pole = ColorRect.new()
		pole.position = Vector2(-2, -64)
		pole.size = Vector2(4, 64)
		pole.color = Color(0.9, 0.9, 0.9)
		add_child(pole)
		flag = ColorRect.new()
		flag.position = Vector2(2, -64)
		flag.size = Vector2(28, 18)
		flag.color = Color(0.5, 0.5, 0.5) if kind == "checkpoint" else Color(1.0, 0.8, 0.1)
		add_child(flag)

	cs.shape = shape
	add_child(cs)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if active and body.is_in_group("player"):
		touched.emit(kind, self)


func activate():
	active = false
	if flag:
		flag.color = Color(0.2, 0.8, 0.3)
