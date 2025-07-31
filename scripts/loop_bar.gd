extends Node2D

@export var start_pos: Vector2
@export var end_pos: Vector2
@export var bpm: float
@export var beats: int
var time: float = 0

signal song_ended

func _process(delta: float) -> void:
	var song_length = beats / bpm * 60
	time += delta
	if time >= song_length:
		time -= song_length
		song_ended.emit()
	position = lerp(start_pos, end_pos, time / song_length)
