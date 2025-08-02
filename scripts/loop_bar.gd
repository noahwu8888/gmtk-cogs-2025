extends Node2D
class_name LoopBar

@export var start_x: float
@export var end_x: float
@export var beat_count: int = 32

func _process(delta: float) -> void:
	print("%s / %s" % [RhythmNotifier.global.current_beat_position, beat_count])
	position.x = lerp(start_x, end_x, clampf(RhythmNotifier.global.current_beat_position / beat_count, 0, 1))
