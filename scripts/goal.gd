extends Node2D
class_name Goal

signal player_entered()

@export var area: Area2D
@export var anim_player: AnimationPlayer
@export var ending_fx: FXBeat


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D):
	if body is Player:
		player_entered.emit()


func play_ending(end_beat: float):
	ending_fx.play_ending_on_beat(end_beat)
