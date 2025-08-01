extends Node2D
class_name FX

signal played()
signal stopped()
signal finished()


## Time to wait before playing.
@export var pre_delay: float = 0
## Time after duration to wait before deletion.
@export var post_delay: float = 0
## Duration of the FX
@export var duration: float = 1
@export var play_on_ready: bool
@export var unparent_on_play: bool
@export var destroy_on_finish: bool
## If true, then calling play() while the FX is already playing will cause
## it to stop the exiting playback before starting a new playback
@export var restart_on_play: bool = true

var is_playing: bool = false

@export_group("Dependencies")
@export var chain_unscaled_fxes: Array[FX]
@export var chain_fxes: Array[FX]
@export var fxes: Array[FX]
@export var fx_beat_delays: Array[FXBeat]
@export var cpu_particles: Array[CPUParticles2D]
@export var gpu_particles: Array[GPUParticles2D]
@export var audio_players: Array[AudioStreamPlayer]
@export var audio_player_2ds: Array[AudioStreamPlayer2D]
@export var anim_players: Array[AnimationPlayer]
@export var fx_anims: Array[FXAnim]
@export var fx_anim_trees: Array[FXAnimTree]


func _ready():
	var registered_nodes = {}
	for node in chain_unscaled_fxes + chain_fxes + fxes + cpu_particles + gpu_particles + audio_players + audio_player_2ds + anim_players + fx_anims:
		registered_nodes[node] = true
	for child in get_children():
		if child in registered_nodes:
			continue
		if child is FX:
			fxes.append(child)
		elif child is FXBeat:
			fx_beat_delays.append(child)
		elif child is CPUParticles2D:
			cpu_particles.append(child)
		elif child is GPUParticles2D:
			gpu_particles.append(child)
		elif child is AudioStreamPlayer:
			audio_players.append(child)
		elif child is AudioStreamPlayer2D:
			audio_player_2ds.append(child)
		elif child is AnimationPlayer:
			anim_players.append(child)
		elif child is FXAnim:
			fx_anims.append(child)
		elif child is FXAnimTree:
			fx_anim_trees.append(child)
	if play_on_ready:
		play()


## Stops playback
func stop():
	if not is_playing:
		return
	for node in fxes:
		node.stop()
	for node in chain_unscaled_fxes:
		node.stop()
	for node in chain_fxes:
		node.stop()
	for node in fx_beat_delays:
		node.stop()
	for node in cpu_particles:
		node.emitting = false
	for node in gpu_particles:
		node.emitting = false
	for node in audio_players:
		node.stop()
	for node in audio_player_2ds:
		node.stop()
	for node in anim_players:
		node.stop()
	for node in fx_anims:
		node.stop()
	for node in fx_anims:
		node.stop()
	for node in fx_anim_trees:
		node.stop()
	stopped.emit()


## Play the FX so it lasts for a specific duration.
func play_duration(new_duration: float):
	play(new_duration / duration)


## Play the FX, with a specific time_scale.
## Ex. time_scale = 2 would double the playback speed
func play(time_scale: float = 1):
	if is_playing and restart_on_play:
		stop()
	if pre_delay > 0:
		await Utils.wait(pre_delay * time_scale)
	for node in fxes:
		node.play(time_scale)
	for node in fx_beat_delays:
		node.play()
	for node in cpu_particles:
		node.speed_scale = 1 / time_scale
		node.emitting = true
	for node in gpu_particles:
		node.speed_scale = 1 / time_scale
		node.emitting = true
	for node in audio_players:
		node.pitch_scale = 1 / time_scale
		node.play()
	for node in audio_player_2ds:
		node.pitch_scale = 1 / time_scale
		node.play()
	for node in anim_players:
		node.speed_scale = 1 / time_scale
		node.play()
	for node in fx_anims:
		node.play(time_scale)
	for node in fx_anim_trees:
		node.play()
	if unparent_on_play:
		reparent(World.global)
	played.emit()
	await Utils.wait(duration * time_scale)
	for node in chain_fxes:
		node.play(time_scale)
	for node in chain_unscaled_fxes:
		node.play()
	await Utils.wait(post_delay)
	stopped.emit()
	finished.emit()
	if destroy_on_finish:
		queue_free()
