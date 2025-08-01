## Script for static utility functions
extends RefCounted
class_name SUtils


static var DEBUG: bool = false
const TILE_SIZE: float = 256


static func draw_arrow(node: CanvasItem, source: Vector2, dest: Vector2, color: Color = Color.WHITE, width: float = -1, arrow_length: float = 64, arrow_angle: float = 30, double_sided: bool = false):
	node.draw_line(source, dest, color, width)
	var to_source = (source - dest).normalized()
	node.draw_line(dest, dest + to_source.rotated(deg_to_rad(arrow_angle)) * arrow_length, color, width)
	node.draw_line(dest, dest + to_source.rotated(-deg_to_rad(arrow_angle)) * arrow_length, color, width)
	if double_sided:
		var to_dest = (dest - source).normalized()
		node.draw_line(source, source + to_dest.rotated(deg_to_rad(arrow_angle)) * arrow_length, color, width)
		node.draw_line(source, source + to_dest.rotated(-deg_to_rad(arrow_angle)) * arrow_length, color, width)	
