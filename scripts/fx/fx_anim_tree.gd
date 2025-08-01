extends Node
class_name FXAnimTree


@export var animation_tree: AnimationTree
@export var state: String
@export var state_machine_path: String = "parameters/playback"


func play():
	if animation_tree == null:
		return
	animation_tree.get(state_machine_path).travel(state)


func stop():
	if animation_tree == null:
		return
	animation_tree.get(state_machine_path).stop()
