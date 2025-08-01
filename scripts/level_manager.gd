extends Node
class_name LevelManager

signal level_completed

@export var level: Level
@export var min_transition_duration: float

@export_group("Dependencies")
@export var camera_region_controller: CameraRegionController2D
@export var loop_bar: LoopBar
@export var player: Player
@export var world: World
@export var rhythm_notifier: RhythmNotifier
@export var bg_track_manager: AudioTrackManager

var active_room: Room
var active_room_index: int
var is_transitioning: bool
var trans_beats_left: int


func _ready() -> void:
	load_level.call_deferred(level)


func _process(delta: float) -> void:
	if player.global_position.y > SUtils.TILE_SIZE * 40:
		player.global_position = active_room.spawn.global_position
		


func load_level(new_level: Level):
	level = new_level
	active_room_index = -1
	load_room_next_room()


func load_room_next_room():
	if active_room != null:
		active_room.region.queue_free()
		active_room.queue_free()
	active_room_index += 1
	if active_room_index >= len(level.room_prefabs):
		level_completed.emit()
		return
	player.visible = false
	player.enabled = false
	player.global_position = Vector2(-1000, -1000)
	await get_tree().process_frame
	var new_room = level.room_prefabs[active_room_index].instantiate() as Room
	world.add_child(new_room)
	new_room.region.reparent(camera_region_controller)
	new_room.finished.connect(_on_room_finished)
	rhythm_notifier.bpm = new_room.bpm
	rhythm_notifier.silent_duration = new_room.duration
	loop_bar.beat_count = new_room.beat_count
	loop_bar.start_x = new_room.region._region.position.x
	loop_bar.end_x = new_room.region._region.end.x
	bg_track_manager.set_active_tracks(new_room.bg_tracks)
	active_room = new_room
	await get_tree().process_frame
	player.visible = true
	player.enabled = true
	player.global_position = active_room.spawn.global_position


func _on_room_finished():
	if is_transitioning:
		return
	is_transitioning = true
	player.enabled = false
	
	print("START TRANSITION")
	var target_beat = rhythm_notifier.get_interval_end_beat(active_room.transition_beat_interval, 0, min_transition_duration)
	active_room.goal.play_ending(target_beat)
	print("PLAYING ENDING with target_beat: %s" % target_beat)
	await rhythm_notifier.wait_until_beat(target_beat)
	is_transitioning = false
	load_room_next_room()
	print("DONE TRANS")
