extends Node
class_name MusicTest

@export var kick_player: AudioStreamPlayer
@export var rhythm_notifier: RhythmNotifier
@export var min_transition_duration: float = 1.0
@export var transition_beat_interval: float = 4.0 
@export var bpm: float = 130
@export var latency: float = 0.01
@export var fx: FX
var bps: float :
	get:
		return bpm / 60

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			start()
		elif event.keycode == KEY_O:
			start_fx()


func _ready() -> void:
	rhythm_notifier.beats(1.0).connect(func(count):
		print("TIME %.4f, ABS_TIME: %.4f, CALC_TIME: %.4f, BEAT %2d  :    %d!" % [rhythm_notifier.current_position, rhythm_notifier.current_abs_position, fmod(rhythm_notifier.current_abs_position, rhythm_notifier.audio_stream_player.stream.get_length()), rhythm_notifier.current_beat, count])
	)


func start():
	print("START TRANSITION")
	var target_beat = rhythm_notifier.get_next_abs_beat(min_transition_duration, transition_beat_interval)
	var target_position = target_beat * rhythm_notifier.beat_length
	#print("    target_beat: ", target_beat)
	print("    target_position: ", target_position)
	print("    notifier rhythms: ", rhythm_notifier._rhythms)
	#await Utils.wait(target_position - rhythm_notifier.current_abs_position)
	await rhythm_notifier.beats(target_beat - latency, false)
	kick_player.play()
	print("TRANSITION END")
	print("    latency: %s cached_latency: %s" % [latency, rhythm_notifier._cached_output_latency])
	

func start_fx():
	fx.play()
