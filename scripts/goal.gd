extends Node2D
class_name Goal

signal player_entered()

@export var area: Area2D


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D):
	if body is Player:
		player_entered.emit()


func play_ending(duration: float):
	pass
	# TODO: Add visuals that scale based on duration
	pass
