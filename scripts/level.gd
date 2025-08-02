@tool
extends Node2D
class_name Level


@export var level_name: String
@export var room_prefabs: Array[PackedScene] = [] :
	get:
		return room_prefabs
	set(value):
		room_prefabs = value
@export var audio_tracks: Array[AudioStream]
@export_multiline var rooms_string: String 


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		rooms_string = _get_rooms_str()


func _get_rooms_str() -> String:
	var res = ""
	for room in room_prefabs:
		var str = "___"
		if room != null:
			str = room.resource_path.get_basename().get_file()
		res += str + "   >   "
	return str(res)


func _validate_property(property: Dictionary) -> void:
	if property.name == "rooms_string":
		property.usage |= PROPERTY_USAGE_READ_ONLY
