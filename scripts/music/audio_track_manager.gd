extends Node
class_name AudioTrackManager


@export var tracks: Array[AudioStream]
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
	audio_player.stream = sync_stream
	update_tracks(tracks)
	audio_player.play()


func update_tracks(tracks: Array[AudioStream]):
	self.tracks = tracks
	sync_stream.stream_count = len(tracks)
	prev_track_volumes.resize(len(tracks))
	new_track_volumes.resize(len(tracks))
	for i in range(len(tracks)):
		sync_stream.set_sync_stream(i, tracks[i])
		sync_stream.set_sync_stream_volume(i, -80)
	audio_player.play()


func set_active_tracks(new_active_tracks: Array[AudioStream]):
	if tween != null and tween.is_running():
		tween.kill()
	active_tracks.clear()
	for track in new_active_tracks:
		active_tracks[track] = true
	for i in range(len(tracks)):
		prev_track_volumes[i] = sync_stream.get_sync_stream_volume(i)
		new_track_volumes[i] = 0 if tracks[i] in active_tracks else -80
	tween = create_tween()
	tween.bind_node(self).tween_method(_tween_tracks, 0.0, 1.0, fade_duration)


func fade_in(duration: float = fade_duration):
	await fade_volume(0, duration)


func fade_out(duration: float = fade_duration):
	await fade_volume(-80, duration)


func fade_volume(dest_db: float, duration: float = fade_duration):
	if tween != null and tween.is_running():
		tween.kill()
	for i in range(len(tracks)):
		prev_track_volumes[i] = sync_stream.get_sync_stream_volume(i)
		new_track_volumes[i] = dest_db
	tween = create_tween()
	tween.bind_node(self).tween_method(_tween_tracks, 0.0, 1.0, duration)
	await tween.finished


func _tween_tracks(value: float):
	for i in range(len(tracks)):
		sync_stream.set_sync_stream_volume(i, lerpf(prev_track_volumes[i], new_track_volumes[i], value))
