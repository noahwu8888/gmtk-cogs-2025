extends Node
class_name AudioFader


signal finished

@export var duration: float = 1.0
@export var fade_in_time: float = 1.0
@export var fade_out_time: float = 1.0
@export var cross_fade_time: float = 0.5
@export_range(-80, 80) var volume_db: float = 0.0
@export var loop: bool = false
@export var stream: AudioStream

var audio_players: Array[AudioStreamPlayer]
var audio_tweens: Array[Tween]
var active_index: int = 0
var active_player: AudioStreamPlayer :
	get:
		return audio_players[active_index]
var active_tween: Tween :
	get:
		return audio_tweens[active_index]
	set(value):
		audio_tweens[active_index] = value
var playing: bool :
	get:
		return active_player.playing


func _ready() -> void:
	for i in range(2):
		var player = AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = volume_db
		add_child(player)
		audio_players.append(player)
		audio_tweens.append(null)


func _process(delta: float) -> void:
	if active_player.playing and active_player.get_playback_position() >= duration:
		finished.emit()
		if loop:
			play()
		else:
			fade_out()


func play(fade_in: bool = true, cross_fade: bool = true):
	if active_player.playing and cross_fade:
		# Cross fade
		self.fade_out(cross_fade_time)
		active_index = 0 if active_index == 1 else 1
		active_player.play()
		self.fade_in(cross_fade_time, volume_db)
	else:
		# Just start playing
		active_player.stop()
		active_player.play()
		if fade_in:
			self.fade_in()


func fade_in(time: float = fade_in_time, start_db: float = -80) -> void:
	active_player.volume_db = start_db
	if active_tween != null and active_tween.is_running():
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(active_player, "volume_db", volume_db, time)


func fade_out(time: float = fade_out_time) -> void:
	if active_tween != null and active_tween.is_running():
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(active_player, "volume_db", -80, time)
	active_tween.tween_callback(active_player.stop)
