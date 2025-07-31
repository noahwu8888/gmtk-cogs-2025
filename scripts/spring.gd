extends Node2D
class_name Spring


@export var power: float = 300
@export var angle: float = -90

@export_group("Dependencies")
@export var spring_area: Area2D
@export var anim_player: AnimationPlayer


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	spring_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body is Player:
		var v = Vector2.from_angle(deg_to_rad(angle)) * power
		body.move_velocity = v
		anim_player.play("spring")
