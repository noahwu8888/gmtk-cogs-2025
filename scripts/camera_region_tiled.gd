@tool
extends CameraRegion2D
class_name CameraRegionTiled


@export var tiled_size: Vector2 :
	get:
		return size / Utils.TILE_SIZE
	set(value):
		size = value * Utils.TILE_SIZE


func _ready() -> void:
	notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if property.name == "size":
		property.usage = PROPERTY_USAGE_NO_EDITOR
