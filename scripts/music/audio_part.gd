extends Node
class_name AudioPart


@export var beat_count: float = 1.0
@export var bpm: float = 1.0
@export var fade_in_time: float = 1.0
@export var fade_out_time: float = 1.0
@export var cross_fade_time: float = 0.5
@export_range(-80, 80) var volume_db: float = 0.0
@export var stream: AudioStream

var fader: AudioFader
var playing: bool :
	get:
		return fader.playing


func _ready() -> void:
	fader = AudioFader.new()
	fader.loop = true
	fader.stream = stream
	fader.fade_in_time = fade_in_time
	fader.fade_out_time = fade_in_time
	fader.duration = beat_count / bpm * 60
	fader.volume_db = volume_db
	add_child(fader)


func play(fade_in: bool = true):
	fader.play(fade_in)


func stop():
	fader.fade_out()
