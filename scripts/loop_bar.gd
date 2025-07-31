extends Node2D
class_name LoopBar

@export var start_pos: Vector2
@export var end_pos: Vector2
@export var bpm: float
@export var beats: int
var time: float = 0

@onready var marker_2d: Marker2D = $Marker2D

signal loop_ended

func _ready() -> void:
	end_pos = marker_2d.position

func _process(delta: float) -> void:
	var song_length = beats / bpm * 60
	time += delta
	if time >= song_length:
		time -= song_length
		loop_ended.emit()
	position.x = lerp(start_pos.x, end_pos.x, time / song_length)
