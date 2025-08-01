@tool
extends AnimatableBody2D
class_name Platform


enum LoopMode {
	LOOP,
	PING_PONG
}

enum MoveMode {
	SPEED,
	BEAT
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
			if _debug_draw:
				_debug_draw.queue_redraw()
@export var waypoints: Array[Vector2] = [] :
	get:
		return waypoints
	set(value):
		if value == null:
			value = []
		waypoints = value
		_update_dest_indicator()
		if _debug_draw:
			_debug_draw.queue_redraw()
var _all_waypoints: Array[Vector2] :
	get:
		var res: Array[Vector2] = [Vector2.ZERO]
		res.append_array(waypoints)
		return res
@export var loop_mode: LoopMode :
	get:
		return loop_mode
	set(value):
		loop_mode = value
		if _debug_draw:
			_debug_draw.queue_redraw()
@export var move_mode: MoveMode :
	get:
		return move_mode
	set(value):
		move_mode = value
		notify_property_list_changed()
@export var speed: float = 100
## What beat to sync the platform to.
@export var beat: float = 0.0
## How the platform moves to a waypoint on a beat
@export var beat_move_curve: Curve
@export_group("Dependencies")
@export var patch_rect: NinePatchRect
@export var collision_shape: CollisionShape2D
@export var _debug_draw: Node2D

var waypoint_idx: int = 0
var waypoint_direction: int = 1

var _prev_waypoint: Vector2
var _next_waypoint: Vector2 :
	get:
		return _all_waypoints[waypoint_idx] * SUtils.TILE_SIZE + _initial_position
var _prev_to_next_dist: float
var _dest_indicator: NinePatchRect
var _prev_abs_beat: float
var _next_abs_beat: float
var _initial_position: Vector2


func _ready() -> void:
	if Engine.is_editor_hint():
		if patch_rect:
			set_process(false)
			_dest_indicator = patch_rect.duplicate()
			_dest_indicator.modulate.a = 0.25
			add_child(_dest_indicator)
			_update_dest_indicator()
		return
	_initial_position = position
	_debug_draw.reparent.call_deferred(get_parent())
	if move_mode == MoveMode.BEAT:
		_prev_abs_beat = RhythmNotifier.global.get_interval_start_beat(beat)
		_next_abs_beat = RhythmNotifier.global.get_interval_end_beat(beat)
	_advance_waypoint()


func _advance_waypoint():
	_prev_waypoint = _next_waypoint
	waypoint_idx += waypoint_direction
	if loop_mode == LoopMode.LOOP:
		if waypoint_idx >= len(_all_waypoints):
			waypoint_idx = 0
	elif loop_mode == LoopMode.PING_PONG:
		if waypoint_idx < 0 or waypoint_idx >= len(_all_waypoints):
			waypoint_direction *= -1
	_prev_to_next_dist = _prev_waypoint.distance_to(_next_waypoint)
	_prev_abs_beat = _next_abs_beat
	_next_abs_beat += beat
	print("    advance waypoint: _prev_abs_beat: %s _next_abs_beat: %s" % [_prev_abs_beat, _next_abs_beat])

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if move_mode == MoveMode.SPEED:
		var move_delta = speed * delta * SUtils.TILE_SIZE
		while true:
			var next_waypoint = _next_waypoint
			var dist_left = position.distance_to(_next_waypoint)
			position = position.move_toward(_next_waypoint, move_delta)
			if move_delta >= dist_left:
				# Reached the next waypoint
				position = _next_waypoint
				_advance_waypoint()
				# Update the move_delta with our remainder
				move_delta = move_delta - dist_left
			else:
				break
	elif move_mode == MoveMode.BEAT:
		var time_weight = (RhythmNotifier.global.current_abs_beat_position - _prev_abs_beat) / beat
		while true:
			var weight = beat_move_curve.sample(time_weight)
			position = _prev_waypoint.lerp(_next_waypoint, weight)
			if time_weight >= 1:
				print("_next_waypoint: time_weight: %s, _next_waypoint: %s, _prev_abs_beat: %s, _next_abs_beat: %s" % [time_weight, _next_waypoint, _prev_abs_beat, _next_abs_beat])
				print(" 	current_abs_beat_position: %s _prev_abs_beat: %s beat: %s" % [RhythmNotifier.global.current_abs_beat_position, _prev_abs_beat, beat])
				_advance_waypoint()
				time_weight -= 1.0
			else:
				break


func _update_dest_indicator():
	if Engine.is_editor_hint() and is_inside_tree():
		if len(_all_waypoints) > 0 and _dest_indicator:
			_dest_indicator.position = _all_waypoints[-1] * SUtils.TILE_SIZE

func _validate_property(property: Dictionary):
	if (property.name in ["beat", "beat_move_curve"] and move_mode != MoveMode.BEAT) or \
		(property.name == "speed" and move_mode != MoveMode.SPEED):
		property.usage = PROPERTY_USAGE_NO_EDITOR
