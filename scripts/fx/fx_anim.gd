extends Node
class_name FXAnim


@export var animation_player: AnimationPlayer
@export var anim_name: String
@export var blend: float
## If true, then the animation player will be ticked manually
@export var is_manual_process: bool :
	get:
		return is_manual_process
	set(value):
		is_manual_process = value
		if is_inside_tree():
			if is_manual_process:
				animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL

var animation_length: float :
	get:
		if animation_player == null:
			return 0.0
		return animation_player.get_animation(anim_name).length


func play(time_scale: float = 1.0):
	if animation_player == null:
		return
	animation_player.speed_scale = 1 / time_scale
	animation_player.play(anim_name, blend)


func stop():
	if animation_player == null:
		return
	animation_player.stop()


func advance(delta: float):
	if animation_player == null:
		return
	animation_player.advance(delta)
