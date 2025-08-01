extends Node
class_name AudioPartManager


@export var active_parts : Dictionary[AudioStream, bool]
var audio_parts: Array[AudioPart]


func _ready() -> void:
	audio_parts = []
	for child in get_children():
		if child is AudioPart:
			audio_parts.append(child)


func set_active_parts(new_active_parts: Array[AudioStream]) -> void:
	active_parts.clear()
	for part in new_active_parts:
		active_parts[part] = true
	
	for audio_part in audio_parts:
		if audio_part.stream in active_parts and not audio_part.playing:
			audio_part.play()
		else:
			if audio_part.playing:
				audio_part.stop()
