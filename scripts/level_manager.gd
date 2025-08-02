extends Node
class_name LevelManager

signal level_finished

@export var level: Level
@export var min_transition_duration: float

@export_group("Dependencies")
@export var camera_region_controller: CameraRegionController2D
@export var loop_bar: LoopBar
@export var player: Player
@export var world: World
@export var trans_color_rect: ColorRect
@export var load_fx: FX
@export var metronome_sfx: AudioStreamPlayer

var active_room: Room
var active_room_index: int
var is_transitioning: bool
var trans_beats_left: int


func _ready() -> void:
	trans_color_rect.color.a = 0.0
	player.death.connect(respawn)
	RhythmNotifier.global.beats(1.0).connect(_on_beat)


func _on_beat(beat: int):
	print("beat: %s, beat_pos: %s abs_beat_pos: %s" % [beat, RhythmNotifier.global.current_beat_position, RhythmNotifier.global.current_abs_beat_position])
	metronome_sfx.play()


func _process(delta: float) -> void:
	if player.global_position.y > Utils.TILE_SIZE * 40:
		player.kill()


func restart_level():
	if not level:
		return
	load_level(level)


func load_level_path(path: String):
	load_level_prefab(load(path) as PackedScene)


func load_level_prefab(new_level_prefab: PackedScene):
	load_level(new_level_prefab.instantiate() as Level)


func load_level(new_level: Level):
	if len(new_level.room_prefabs) == 0:
		push_error("Level must have > 0 rooms!")
		return
	if new_level.get_parent() == null:
		add_child(new_level)
	else:
		new_level.reparent(self)
	level = new_level
	active_room_index = -1
	is_transitioning = true
	BGTrackManager.global.update_tracks(level.audio_tracks)
	load_room_next_room()


func respawn():
	trans_color_rect.color.a = 1.0
	player.global_position = active_room.spawn.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	camera_region_controller.instant_update_camera_position()
	player.enabled = true
	player.reset()
	var tween = create_tween()
	tween.tween_property(trans_color_rect, "color", Color(trans_color_rect.color, 0.0), 1.0) \
		.set_ease(Tween.EASE_OUT)
	load_fx.play()


func load_room_next_room():
	if active_room != null:
		active_room.region.queue_free()
		active_room.queue_free()
	active_room_index += 1
	if active_room_index >= len(level.room_prefabs):
		level_finished.emit()
		return
	player.enabled = false
	await get_tree().process_frame
	var new_room = level.room_prefabs[active_room_index].instantiate() as Room
	world.add_child(new_room)
	new_room.region.reparent(camera_region_controller)
	new_room.finished.connect(_on_room_finished)
	RhythmNotifier.global.bpm = new_room.bpm
	RhythmNotifier.global.silent_duration = new_room.duration
	loop_bar.beat_count = new_room.beat_count
	loop_bar.start_x = new_room.region._region.position.x
	loop_bar.end_x = new_room.region._region.end.x
	BGTrackManager.global.set_active_tracks(new_room.audio_tracks)
	active_room = new_room
	await get_tree().process_frame
	respawn()
	is_transitioning = false


func _on_room_finished():
	if is_transitioning:
		return
	is_transitioning = true
	player.enabled = false
	
	print("START TRANSITION")
	var target_beat = RhythmNotifier.global.get_interval_end_beat(active_room.transition_beat_interval, 0, min_transition_duration)
	active_room.goal.play_ending(target_beat)
	print("PLAYING ENDING with target_beat: %s" % target_beat)
	await RhythmNotifier.global.wait_until_beat(target_beat)
	trans_color_rect.visible = true
	trans_color_rect.color.a = 1.0
	load_room_next_room()
	print("DONE TRANS")
