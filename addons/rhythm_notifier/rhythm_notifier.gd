@tool
@icon("icon.svg")
class_name RhythmNotifier
extends Node
## A node that emits emits rhythmic signals synchronized with the beat of an [AudioStreamPlayer].
##
## [RhythmNotifier] lets you define custom signals that emit when a given beat in the audio stream
## is reached, or that emit every [code]N[/code] beats.  The signals are precisely synchronized 
## with the audio, accounting for output latency.  You can also run the [RhythmNotifier] without 
## playing audio, to generate rhythmic signals without music.
## 
## [br][br][color=yellow]Note:[/color] Beats are 0-indexed to make [RhythmNotifier] easier
## to use, while musicians are accustomed to counting from beat one.
##
## [br][br][b]Usage example:[/b]
## [codeblock]
## @onready var r: RhythmNotifier = $RhythmNotifier  # Set bpm and audio_stream_player in inspector
##
## # Play music and emit lots of signals
## func _play_some_music():
##     # Print on beat 4, 8, 12...
##     r.beats(4).connect(func(count): print("Hello from beat %d!" % (count * 4)))
##
##     # Print on beat 5, 8, 11...
##     r.beats(3, true, 2).connect(func(count): print("Hello from beat %d!" % 2+(count * 3)))
##
##     # Print anytime beat 8.5 is reached
##     r.beats(8.5, false).connect(func(_i): print("Hello from beat eight and a half!"))
##
##     r.audio_stream_player.play()  # Start signaling
##     r.audio_stream_player.seek(1.5)  # pausing/stopping/seeking all supported
##
##     # Stop playback on beat 20
##     r.beats(20, false).connect(func(_i): r.audio_stream_player.stop())
##
## # Play the music after 4 pickup beats
## func _play_with_leadin():
##     r.beats(4, false).connect(func(_i):
##         r.audio_stream_player.play()
##     , CONNECT_ONE_SHOT)
##
##     r.beat.connect(func(count):
##         if not r.audio_stream_player.playing:
##             print("Pickup beat %d" % count)
##         else:
##             print("Song beat %d" % count)
##
##     r.running = true  # Start signaling without playing the audio stream
##
## # Change the song tempo partway through
## func _change_tempos():
##     r.bpm = 60
##     r.beats(4).connect(func(count):
##         if r.bpm == 60 and count == 4:
##             print("Four seconds into the song, we speed up.")
##             r.bpm = 120
##         elif r.bpm == 120:
##             print("We are %.2f seconds into the song." % r.current_position)
##     )
##     r.audio_stream_player.play()
## [/codeblock]
##
## [b]Usage example:[/b] Printing the rhythm musicians say when counting measures [i]("ONE and 
## two and three and TWO and two and three and THREE and ...")[/i]
##
## [codeblock]
## var r = RhythmNotifier.new()
## get_tree().current_scene.add_child(r)
## r.running = true
## 
## # Say the measure number at the start of each measure
## r.beats(3).connect(func(count):
##     print("TIME %.2f, BEAT %2d  :    %d!" %
##         [r.current_position, r.current_beat, count])
## )
## # Say the other downbeats in the measure
## r.beat.connect(func(count):
##     if count % 3 != 0:
##         print("TIME %.2f, BEAT %2d  :       (%d)" % 
##             [r.current_position, count, (count % 3)+1])
## )
## # Say the upbeats in the measure
## r.beats(.5).connect(func(i):
##     if i % 2 != 0:
##         print("TIME %.2f, BEAT %4.1f:       (and)" %
##             [r.current_position, i/2.])
## )
##
## # Output:
## #     TIME 0.52, BEAT  0.5:       (and)
## #     TIME 1.00, BEAT  1  :       (2)
## #     TIME 1.52, BEAT  1.5:       (and)
## #     TIME 2.02, BEAT  2  :       (3)
## #     TIME 2.52, BEAT  2.5:       (and)
## #     TIME 3.02, BEAT  3  :    1!
## #     TIME 3.52, BEAT  3.5:       (and)
## #     TIME 4.02, BEAT  4  :       (2)
## #     TIME 4.52, BEAT  4.5:       (and)
## #     TIME 5.02, BEAT  5  :       (3)
## #     TIME 5.52, BEAT  5.5:       (and)
## #     TIME 6.02, BEAT  6  :    2!
## #     TIME 6.52, BEAT  6.5:       (and)
## #     TIME 7.02, BEAT  7  :       (2)
## #     TIME 7.52, BEAT  7.5:       (and)
## #     TIME 8.02, BEAT  8  :       (3)
## #     TIME 8.50, BEAT  8.5:       (and)
## #     TIME 9.00, BEAT  9  :    3!
## #     TIME 9.50, BEAT  9.5:       (and)
## # ...etc
## [/codeblock]
##
## [br][br]See [method beats] for more usage examples.


