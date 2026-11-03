extends CharacterBody2D

signal died

const SPEED = 240.0
const ACCEL = 1800.0
const FRICTION = 2200.0
const JUMP_VELOCITY = -520.0
const GRAVITY = 1500.0
const MAX_FALL = 900.0
const COYOTE_TIME = 0.1   # can still jump just after leaving a ledge
const JUMP_BUFFER = 0.1   # jump press is remembered just before landing

var dead = false
var frozen = false
var coyote = 0.0
var buffer = 0.0
var eyes: ColorRect
var cam: Camera2D


func _ready():
	add_to_group("player")

	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(24, 40)
	cs.shape = shape
	add_child(cs)

	var body = ColorRect.new()
	body.position = Vector2(-12, -20)
	body.size = Vector2(24, 40)
	body.color = Color(0.20, 0.35, 0.90)
	add_child(body)

	eyes = ColorRect.new()
	eyes.position = Vector2(2, -12)
	eyes.size = Vector2(8, 8)
	eyes.color = Color.WHITE
	add_child(eyes)

	cam = Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	cam.limit_left = 0
	cam.limit_right = 3000
	cam.limit_top = 0
	cam.limit_bottom = 648
	add_child(cam)


func _physics_process(delta):
	if dead or frozen:
		return

	var dir = Input.get_axis("left", "right")
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * SPEED, ACCEL * delta)
		eyes.position.x = 2 if dir > 0 else -10
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	if not is_on_floor():
		velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL)
		coyote -= delta
	else:
		coyote = COYOTE_TIME

	if Input.is_action_just_pressed("jump"):
		buffer = JUMP_BUFFER
	else:
		buffer -= delta

	if buffer > 0.0 and coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		buffer = 0.0
		coyote = 0.0

	# Release jump early for a shorter hop
	if Input.is_action_just_released("jump") and velocity.y < -150.0:
		velocity.y *= 0.5

	move_and_slide()

	if position.y > 900:
		die()


func die():
	if dead:
		return
	dead = true
	visible = false
	velocity = Vector2.ZERO
	died.emit()


func respawn(pos: Vector2):
	position = pos
	velocity = Vector2.ZERO
	dead = false
	visible = true
	cam.reset_smoothing()


func bounce():
	velocity.y = -380.0
	coyote = 0.0
