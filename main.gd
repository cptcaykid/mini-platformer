extends Node2D
# Builds the whole level in code so the project has zero asset dependencies.
# Tweak the numbers in build_level() to reshape the level.

const PlayerScript = preload("res://player.gd")
const EnemyScript = preload("res://enemy.gd")
const HazardScript = preload("res://hazard.gd")
const PickupScript = preload("res://pickup.gd")
const MovingScript = preload("res://moving_platform.gd")

var player
var spawn_point = Vector2(80, 478)
var coins = 0
var total_coins = 0
var deaths = 0
var time = 0.0
var won = false
var hud_label: Label
var msg_label: Label


func _ready():
	_setup_input()
	_build_level()
	_build_player()
	_build_hud()


func _setup_input():
	_add_action("left", [KEY_A, KEY_LEFT])
	_add_action("right", [KEY_D, KEY_RIGHT])
	_add_action("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_add_action("restart", [KEY_R])


func _add_action(action, keys):
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for k in keys:
		var e = InputEventKey.new()
		e.physical_keycode = k
		InputMap.action_add_event(action, e)


# ---------------------------------------------------------------- level

func _build_level():
	# Ground chunks and platforms: Rect2(x, y, width, height)
	var solids = [
		Rect2(0, 500, 720, 200),     # start ground
		Rect2(400, 440, 120, 20),    # small platform 1
		Rect2(570, 380, 120, 20),    # small platform 2
		Rect2(840, 500, 420, 200),   # ground 2 (spikes here)
		Rect2(1560, 500, 500, 200),  # ground 3 (enemy here)
		Rect2(2100, 440, 100, 20),   # stairs
		Rect2(2250, 380, 100, 20),
		Rect2(2400, 320, 100, 20),
		Rect2(2560, 340, 440, 300),  # goal ground
	]
	for r in solids:
		_make_solid(r)

	# Invisible walls at the level edges
	_make_wall(Rect2(-20, -500, 20, 2000))
	_make_wall(Rect2(3000, -500, 20, 2000))

	# Moving platform over the big pit
	var mp = AnimatableBody2D.new()
	mp.set_script(MovingScript)
	mp.position = Vector2(1410, 500)
	mp.size = Vector2(100, 20)
	mp.amplitude = 90.0
	mp.speed = 1.5
	add_child(mp)

	# Hazards
	_make_hazard(Vector2(980, 500), 64)

	# Enemies (origin = bottom centre): x position, ground y, patrol left, patrol right
	_make_enemy(600, 500, 480, 680)
	_make_enemy(1800, 500, 1650, 2000)

	# Checkpoints and goal (origin = bottom of pole)
	_make_pickup("checkpoint", Vector2(880, 500))
	_make_pickup("checkpoint", Vector2(1600, 500))
	_make_pickup("goal", Vector2(2900, 340))

	# Coins
	var coin_positions = [
		Vector2(180, 460), Vector2(220, 460), Vector2(260, 460),
		Vector2(460, 410), Vector2(630, 350), Vector2(780, 400),
		Vector2(900, 460), Vector2(1010, 400), Vector2(1100, 460),
		Vector2(1410, 440), Vector2(1700, 460), Vector2(1900, 460),
		Vector2(2150, 410), Vector2(2300, 350), Vector2(2450, 290),
		Vector2(2700, 300), Vector2(2760, 300),
	]
	for p in coin_positions:
		_make_pickup("coin", p)
		total_coins += 1


func _make_solid(r: Rect2):
	var body = StaticBody2D.new()
	body.position = r.position
	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	cs.position = r.size / 2.0
	body.add_child(cs)
	var dirt = ColorRect.new()
	dirt.size = r.size
	dirt.color = Color(0.45, 0.30, 0.18)
	body.add_child(dirt)
	var grass = ColorRect.new()
	grass.size = Vector2(r.size.x, 8)
	grass.color = Color(0.30, 0.65, 0.25)
	body.add_child(grass)
	add_child(body)


func _make_wall(r: Rect2):
	var body = StaticBody2D.new()
	body.position = r.position
	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	cs.position = r.size / 2.0
	body.add_child(cs)
	add_child(body)


func _make_hazard(pos: Vector2, width: float):
	var h = Area2D.new()
	h.set_script(HazardScript)
	h.width = width
	h.position = pos
	add_child(h)


func _make_enemy(x: float, y: float, left_x: float, right_x: float):
	var e = Area2D.new()
	e.set_script(EnemyScript)
	e.position = Vector2(x, y)
	e.left_x = left_x
	e.right_x = right_x
	add_child(e)


func _make_pickup(kind: String, pos: Vector2):
	var p = Area2D.new()
	p.set_script(PickupScript)
	p.kind = kind
	p.position = pos
	p.touched.connect(_on_pickup_touched)
	add_child(p)


# --------------------------------------------------------------- player

func _build_player():
	player = CharacterBody2D.new()
	player.set_script(PlayerScript)
	player.position = spawn_point
	player.died.connect(_on_player_died)
	add_child(player)


func _on_player_died():
	deaths += 1
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(player) and not won:
		player.respawn(spawn_point)


func _on_pickup_touched(kind, node):
	match kind:
		"coin":
			coins += 1
			node.queue_free()
		"checkpoint":
			spawn_point = node.position + Vector2(0, -20)
			node.activate()
		"goal":
			_win()


func _win():
	if won:
		return
	won = true
	player.frozen = true
	msg_label.text = "LEVEL COMPLETE!\nTime: %.1fs   Coins: %d/%d   Deaths: %d\n\nPress R to play again" % [time, coins, total_coins, deaths]


# ------------------------------------------------------------------ HUD

func _build_hud():
	var layer = CanvasLayer.new()
	add_child(layer)

	hud_label = Label.new()
	hud_label.position = Vector2(16, 10)
	hud_label.add_theme_font_size_override("font_size", 22)
	hud_label.add_theme_color_override("font_outline_color", Color.BLACK)
	hud_label.add_theme_constant_override("outline_size", 6)
	layer.add_child(hud_label)

	msg_label = Label.new()
	msg_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	msg_label.add_theme_font_size_override("font_size", 36)
	msg_label.add_theme_color_override("font_outline_color", Color.BLACK)
	msg_label.add_theme_constant_override("outline_size", 8)
	layer.add_child(msg_label)


func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		return
	if not won:
		time += delta
	if hud_label:
		hud_label.text = "Coins: %d/%d    Time: %.1f    Deaths: %d\nA/D or Arrows: move   Space: jump (stomp enemies!)   R: restart" % [coins, total_coins, time, deaths]
