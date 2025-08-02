extends Node
class_name SceneManager


static var global: Node

@export_group("Dependencies")
@export var _transition_manager: TransitionManager

var is_transitioning: bool = false
var prev_scene: String


func _enter_tree() -> void:
	if global != null:
		queue_free()
		return
	global = self


func _ready() -> void:
	prev_scene = get_tree().current_scene.get_path()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and global == self:
		global = null


func play_level(level: Level):
	transition_to_scene("res://scenes/gameplay.tscn", _setup_level.bind(level))


func _setup_level(level: Level):
	var level_manager = get_node("LevelManager") as LevelManager
	level_manager.load_level(level)
	level_manager.level_finished.connect(func(): transition_to_scene(prev_scene), CONNECT_ONE_SHOT)


func transition_to_scene(scene, setup_callback: Callable = func(): pass):
	if is_transitioning:
		return
	is_transitioning = true
	prev_scene = get_tree().current_scene.get_path()
	await _transition_manager.trans_in()
	if scene is String:
		get_tree().change_scene_to_file(scene)
	else:
		get_tree().change_scene_to_packed(scene)
	await setup_callback
	await _transition_manager.trans_out()
	is_transitioning = false
