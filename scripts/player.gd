extends CharacterBody2D
class_name Player


@export var sprite: Sprite2D
@export var speed: float = 100
@export var jump_power: float = 100
@export var gravity: float = 300
@export var terminal_velocity: float = 150
@export var down_gravity_scale: float = 1.5
@export var coyote_time: float = 0.1
@export var jumps: int = 1

var jumps_left: int = 0
var time_since_floor: float 
var move_velocity: Vector2

func _physics_process(delta: float) -> void:
	# Horizontal movement
	var horz_dir = Input.get_axis("p1_left", "p1_right")
	move_velocity.x = horz_dir * speed
	
	# Jump
	var can_jump = time_since_floor < coyote_time or (jumps_left > 0 and not is_on_floor())
	if can_jump and Input.is_action_just_pressed("p1_jump"):
		move_velocity.y = -jump_power
		jumps_left -= 1
	
	# Visual sprite flip
	if move_velocity.x > 0:
		sprite.flip_h = false
	elif move_velocity.x < 0:
		sprite.flip_h = true
	
	# Gravity
	var gravity_delta = gravity * delta
	if move_velocity.y > 0:
		# If we are falling:
		gravity_delta *= down_gravity_scale
	move_velocity.y += gravity_delta
	if move_velocity.y > 0:
		# If we are falling
		move_velocity.y = clampf(move_velocity.y, 0, terminal_velocity)
	
	# Limit movement when hitting wall or floor
	if is_on_ceiling() and move_velocity.y < 0:
		move_velocity.y = 0
	if is_on_floor() and move_velocity.y > 0:
		move_velocity.y = 0
		time_since_floor = 0.0
		jumps_left = jumps
	time_since_floor += delta
	velocity = move_velocity
	
	move_and_slide()
