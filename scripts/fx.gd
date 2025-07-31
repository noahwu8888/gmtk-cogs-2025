extends Node2D
class_name FX

signal played()
signal stopped()
signal finished()


## Time to wait before playing.
@export var pre_delay: float = 0
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
@export var fxes: Array[FX]
@export var cpu_particles: Array[CPUParticles2D]
@export var gpu_particles: Array[GPUParticles2D]
@export var audio_players: Array[AudioStreamPlayer]
@export var audio_player_2ds: Array[AudioStreamPlayer2D]
@export var animation_players: Array[AnimationPlayer]
@export var fx_animations: Array[FXAnim]


func _ready():
	if play_on_ready:
		play()
	for child in get_children():
		if child is FX:
			fxes.append(child)
		elif child is CPUParticles2D:
			cpu_particles.append(child)
		elif child is GPUParticles2D:
			gpu_particles.append(child)
		elif child is AudioStreamPlayer:
			audio_players.append(child)
		elif child is AudioStreamPlayer2D:
			audio_player_2ds.append(child)
		elif child is AnimationPlayer:
			animation_players.append(child)
		elif child is FXAnim:
			fx_animations.append(child)


## Stops playback
func stop():
	if not is_playing:
		return
	for node in fxes:
		node.stop()
	for node in cpu_particles:
		node.emitting = false
	for node in gpu_particles:
		node.emitting = false
	for node in audio_players:
		node.stop()
	for node in audio_player_2ds:
		node.stop()
	for node in animation_players:
		node.stop()
	for node in fx_animations:
		node.stop()
	stopped.emit()


## Play the FX so it lasts for a specific duration.
func play_duration(new_duration: float):
	print("new duration: ", new_duration, " duration: ", duration)
	play(duration / new_duration)


## Play the FX, with a specific time_scale.
## Ex. time_scale = 2 would double the playback speed
func play(time_scale: float = 1):
	if is_playing and restart_on_play:
		stop()
	if pre_delay > 0:
		await Utils.wait(pre_delay * time_scale)
	print("time_scale: ", time_scale)
	for node in fxes:
		node.play(time_scale)
	for node in cpu_particles:
		node.speed_scale = 1 / time_scale
		node.emitting = true
	for node in gpu_particles:
		node.speed_scale = 1 / time_scale
		node.emitting = true
	for node in audio_players:
		node.pitch_scale = 1 / time_scale
		print("pitch scale: ", node.pitch_scale)
		node.play()
	for node in audio_player_2ds:
		node.pitch_scale = 1 / time_scale
		node.play()
	for node in animation_players:
		node.speed_scale = 1 / time_scale
		node.play()
	for node in fx_animations:
		node.play(time_scale)
	if unparent_on_play:
		reparent(World.global)
	played.emit()
	await Utils.wait(duration * time_scale)
	stopped.emit()
	finished.emit()
	if destroy_on_finish:
		queue_free()
