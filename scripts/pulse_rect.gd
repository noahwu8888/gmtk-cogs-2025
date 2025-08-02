@tool
extends NinePatchRect
class_name PulseRect


@export var pulse_offset: float :
	get:
		return pulse_offset
	set(value):
		pulse_offset = value
		if is_inside_tree():
			size = original_size + (Vector2.ONE * 2 * pulse_offset * Utils.TILE_SIZE)
			position = -size / 2.0
			
var original_size: Vector2 :
	get:
		return original_size
	set(value):
		original_size = value
		pulse_offset = pulse_offset
