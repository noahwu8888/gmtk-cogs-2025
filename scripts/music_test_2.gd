extends Node2D


@export var active_tracks: Array[AudioStream]
@export var metronome: AudioStreamPlayer
@export var bpm: float = 136
@export var beats: float = 4 :
	get:
		return beats
	set(value):
		if is_inside_tree():
			RhythmNotifier.global.beats(beats).disconnect(_on_beat)
		beats = value
		if is_inside_tree():
			RhythmNotifier.global.beats(beats).connect(_on_beat)
var _start_time: int = 0


func _ready() -> void:
	beats = beats
	BGTrackManager.global.update_tracks(active_tracks)
	BGTrackManager.global.set_active_tracks(active_tracks)
	RhythmNotifier.global.bpm = bpm
	_start_time = Time.get_ticks_msec()
	


func _on_beat(beat: int):
	var r = RhythmNotifier.global
	var calc_time_elapsed = r.current_abs_position
	print("beat: %s beat_position: %s abs_beat_position: %s calc_time_elapsed: %s actual_time_elapsed: %s" % [r.beat, r.current_beat_position, r.current_abs_beat_position, calc_time_elapsed, (Time.get_ticks_msec() - _start_time) / 1000.0])
	metronome.play()
