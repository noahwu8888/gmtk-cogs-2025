extends CharacterBody2D
class_name Player


@export var sprite: Sprite2D
@export var speed: float = 100
@export var jump_speed: float = 100
@export var gravity: float = 98
@export var terminal_velocity: float = 100

func _physics_process(delta: float) -> void:
	var horz_dir = Input.get_axis("p1_left", "p1_right")
	velocity.x = horz_dir * speed
	if Input.is_action_just_pressed("p1_jump"):
		velocity.y = -jump_speed
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, -terminal_velocity, terminal_velocity)
	move_and_slide() 
