extends CharacterBody2D

const SPEED = 300.0
@export var jump_force = 700.0
@export var jump_cut_multi := 0.5
@export var jump_gav_multi := 2.0
@onready var map := get_parent().find_child("Map")
@export var defaultCD := 5.0
var cooldown := 0.2
@onready var camera := $Camera2D
var score := 0.0

func _ready() -> void:
	$UI/CD.max_value = defaultCD

@export var bounceMulti := 1.2
var old_velocity: Vector2 = Vector2.ZERO
var last_viewport_pos := 0.0
func _physics_process(delta: float) -> void:
	if not get_parent().move: return
	if get_viewport_transform().origin.y < last_viewport_pos:
		get_parent().find_child("Death").show()
	last_viewport_pos = get_viewport_transform().origin.y - 5.0
	if Input.is_action_just_pressed("jump") and (is_on_floor() or $FloorCast.global_transform.origin.distance_to($FloorCast.get_collision_point()) < 40.0): velocity.y = -jump_force
	if Input.is_action_just_released("jump") and velocity.y < 0.0: velocity.y *= jump_cut_multi
	score = global_position.y * -1
	var direction := Input.get_axis("left", "right")
	if direction: velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * 10 * delta) if not is_on_wall() else -direction * SPEED
	else: velocity.x = move_toward(velocity.x, 0, SPEED)
	cooldown = max(cooldown - delta, 0)
	$UI/CD.value = cooldown
	global_position.x = clamp(global_position.x, 0.0, 1152.0)
	old_velocity = velocity
	move_and_slide()
	if not is_on_floor(): velocity += get_gravity() * delta
	elif (is_on_floor() or is_on_ceiling() or is_on_wall()) and not old_velocity.is_equal_approx(Vector2.ZERO): velocity.y += -old_velocity.y * bounceMulti ; velocity.x += -old_velocity.x * bounceMulti
	if is_on_wall(): velocity.x += -old_velocity.x ; print("BOING")
	elif (is_on_ceiling() or is_on_wall()) and not old_velocity.is_equal_approx(Vector2.ZERO): velocity.y += -old_velocity.y * bounceMulti ; velocity.x += -old_velocity.x * bounceMulti ; print(old_velocity.x)
	if velocity.y < 0.0 and !Input.is_action_just_pressed("jump"): velocity += get_gravity() * (jump_gav_multi - 1.0) * delta

func boost_jump(): velocity.y = -jump_force * 1.5
