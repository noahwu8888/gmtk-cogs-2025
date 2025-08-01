extends CharacterBody2D
class_name Player


signal death


@export var speed: float = 100
@export var jump_power: float = 100
@export var gravity: float = 300
@export var terminal_velocity: float = 150
@export var down_gravity_scale: float = 1.5
@export var coyote_time: float = 0.1
@export var jumps: int = 1
@export var enabled: bool = true :
	get:
		return enabled
	set(value):
		enabled = value
		if is_inside_tree():
			await get_tree().process_frame
			collision_shape.disabled = not enabled

@export_group("Dependencies")
@export var visuals_anim_tree: AnimationTree
@export var sprite: Sprite2D
@export var collision_shape: CollisionShape2D

var jumps_left: int = 0
var time_since_floor: float 
var move_velocity: Vector2

var just_jumped: bool
var just_landed: bool
var prev_on_floor: bool 


func _ready() -> void:
	enabled = enabled
	reset()


func _physics_process(delta: float) -> void:
	if enabled:
		update_movement(delta)
		update_anim()


func update_movement(delta):
	# Horizontal movement
	var horz_dir = Input.get_axis("p1_left", "p1_right")
	move_velocity.x = horz_dir * speed * SUtils.TILE_SIZE
	
	# Jump
	var can_jump = time_since_floor < coyote_time or (jumps_left > 0 and not is_on_floor())
	just_jumped = false
	if can_jump and Input.is_action_just_pressed("p1_jump"):
		move_velocity.y = -jump_power * SUtils.TILE_SIZE
		jumps_left -= 1
		just_jumped = true
	
	# Landing
	just_landed = false
	if not prev_on_floor and is_on_floor():
		just_landed = true
	prev_on_floor = is_on_floor()
	
	# Visual sprite flip
	if move_velocity.x > 0:
		sprite.flip_h = false
	elif move_velocity.x < 0:
		sprite.flip_h = true
	
	# Gravity
	var gravity_delta = gravity * delta * SUtils.TILE_SIZE
	if move_velocity.y > 0:
		# If we are falling:
		gravity_delta *= down_gravity_scale
	move_velocity.y += gravity_delta
	if move_velocity.y > 0:
		# If we are falling
		move_velocity.y = clampf(move_velocity.y, 0, terminal_velocity * SUtils.TILE_SIZE)
	
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


func update_anim():
	var direction_playback: AnimationNodeStateMachinePlayback = visuals_anim_tree.get("parameters/direction/playback")
	var visuals_playback: AnimationNodeStateMachinePlayback = visuals_anim_tree.get("parameters/visuals/playback")
	if just_jumped:
		visuals_playback.start("jump")
	if just_landed:
		visuals_playback.start("landing")
	visuals_anim_tree.set("parameters/conditions/idle", is_on_floor())
	visuals_anim_tree.set("parameters/conditions/falling", velocity.y > 0)


func reset():
	velocity = Vector2.ZERO
	move_velocity = Vector2.ZERO


func kill():
	death.emit()
	reset()
