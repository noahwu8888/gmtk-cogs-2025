extends RefCounted
class_name Utils


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


## Waits a specific duration. Requires a global World node in the scene. 
static func wait(duration: float) -> Signal:
	return World.global.get_tree().create_timer(duration).timeout
