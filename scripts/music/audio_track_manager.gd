extends Node
class_name AudioTrackManager


@export var active_tracks: Dictionary[AudioStream, bool]
@export var fade_duration: float

var audio_player: AudioStreamPlayer
var sync_stream: AudioStreamSynchronized
var prev_track_volumes: Array[float] = []
var new_track_volumes: Array[float] = []
var tween: Tween

func _ready() -> void:
	for child in get_children():
		if child is AudioStreamPlayer:
			audio_player = child
			break
	if audio_player == null:
		audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
	sync_stream = AudioStreamSynchronized.new()
	sync_stream.stream_count = AudioStreamSynchronized.MAX_STREAMS
	for i in range(AudioStreamSynchronized.MAX_STREAMS):
		sync_stream.set_sync_stream(i, null)
		sync_stream.set_sync_stream_volume(i, -80)
	audio_player.stream = sync_stream
	audio_player.play()
	prev_track_volumes.resize(AudioStreamSynchronized.MAX_STREAMS)
	new_track_volumes.resize(AudioStreamSynchronized.MAX_STREAMS)


func set_active_tracks(new_active_tracks: Array[AudioStream]):
	assert(len(new_active_tracks) <= 16, "AudioTrackManager can only support 16 active tracks!")
	if tween != null and tween.is_running():
		tween.kill()
	var free_track_indices = []
	for i in range(AudioStreamSynchronized.MAX_STREAMS):
		var stream = sync_stream.get_sync_stream(i)
		if not (stream in active_tracks or stream in new_active_tracks):
			free_track_indices.append(i)
	print("free tracks: %s" % [free_track_indices])
	for i in range(len(new_active_tracks)):
		sync_stream.set_sync_stream(free_track_indices[i], new_active_tracks[i])
		sync_stream.set_sync_stream_volume(free_track_indices[i], -80)
	active_tracks.clear()
	for track in new_active_tracks:
		active_tracks[track] = true
	for i in range(AudioStreamSynchronized.MAX_STREAMS):
		var stream = sync_stream.get_sync_stream(i)
		prev_track_volumes[i] = sync_stream.get_sync_stream_volume(i)
		new_track_volumes[i] = 0 if stream in active_tracks else -80
	tween = create_tween()
	tween.bind_node(self).tween_method(_tween_tracks, 0.0, 1.0, fade_duration)
	if not audio_player.playing:
		audio_player.play()


func _tween_tracks(value: float):
	for i in range(AudioStreamSynchronized.MAX_STREAMS):
		sync_stream.set_sync_stream_volume(i, lerpf(prev_track_volumes[i], new_track_volumes[i], value))
