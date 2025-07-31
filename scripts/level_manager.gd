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
@export var bg_part_manager: AudioPartManager

var active_room: Room
var active_room_index: int
var is_transitioning: bool
var trans_beat: int

func _ready() -> void:
	rhythm_notifier.beat.connect(_on_beat)
	load_level.call_deferred(level)

func load_level(new_level: Level):
	level = new_level
	active_room_index = -1
	load_room_next_room()

func load_room_next_room():
	if active_room != null:
		active_room.queue_free()
	active_room_index += 1
	if active_room_index >= len(level.room_prefabs):
		level_completed.emit()
		return
	player.enabled = true
	var new_room = level.room_prefabs[active_room_index].instantiate() as Room
	world.add_child(new_room)
	new_room.region.reparent(camera_region_controller)
	new_room.finished.connect(_on_room_finished)
	rhythm_notifier.bpm = new_room.bpm
	rhythm_notifier.silent_duration = new_room.duration
	loop_bar.beat_count = new_room.beat_count
	loop_bar.start_x = new_room.region._region.position.x
	loop_bar.end_x = new_room.region._region.end.x
	bg_part_manager.set_active_parts(new_room.bg_tracks)
	active_room = new_room

func _on_room_finished():
	is_transitioning = true
	player.enabled = false
	# The next interval we could use to transition
	# Ex. Asumming transition_beat_interval = 4, this partitions beats into multiples of 4
	#               .- trans_beat (wraps around)                                .- end of song
	# beat          0    1    2    3    4    5    6    7    8    9    10   11   12   13   14   15
	#               |----|----|----|----|----|----|----|----|----|----|----|----X----|----|----|
	# interval      0                   1    |              2    |              3
	#                    curr_interval -'    '- curr_beat        |              '- trans_interval_unbounded
	#                       curr_beat + min_transition_duration -'              
	# Unit: beats
	var min_trans_beats: float = min_transition_duration * active_room.bps
	# Unit: intervals
	var trans_interval_unbounded: int = ceil((rhythm_notifier.current_beat + min_trans_beats) / active_room.transition_beat_interval)
	# Unit: beats
	# ceil(intervals * beats/interval) % beats
	trans_beat = (trans_interval_unbounded * active_room.transition_beat_interval) % active_room.beat_count
	# Unit: seconds
	# interval * beats/interval * seconds/beat = seconds
	var time_left = trans_interval_unbounded * active_room.transition_beat_interval / active_room.bps
	active_room.goal.play_ending(time_left)
	print("PLAYING ENDING with time: %s" % time_left)
	print("TRANS BEAT %s beat_pos: %s beat: %s" % [trans_beat, rhythm_notifier.current_beat_position, rhythm_notifier.current_beat])

func _on_beat(current_beat: int):
	print("beat: ", current_beat)
	if is_transitioning and current_beat == trans_beat:
		is_transitioning = false
		#print("DONE TRANS")
		load_room_next_room()
