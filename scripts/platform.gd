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


@export var size: Vector2:
	get:
		return size
	set(value):
		size = value
		if is_inside_tree() and _patch_rect and _collision_shape:
			if size.x < 1:
				size.x = 1
			if size.y < 1:
				size.y = 1
			var true_size = size * Utils.TILE_SIZE
			_patch_rect.size = true_size
			_patch_rect.position = (-size / 2.0) * Utils.TILE_SIZE
			if _dest_indicator:
				_dest_indicator.size = _patch_rect.size
			var shape = _collision_shape.shape as RectangleShape2D
			shape.size = true_size
			if _debug_draw:
				_debug_draw.queue_redraw()
			_update_dest_indicator()
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
## Beat interval at which this platform visually pulses
@export var pulse_beat: float = 4.0
@export_group("Dependencies")
@export var _patch_rect: NinePatchRect
@export var _collision_shape: CollisionShape2D
@export var _debug_draw: Node2D
@export var _visuals: Node2D
@export var _pulse_fx: FX

var waypoint_idx: int = 0
var waypoint_direction: int = 1

var _prev_waypoint: Vector2
var _next_waypoint: Vector2 :
	get:
		return _all_waypoints[waypoint_idx] * Utils.TILE_SIZE + _initial_position
var _prev_to_next_dist: float
var _dest_indicator: NinePatchRect
var _prev_abs_beat: float
var _next_abs_beat: float
var _initial_position: Vector2


func _ready() -> void:
	if Engine.is_editor_hint():
		if _patch_rect:
			set_process(false)
			_dest_indicator = get_node_or_null("_dest_indicator")
			if _dest_indicator == null:
				_dest_indicator = _patch_rect.duplicate()
				_dest_indicator.modulate.a = 0.25
				_dest_indicator.name = "_dest_indicator"
				add_child(_dest_indicator)
			_update_dest_indicator()
		return
	_initial_position = position
	_debug_draw.reparent.call_deferred(get_parent())
	if move_mode == MoveMode.BEAT:
		_prev_abs_beat = RhythmNotifier.global.get_interval_start_beat(beat)
		_next_abs_beat = RhythmNotifier.global.get_interval_end_beat(beat)
	if pulse_beat > 0:
		RhythmNotifier.global.beats(pulse_beat).connect(_pulse_fx.play.unbind(1))
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
			waypoint_idx += waypoint_direction
	_prev_to_next_dist = _prev_waypoint.distance_to(_next_waypoint)
	_prev_abs_beat = _next_abs_beat
	_next_abs_beat += beat

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if move_mode == MoveMode.SPEED:
		var move_delta = speed * delta * Utils.TILE_SIZE
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
				_advance_waypoint()
				time_weight -= 1.0
			else:
				break


func _update_dest_indicator():
	if Engine.is_editor_hint() and is_inside_tree():
		if len(_all_waypoints) > 0 and _dest_indicator:
			_dest_indicator.position = (_all_waypoints[-1] - size / 2.0) * Utils.TILE_SIZE

func _validate_property(property: Dictionary):
	if (property.name in ["beat", "beat_move_curve"] and move_mode != MoveMode.BEAT) or \
		(property.name == "speed" and move_mode != MoveMode.SPEED):
		property.usage = PROPERTY_USAGE_NO_EDITOR
