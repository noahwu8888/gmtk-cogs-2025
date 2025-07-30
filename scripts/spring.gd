@tool
extends Node2D
class_name Spring


@export var power: float = 300
@export var angle: float = -90

@export_group("Dependencies")
@export var head_sprite: Sprite2D
@export var tube_sprite: Sprite2D
@export var base_sprite: Sprite2D
@export var tube_base: Node2D
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

func _process(delta: float) -> void:
	_delayed.call_deferred()

func _delayed():
	if head_sprite != null and tube_sprite != null and base_sprite != null and tube_base != null:
		if head_sprite.position.x != 0:
			head_sprite.position.x = 0
		var vert_dist = tube_base.position.y - head_sprite.position.y
		tube_sprite.scale.y = vert_dist / tube_sprite.get_rect().size.y
		tube_sprite.position = tube_base.position
