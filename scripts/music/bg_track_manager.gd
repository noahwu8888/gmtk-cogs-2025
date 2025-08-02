extends AudioTrackManager
class_name BGTrackManager


static var global: BGTrackManager

func _enter_tree() -> void:
	if global != null:
		queue_free()
		return
	global = self

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and global == self:
		global = null
