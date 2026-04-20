extends CharacterBody2D

const SPEED = 300.0
@export var jump_force = 400.0
@onready var map := get_parent().find_child("Map")
@export var defaultCD := 5.0
var cooldown := 0.2
@onready var camera := $Camera2D
var score := 0.0

func _ready() -> void:
	$UI/CD.max_value = defaultCD

var last_viewport_pos := 0.0
func _physics_process(delta: float) -> void:
	if not get_parent().move: return
	if not is_on_floor(): velocity += get_gravity() * delta
	if get_viewport_transform().origin.y < last_viewport_pos:
		get_parent().find_child("Death").show()
	last_viewport_pos = get_viewport_transform().origin.y - 5.0
	if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y = -jump_force
	score = global_position.y * -1
	var direction := Input.get_axis("left", "right")
	if direction: velocity.x = direction * SPEED
	else: velocity.x = move_toward(velocity.x, 0, SPEED)
	cooldown = max(cooldown - delta, 0)
	$UI/CD.value = cooldown
	global_position.x = clamp(global_position.x, 0.0, 1152.0)
	move_and_slide()

func boost_jump(): velocity.y = -jump_force * 1.5
