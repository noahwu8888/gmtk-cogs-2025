extends Node2D


enum Mode {
	MANUAL,
	NOTIFIER,
	OG,
}


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
@export var og_rhythm_notifier: OGRhythmNotifier
@export var test_mode: Mode = Mode.MANUAL
var _start_time: int = 0

var _time: float = 0
var _beat_length: float


func _ready() -> void:
	beats = beats
	_beat_length = 60 / bpm
	if test_mode == Mode.OG:
		og_rhythm_notifier.audio_stream_player.stream = active_tracks[0]
		og_rhythm_notifier.audio_stream_player.play()
		og_rhythm_notifier.bpm = bpm
		og_rhythm_notifier.beats(1.0).connect(_on_beat)
	elif test_mode == Mode.NOTIFIER:
		BGTrackManager.global.update_tracks(active_tracks)
		BGTrackManager.global.set_active_tracks(active_tracks)
		RhythmNotifier.global.bpm = bpm
		RhythmNotifier.global.beats(1.0).connect(_on_beat)
	_start_time = Time.get_ticks_msec()


func _process(delta: float) -> void:
	if test_mode == Mode.MANUAL:
		_time += delta
		while _time >= _beat_length:
			_on_beat(0)
			_time -= _beat_length


func _on_beat(beat: int):
	if test_mode == Mode.NOTIFIER:
		var r = RhythmNotifier.global
		var calc_time_elapsed = r.current_abs_position
		print("beat: %s beat_position: %s abs_beat_position: %s calc_time_elapsed: %s actual_time_elapsed: %s" % [r.beat, r.current_beat_position, r.current_abs_beat_position, calc_time_elapsed, (Time.get_ticks_msec() - _start_time) / 1000.0])
	metronome.play()
