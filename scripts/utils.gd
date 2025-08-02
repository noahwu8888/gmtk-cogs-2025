extends Node
class_name Utils


static var global: Node

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


## Returns the type of an object as a String.
## This works with custom class_names.
static func get_type_as_string(object: Object) -> String:
	if object == null:
		return ""
	
	var script: Script = object.get_script()
	if script == null:
		return object.get_class()
	
	var type_as_string: String = script.get_global_name()
	if type_as_string == "":
		type_as_string = script.get_instance_base_type()
	
	return type_as_string


## Fetches a descendant node by a type.
static func get_node_by_type(root: Node, type: String) -> Node:
	for child in root.get_children(true):
		if get_type_as_string(child) == type:
			return child
		var res = get_node_by_type(child, type)
		if res != null:
			return res
	return null


## Fetches a descendant node by a group.
static func get_node_by_group(root: Node, group: String) -> Node:
	for child in root.get_children(true):
		if child.is_in_group(group):
			return child
		var res = get_node_by_group(child, group)
		if res != null:
			return res
	return null


## Waits a specific duration. Requires a global World node in the scene. 
static func wait(duration: float) -> Signal:
	return global.get_tree().create_timer(duration).timeout


func _enter_tree() -> void:
	if global != null:
		queue_free()
		return
	global = self


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and global == self:
		global = null
