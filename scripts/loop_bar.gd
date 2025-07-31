extends Node2D
class_name LoopBar

@export var start_x: float
@export var end_x: float
@export var beat_count: int = 32
@export var rhythm_notifier: RhythmNotifier

func _process(delta: float) -> void:
	position.x = lerp(start_x, end_x, clampf(rhythm_notifier.current_beat_position / beat_count, 0, 1))
