extends Node


#func _ready() -> void:
	#RhythmNotifier.global.beats(1.0).connect(_on_beat)

#func _on_beat(beat: int):
	#var r = RhythmNotifier.global
	#print("beat: %s abs_beat_pos: %s beat_pos: %s" % [beat, r.current_abs_beat_position, r.current_beat_position])
