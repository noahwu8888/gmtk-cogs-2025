extends Node
class_name BeatNotifier


signal beat(beat: int)


@export var duration: float
@export var repeating: bool = true
@export var use_abs_position: bool = true
@export var start_beat: float


func _ready() -> void:
	RhythmNotifier.global.beats(duration, repeating, use_abs_position, start_beat).connect(beat.emit)
