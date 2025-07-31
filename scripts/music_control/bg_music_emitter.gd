extends AudioStreamPlayer
class_name BGMusicEmitter

@export var start_room_number : int = 1
@export var end_room_number : int = 100
@export var fade_in_time : float = 1.0
@export var fade_out_time : float = 1.0
@export var beat_length : int = 32 

var music_manager: BGMusicManager
var rhythm_notifier: RhythmNotifier

func _ready() -> void:
	max_polyphony = 2

	music_manager = get_parent()
	if not music_manager:
		push_error("BGMusicManager not found in parent node path.")
	
	# Create and configure the rhythm notifier
	rhythm_notifier = RhythmNotifier.new()
	add_child(rhythm_notifier)
	rhythm_notifier.bpm = music_manager.bpm
	rhythm_notifier.audio_stream_player = self
	
	# Connect beat signal to the handler
	rhythm_notifier.connect("beat", Callable(self, "_on_rhythm_notifier_beat"))

func fade_in() -> void:
	volume_db = -80
	play()
	create_tween().tween_property(self, "volume_db", 0, fade_in_time)

func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "volume_db", -80, fade_out_time)
	tween.tween_callback(Callable(self, "stop"))

func _on_stream_finished() -> void:
	# not used anymore — looping is controlled by beat sync
	pass

func _on_rhythm_notifier_beat(current_beat: int) -> void:
	print("Beat:", current_beat)
	if current_beat == beat_length:
		if music_manager.current_room >= start_room_number and music_manager.current_room <= end_room_number:
			print("Emitter:", self.name, "beat-based loop triggered.")
			play() 
