@tool
extends AnimatableBody2D
class_name Platform


enum Mode {
	LOOP,
	PING_PONG
}


@export var rect: Rect2:
	get:
		return rect
	set(value):
		rect = value
		if is_inside_tree() and patch_rect and collision_shape:
			if rect.size.x < 1:
				rect.size.x = 1
			if rect.size.y < 1:
				rect.size.y = 1
			var size = rect.size * SUtils.TILE_SIZE
			patch_rect.size = size
			patch_rect.position = rect.position * SUtils.TILE_SIZE
			if _dest_indicator:
				_dest_indicator.size = patch_rect.size
			var shape = collision_shape.shape as RectangleShape2D
			shape.size = size
			collision_shape.position = rect.get_center() * SUtils.TILE_SIZE
			queue_redraw()
@export var waypoints: Array[Vector2] = [] :
	get:
		return waypoints
	set(value):
		if value == null:
			value = []
		waypoints = value
		_update_dest_indicator()
		queue_redraw()
var _all_waypoints: Array[Vector2] :
	get:
		var res: Array[Vector2] = [Vector2.ZERO]
		res.append_array(waypoints)
		return res
@export var mode: Mode :
	get:
		return mode
	set(value):
		mode = value
		queue_redraw()
@export var speed: float = 100
@export_group("Dependencies")
@export var patch_rect: NinePatchRect
@export var collision_shape: CollisionShape2D


var _dest_indicator: NinePatchRect


func _ready() -> void:
	if Engine.is_editor_hint() and patch_rect:
		_dest_indicator = patch_rect.duplicate()
		_dest_indicator.modulate.a = 0.25
		add_child(_dest_indicator)
		_update_dest_indicator()


func _update_dest_indicator():
	if Engine.is_editor_hint() and is_inside_tree():
		if len(_all_waypoints) > 0 and _dest_indicator:
			_dest_indicator.position = _all_waypoints[-1] * SUtils.TILE_SIZE


func _draw() -> void:
	var color = Color.CYAN
	var width = -1
	var arrow_length = 64
	var arrow_angle = 30
	var double_sided = mode == Mode.PING_PONG
	var offset = rect.get_center()
	for i in range(len(_all_waypoints) - 1):
		SUtils.draw_arrow(self, (offset + _all_waypoints[i]) * SUtils.TILE_SIZE, (offset + _all_waypoints[i + 1]) * SUtils.TILE_SIZE, color, width, arrow_length, arrow_angle, double_sided)
	if mode == Mode.LOOP:
		SUtils.draw_arrow(self, (offset + _all_waypoints[-1]) * SUtils.TILE_SIZE, (offset + _all_waypoints[0]) * SUtils.TILE_SIZE, color, width, arrow_length, arrow_angle)