class _Rhythm:

	signal interval_changed(current_interval: int)

	var repeating: bool
	var duration: float 
	var start_beat: float
	var last_frame_interval # int or null
	var use_abs_position: bool
	var cleanup: bool
	

	func _init(_repeating: bool, _use_abs_position: bool, _duration: float, _start_beat: float):
		repeating = _repeating
		duration = _duration
		start_beat = _start_beat
		use_abs_position = _use_abs_position
		

	const TOO_LATE = .1 # This long after interval starts, we are too late to emit
	# We pass secs_per_beat so user can change bpm any time
	func emit_if_needed(beat_position: float, abs_beat_position: float, secs_per_beat: float) -> void:
		var interval_secs = duration * secs_per_beat
		var elapsed_beat_time = beat_position - start_beat
		if use_abs_position:
			elapsed_beat_time = abs_beat_position - start_beat
		var current_interval = int(floor(elapsed_beat_time / duration))
		var secs_past_interval = fmod(elapsed_beat_time * secs_per_beat, interval_secs)
		var valid_interval = current_interval >= 0 and (repeating or current_interval == 1)
		var too_late = secs_past_interval >= TOO_LATE
		#if duration != 1.0:
			#print("current_interval: %s, elapsed_beat_time: %s, interval_secs: %s" % [current_interval, elapsed_beat_time, interval_secs])
		if not valid_interval or too_late:
			# Invalid interval or interval is too late
			last_frame_interval = null
		elif last_frame_interval != current_interval:
			# Valid new interval
			if use_abs_position:
				interval_changed.emit(current_interval)
				if not repeating:
					# If we aren't repeating, then mark ourselves as finishes so we can be remove
					# from the RhythmNotifier
					cleanup = true
			else:
				interval_changed.emit(current_interval)
			#print("RHYTHM NOTIFIER, ", current_interval)
			last_frame_interval = current_interval


## Emitted once per beat, excluding beat 0.  The [param current_beat] parameter
## is the value of [member RhythmNotifier.current_beat].
## [br][br][color=yellow]Note:[/color] This once-per-beat signal is a convenience to 
## allow connecting in the inspector, and is equivalent to [code]beats(1.0)[/code]. For
## other signal frequencies, use [method beats].
signal beat(current_beat: int)
## Emitted whenever the notifier advances the current_position by a delta.
## This can be used to advance nodes like AnimationPlayers in sync with the audio.
signal beat_process(delta: float)

static var global: RhythmNotifier

## Beats per minute.  Changing this value changes [member beat_length].
## [br][br]This value can be changed while [member running] is true.
@export var bpm: float = 60.0:
	set(val):
		if val == 0: return
		bpm = val
		notify_property_list_changed()

## Length of one beat in seconds.  Changing this value changes [member bpm].  It is usually more 
## precise to specify [member bpm] and let [member beat_length] be calculated automatically,
## because song tempos are often an integer bpm.
@export var beat_length: float = 1.0:
	get:
		return 60.0 / bpm
	set(val):
		if val == 0: return
		bpm = 60.0 / val

