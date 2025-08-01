extends Node2D
class_name FXBeat


signal played()
signal stopped()
signal finished()


enum Mode {
	PLAY,
	PLAY_ENDING_ON_BEAT
}


## Time to wait before playing.
@export var beat_delay: float = 0
## Time after duration to wait before deletion.
@export var post_delay: float = 0
@export var duration: float = 1.0
@export var play_on_ready: bool
@export var unparent_on_play: bool
@export var destroy_on_finish: bool
## If true, then calling play() while the FX is already playing will cause
## it to stop the exiting playback before starting a new playback
@export var restart_on_play: bool = true

@export_group("Dependencies")
@export var chain_fxes: Array[FX]
@export var fxes: Array[FX]
@export var anim_players: Array[AnimationPlayer]
@export var fx_anims: Array[FXAnim]

var is_playing: bool = false
var mode: Mode
var time_until_beat: float


func _ready():
	var registered_nodes = {}
	for child in get_children():
		if child is FX and child not in chain_fxes:
			fxes.append(child)
		elif child is AnimationPlayer:
			anim_players.append(child)
		elif child is FXAnim:
			fx_anims.append(child)
			
	# Create FX for remainder
	var fx = FX.new()
	for child in get_children():
		if child is not FX and child is not AnimationPlayer and child is not FXAnim:
			child.reparent(fx)
	if fx.get_child_count() == 0:
		fx.queue_free()
	else:
		fx.duration = duration
		add_child(fx)
		fxes.append(fx)
	RhythmNotifier.global.beat_process.connect(_on_beat_process)
	
	if play_on_ready:
		play()


## Stops playback
func stop():
	if not is_playing:
		return
	is_playing = false
	for fx in fxes:
		fx.stop()
	for node in fx_anims:
		node.stop()
	stopped.emit()


## Plays the FX such that it ends on a specific absolute beat.
## This will scale the any scalable fxes.
func play_ending_on_beat(beat: float):
	mode = Mode.PLAY_ENDING_ON_BEAT
	if is_playing and restart_on_play:
		stop()
	if unparent_on_play:
		reparent(World.global)
	is_playing = true
	time_until_beat = beat * RhythmNotifier.global.beat_length - RhythmNotifier.global.current_abs_position
	for fx in fxes:
		fx.play_duration(time_until_beat)
	for node in fx_anims:
		node.is_manual_process = true
		node.play()
	for node in anim_players:
		node.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		node.play()
	played.emit()
	await RhythmNotifier.global.wait_until_beat(beat)
	for node in chain_fxes:
		node.play()
	await get_tree().create_timer(post_delay).timeout
	stopped.emit()
	finished.emit()
	if destroy_on_finish:
		queue_free()


func _on_beat_process(delta: float):
	if not is_playing:
		return
	if mode == Mode.PLAY:
		for node in anim_players:
			node.advance(delta)
		for node in fx_anims:
			node.advance(delta)
	elif mode == Mode.PLAY_ENDING_ON_BEAT:
		for node in anim_players:
			# Scale animation to ensure it ends on the beat
			var delta_scale = node.current_animation_length / time_until_beat
			node.advance(delta * delta_scale)
		for node in fx_anims:
			# Scale animation to ensure it ends on the beat
			var delta_scale = node.animation_length / time_until_beat
			node.advance(delta * delta_scale)


## Play the FX, with a specific time_scale.
## Ex. time_scale = 2 would double the playback speed
func play():
	mode = Mode.PLAY
	if is_playing and restart_on_play:
		stop()
	if unparent_on_play:
		reparent(World.global)
	is_playing = true
	if beat_delay > 0:
		await RhythmNotifier.global.wait_beats(beat_delay)
	for fx in fxes:
		fx.play()
	for node in anim_players:
		node.play()
	for node in fx_anims:
		node.play()
	for node in chain_fxes:
		node.play()
	await get_tree().create_timer(post_delay).timeout
	played.emit()
	stopped.emit()
	finished.emit()
	if destroy_on_finish:
		queue_free()
