extends Node
class_name TransitionManager


signal trans_finished


static var global: Node

@export var trans_in_duration: float
@export var trans_in_curve: Curve
@export var trans_out_duration: float
@export var trans_out_curve: Curve

@export_group("Dependencies")
@export var _trans_rect: TextureRect

var _trans_tween: Tween
var _trans_mat: ShaderMaterial

func _enter_tree() -> void:
	if global != null:
		queue_free()
		return
	global = self


func _ready() -> void:
	_trans_mat = _trans_rect.material
	_trans_rect.visible = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and global == self:
		global = null


func trans_in(duration: float = trans_in_duration, curve: Curve = trans_in_curve):
	if _trans_tween and _trans_tween.is_running():
		_trans_tween.kill()
	_trans_rect.visible = true
	_trans_tween = create_tween()
	_trans_tween.tween_method(_tween.bind(curve), 0.0, 1.0, duration)
	await _trans_tween.finished
	trans_finished.emit()


func _tween(value: float, curve: Curve):
	_trans_mat.set_shader_parameter("fill_amount", curve.sample(value))


func trans_out(duration: float = trans_out_duration, curve: Curve = trans_out_curve):
	if _trans_tween and _trans_tween.is_running():
		_trans_tween.kill()
	_trans_tween = create_tween()
	_trans_tween.tween_method(_tween.bind(curve), 1.0, 0.0, duration)
	await _trans_tween.finished
	_trans_rect.visible = false
	trans_finished.emit()
