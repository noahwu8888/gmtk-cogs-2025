@tool
extends EditorPlugin


var properties: Array[Dictionary] = []
var target_object: CanvasItem
var waypoints: Array[Dictionary]
var dragged_waypoint: Dictionary
var dragged_waypoint_start: Dictionary

const COLORS = [Color.GREEN, Color.DODGER_BLUE, Color.BLUE, Color.PURPLE, Color.HOT_PINK, Color.RED, Color.ORANGE, Color.YELLOW]


func _on_property_edited(property: String):
	if target_object.get(property) is Array[Vector2]:
		_edit(target_object)
		update_overlays()


func _enter_tree() -> void:
	EditorInterface.get_inspector().property_edited.connect(_on_property_edited)


func _exit_tree() -> void:
	EditorInterface.get_inspector().property_edited.disconnect(_on_property_edited)


func _edit(object: Object) -> void:
	properties.clear()
	waypoints.clear()
	target_object = object
	if not object:
		return
	var color_idx = 0
	for property in object.get_property_list():
		if not property.name.begins_with("_") and "waypoints" in property.name and object.get(property.name) is Array[Vector2]:
			color_idx = (color_idx + 1) % len(COLORS)
			properties.append(property)
			var array = object.get(property.name) as Array[Vector2]
			for i in range(len(array)):
				var waypoint = {
					"property": property.name,
					"index": i,
					"draw_position": Vector2.ZERO,
					"position": array[i],
					"offset": Vector2.ZERO,
					"scale": 0.0,
					"radius": 8.0,
					"snap": Vector2.ZERO,
					"color": COLORS[color_idx]
				}
				if target_object is Platform:
					waypoint["scale"] = SUtils.TILE_SIZE
					waypoint["offset"] = target_object.rect.get_center() * SUtils.TILE_SIZE
					waypoint["snap"] = Vector2.ONE * 128
				waypoints.append(waypoint)


func _forward_canvas_draw_over_viewport(overlay: Control) -> void:
	if not target_object or not target_object.is_inside_tree():
		return
	for waypoint in waypoints: 
		var array = target_object.get(waypoint.property) as Array[Vector2]
		waypoint.position = array[waypoint.index]
		waypoint.draw_position = target_object.get_viewport_transform() * target_object.get_global_transform_with_canvas() * (waypoint.position * waypoint.scale + waypoint.offset)
		overlay.draw_circle(waypoint.draw_position, waypoint.radius, waypoint.color)
	#for property in properties:
		#var point_array: Array[Vector2] = target_object.get(property.name)
		#for i in range(len(point_array)):
			#var point = point_array[i]
			#var draw_pos = Vector2.ZERO
			#if target_object is Platform:
				#draw_pos = (point * SUtils.TILE_SIZE)
				#draw_pos += target_object.rect.get_center() * SUtils.TILE_SIZE
			#draw_pos = target_object.get_viewport_transform() * target_object.get_canvas_transform() * draw_pos
			#overlay.draw_circle(draw_pos, CIRCLE_RADIUS, COLOR)


func drag_to(event_position: Vector2) -> void:
	if not dragged_waypoint:
		return
	
	var viewport_transform_inverted = target_object.get_viewport().global_canvas_transform.affine_inverse()
	var viewport_position = viewport_transform_inverted * event_position
	var global_transform_inverted = target_object.get_global_transform_with_canvas().affine_inverse()
	var target_position = global_transform_inverted * viewport_position
	if dragged_waypoint.snap != Vector2.ZERO:
		target_position = target_position.snapped(dragged_waypoint.snap) 
	
	dragged_waypoint.position = (target_position - dragged_waypoint.offset) / dragged_waypoint.scale
	dragged_waypoint.draw_position = target_object.get_viewport_transform() * target_object.get_global_transform_with_canvas() * (dragged_waypoint.position * dragged_waypoint.scale + dragged_waypoint.offset)
	_move_waypoint(target_object, dragged_waypoint)


func _move_waypoint(object: CanvasItem, waypoint: Dictionary, update_overlays: bool = false):
	if not object:
		return
	var array = object.get(waypoint.property)
	array[waypoint.index] = waypoint.position
	object.set(waypoint.property, array)
	if update_overlays:
		object.notify_property_list_changed()
		update_overlays()


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if not target_object:
		return false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not dragged_waypoint and event.is_pressed():
			# Start drag
			for waypoint in waypoints:
				if waypoint.draw_position.distance_to(event.position) < waypoint.radius:
					dragged_waypoint = waypoint
					dragged_waypoint_start = dragged_waypoint.duplicate()
					return true
		elif dragged_waypoint and not event.is_pressed():
			# Stop drag
			var undo = get_undo_redo()
			undo.create_action("Move %s[%s] -> %s" % [dragged_waypoint.property, dragged_waypoint.index, dragged_waypoint.position])
			undo.add_undo_method(self, "_move_waypoint", target_object, dragged_waypoint_start.duplicate(), true)
			undo.add_do_method(self, "_move_waypoint", target_object, dragged_waypoint.duplicate(), true)
			undo.commit_action()
			var v = Vector2()
			drag_to(event.position)
			dragged_waypoint = {}
			dragged_waypoint_start = {}
	if dragged_waypoint:
		if event is InputEventMouseMotion:
			drag_to(event.position)
			update_overlays()
			return true
		if event.is_action_pressed("ui_cancel"):
			dragged_waypoint = {}
			dragged_waypoint_start = {}
			drag_to(dragged_waypoint_start.draw_position)
			return true
	return false


func _handles(object: Object) -> bool:
	if object is not CanvasItem:
		return false
	for property in object.get_property_list():
		if "waypoints" in property.name and object.get(property.name) is Array[Vector2]:
			return true
	return true
