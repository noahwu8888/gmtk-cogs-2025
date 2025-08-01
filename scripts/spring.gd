extends Node2D
class_name Spring


@export var power: float = 300
@export var angle: float = -90
@export var pulse_beats: float = 2.0

@export_group("Dependencies")
@export var _spring_area: Area2D
@export var _spring_fx: FX
@export var _pulse_fx: FX


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_spring_area.body_entered.connect(_on_body_entered)
	if pulse_beats > 0:
		RhythmNotifier.global.beats(pulse_beats).connect(_pulse_fx.play.unbind(1))

func _on_body_entered(body: Node2D):
	if body is Player:
		var v = Vector2.from_angle(deg_to_rad(angle)) * power * SUtils.TILE_SIZE
		body.move_velocity = v
		_spring_fx.play()
