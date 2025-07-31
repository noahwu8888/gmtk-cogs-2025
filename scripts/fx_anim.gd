extends Node
class_name FXAnim

@export var animation_player: AnimationPlayer
@export var anim_name: String
@export var blend: float

func play(time_scale: float):
	animation_player.speed_scale = 1 / time_scale
	animation_player.play(anim_name, blend)
