extends Node
class_name BGMusicManager

@export var bpm : int = 136
var emitters : Array[BGMusicEmitter]

var _current_room: int = 1
@export var current_room: int:
	get: return _current_room
	set(value):
		_current_room = value
		_update_emitters_for_room(value)

func _ready() -> void:
	emitters = []
	for child in get_children():
		if child is BGMusicEmitter:
			emitters.append(child)
	_update_emitters_for_room(_current_room)

func _update_emitters_for_room(room: int) -> void:
	for emitter in emitters:
		var is_in_range = emitter.start_room_number <= room and room <= emitter.end_room_number
		if is_in_range:
			emitter.play()
		else:
			if emitter.playing:
				emitter.fade_out()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P:
			current_room += 1
			print("Current Room:", current_room)
