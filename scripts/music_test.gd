extends Node
class_name MusicTest

@export var kick_player: AudioStreamPlayer
@export var rhythm_notifier: RhythmNotifier
@export var min_transition_duration: float = 1.0
@export var transition_beat_interval: float = 4.0 
@export var bpm: float = 130
@export var latency: float = 0.01
var bps: float :
	get:
		return bpm / 60

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			start()


func _ready() -> void:
	rhythm_notifier.beats(1.0).connect(func(count):
		print("TIME %.4f, ABS_TIME: %.4f, CALC_TIME: %.4f, BEAT %2d  :    %d!" % [rhythm_notifier.current_position, rhythm_notifier.current_abs_position, fmod(rhythm_notifier.current_abs_position, rhythm_notifier.audio_stream_player.stream.get_length()), rhythm_notifier.current_beat, count])
	)


func start():
	#r.beats(1.0).connect(func(count):
		#print("TIME %.2f, BEAT %2d  :    %d!" % [r.current_position, r.current_beat, count])
	#)
	print("START TRANSITION")
	var min_trans_beats_left: float = min_transition_duration * bps
	print("    min_transition_duration: ", min_transition_duration, " active_room.bps: ", bps)
	# Unit: intervals
	var trans_interval_unbounded: int = ceil((rhythm_notifier.current_abs_beat_position + min_trans_beats_left) / transition_beat_interval)
	print("    trans_interval_unbounded: rhythm_notifier.current_beat: ", rhythm_notifier.current_beat, " current beat_position: ", rhythm_notifier.current_beat_position, " min_trans_beats_left: ", min_trans_beats_left, " transition_beat_interval: ", transition_beat_interval)
	# Unit: beats
	# ceil(intervals * beats/interval) % beats
	var target_beat = trans_interval_unbounded * transition_beat_interval
	var target_position = target_beat / bps
	print("    target_beat: ", target_beat)
	#await get_tree().create_timer(target_position - rhythm_notifier.current_abs_position).timeout
	await rhythm_notifier.beats(target_beat - latency, false)
	kick_player.play()
	print("TRANSITION END %.2f, BEAT %2d! STARTING AT %sp" % [rhythm_notifier.current_position, rhythm_notifier.current_abs_beat, rhythm_notifier.current_abs_position - target_position])
	print("    latency: %s cached_latency: %s" % [latency, rhythm_notifier._cached_output_latency])
	