## Maximum current_position value before it ends. Used if no AudioStreamPlayer is set.
@export var silent_duration: float = 1.0

## Optional [AudioStreamPlayer] to synchronize signals with.  While [member audio_stream_player] is
## playing, [signal beat] and [method beats] signals will be emitted based on playback position.
## [br][br]See [member running] for emitting signals without an [AudioStreamPlayer].
@export var audio_stream_player: AudioStreamPlayer

## If [code]true[/code], [signal beat] and [method beats] signals are being emitted.  Can be set to
## [code]true[/code] to emit signals without playing a stream.  [member running] is always
## [code]true[/code] while [member audio_stream_player] is playing.
@export var running: bool:
	get: return _silent_running or _stream_is_playing()
	set(val):
		if val == running:
			return  # No change
		if _stream_is_playing():
			return  # Can't override
		_silent_running = val
		_position = 0.0

## if true, then this notifier will be registered as the global notifier
@export var is_global: bool

## The current beat, indexed from [code]0[/code].
var current_beat: int:
	get: return int(floor(_position / beat_length))
## The current position in seconds.  If [member audio_stream_player] is playing, this is the
## accurate number of seconds into the stream, and setting the value will seek to
## that position.  If the audio stream is not playing, this is the number of seconds
## that [member running] has been set to true, if any, and setting overrides the value.
var current_position: float:
	get: return _position
	set(val):
		if _stream_is_playing():
			audio_stream_player.seek(val)
		elif _silent_running:
			_position = val
## The current beat as a float position. This is = current_position / beat_length.
## Use current_beat if you want an integer number for the beat.
var current_beat_position: float:
	get: return _position / beat_length

## The current absolute beat, indexed from [code]0[/code]. This beat is monotonically increasing
var current_abs_beat: int:
	get: return int(floor(current_abs_position / beat_length))
## The current absolute beat as a float position. This position is monotonically increasing.
## This is = current_position / beat_length. Use current_beat if you want an integer number for the beat.
var current_abs_beat_position: float:
	get: return current_abs_position / beat_length
## The current absolute position in seconds. This position is monotonically increasing.
## If [member audio_stream_player] is playing, this is the accurate number of seconds into the 
## stream. If the audio stream is not playing, this is the number of seconds that [member running] 
## has been set to true, if any.
var current_abs_position: float:
	get: return _abs_position
# Position that is between [0, AudioStream.get_length()]
var _position: float = 0.0
# Position that always monotonically increases
var _abs_position: float = 0.0
var _length: float :
	get:
		if _silent_running:
			return silent_duration
		else:
			return audio_stream_player.stream.get_length()
	
var _cached_output_latency: float:
	get:
		if Time.get_ticks_msec() >= _invalidate_cached_output_latency_by:
			# Cached because method is expensive per its docs
			_cached_output_latency = AudioServer.get_output_latency()
			_invalidate_cached_output_latency_by = Time.get_ticks_msec() + 1000
		return _cached_output_latency
var _invalidate_cached_output_latency_by := 0
var _silent_running: bool
var _rhythms: Dictionary[String, _Rhythm] = {}


func _enter_tree() -> void:
	if is_global:
		if global != null:
			queue_free()
			return
		global = self


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and is_global and global == self:
		global = null


func _ready():
	beats(1.0).connect(beat.emit)


# If not stopped, recalculate track position and emit any appropriate signals.
func _physics_process(delta):
	if _silent_running and _stream_is_playing():
		_silent_running = false
	if not running:
		return
	
	var prev_position = _position
	
	if _silent_running:
		_position += delta
		if silent_duration > 0:
			_position = fmod(_position, silent_duration)
	if not _silent_running:
		_position = audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix() - _cached_output_latency
	
	if prev_position > _position:
		# We've looped, so _position is the new delta
		delta = _position + (_length - prev_position)
	else:
		# Use the difference as the delta
		delta = _position - prev_position
	_abs_position += delta
	beat_process.emit(delta)
	
	if Engine.is_editor_hint():
		return
	for key in _rhythms:
		var rhythm = _rhythms[key]
		rhythm.emit_if_needed(current_beat_position, current_abs_beat_position, beat_length)
		if rhythm.cleanup:
			_rhythms.erase(key)


