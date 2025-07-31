extends Node
class_name BGMusicManager

@export var bpm : int = 136
var emitters : Array[BGMusicEmitter]

@export var active_tracks : Dictionary[AudioStream, bool]

func _ready() -> void:
	emitters = []
	for child in get_children():
		if child is BGMusicEmitter:
			emitters.append(child)

func update_emitters_for_room(new_active_tracks: Array[AudioStream]) -> void:
	active_tracks.clear()
	for track in new_active_tracks:
		active_tracks[track] = true
	
	for emitter in emitters:
		if emitter.stream in active_tracks and not emitter.playing:
			emitter.play()
		else:
			if emitter.playing:
				emitter.fade_out()
