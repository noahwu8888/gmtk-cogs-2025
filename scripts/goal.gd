extends Node2D
class_name Goal

signal player_entered()

@export var pulse_beat: float

@export_category("Dependencies")
@export var _area: Area2D
@export var _ending_fx: FXBeat
@export var _pulse_fx: FX


func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)
	if pulse_beat > 0:
		RhythmNotifier.global.beats(pulse_beat).connect(_pulse_fx.play.unbind(1))


func _on_body_entered(body: Node2D):
	if body is Player:
		player_entered.emit()


func play_ending(end_beat: float):
	_ending_fx.play_ending_on_beat(end_beat)