## Returns a signal that emits when a specific beat is reached, or repeatedly every specified
## number of beats. [param start_beat] (defaults to [code]0.0[/code]) is the beat from which
## to begin counting. [param duration] is the number of beats after [param start_beat] on which
## to signal. If [param repeating] (defaults to [code]true[/code]), the signal is emitted
## every [param duration] beats after [param start_beat].
## [br][br]Callback should be of the form [code]fn(current_interval)[/code], where
## [param current_interval] is the number of [param duration]-length intervals 
## past [param start_beat].
##
## [br][br]Usage:
## [codeblock]
## # Signals on beat 1, 2, 3, etc.  Equivalent to beat.connect(...)
## beats(1.0).connect(func(beat): pass)
##
## # Signals on beat 4, 8, 12, etc
## beats(4).connect(func(four_beat_group): pass)  # Parameter value will be 1, 2, 3, etc.
## # Signals on beat 6.25, 10.25, 12.25, etc
## beats(4.25, true, 2).connect(func(four_beat_group): pass)  # Parameter value will be 1, 2, 3, etc.
##
## # Signals anytime playback reaches beat 8.5
## beats(8.5, false).connect(func(_i): pass)  # Parameter value will be 1
## # Signals anytime playback reaches beat 10
## beats(8, false, 2).connect(func(_i): pass)  # Parameter value will be 1
##
## # Signals once, on beat 8
## beats(8, false).connect(_func, CONNECT_ONE_SHOT)
## # Signals once, the first time a multiple of 4 beats after beat 2 is reached
## beats(4, true, 2).connect(_func, CONNECT_ONE_SHOT)
## [/codeblock]
func beats(duration: float, repeating := true, use_abs_position := true, start_beat := 0.0) -> Signal:
	var key = "%s %s%s %s" % [duration, int(repeating), int(use_abs_position), start_beat]
	if key in _rhythms:
		return _rhythms[key].interval_changed
	var new_rhythm = _Rhythm.new(repeating, use_abs_position, duration, start_beat)
	_rhythms[key] = new_rhythm
	return new_rhythm.interval_changed


## Waits a specifc number of beats, specified by duration.
func wait_beats(duration: float, rounded: bool = true) -> Signal:
	return beats(duration, false, true, float(current_abs_beat) if rounded else current_abs_beat_position)


## Waits until a specific absolute beat
func wait_until_beat(beat: float) -> Signal:
	return beats(beat, false, true, 0.0)


## Returns the next absolute beat at a given beat_interval.
## The next beat will be at least min_gap away from the current abs position.
## Use beat_offset to change the start of the beat_interval.
func get_next_abs_beat(min_time_gap: float, beat_interval: float, beat_offset: int = 0) -> float:
	var gap_beats: float = min_time_gap / beat_length
	var curr_abs_interval: int = ceil((current_abs_beat_position + gap_beats + beat_offset) / beat_interval)
	var target_beat = curr_abs_interval * beat_interval - beat_offset
	return target_beat


## Returns the next absolute position (time in seconds) at a given beat_interval.
## The next beat will be at least min_gap away from the current abs position.
## Use beat_offset to change the start of the beat_interval.
func get_next_abs_position(min_time_gap: float, beat_interval: float, beat_offset: int = 0) -> float:
	return get_next_abs_beat(min_time_gap, beat_interval, beat_offset) * beat_length


func _stream_is_playing():
	return audio_stream_player != null and audio_stream_player.playing
