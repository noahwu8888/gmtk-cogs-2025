@tool
extends Node2D


var platform: Platform


func _ready() -> void:
	platform = get_parent() as Platform
	queue_redraw()


func _draw() -> void:
	if not (SUtils.DEBUG or Engine.is_editor_hint()):
		return
	var color = Color.GREEN
	var width = -1
	var arrow_length = 64
	var arrow_angle = 30
	var double_sided = platform.loop_mode == Platform.LoopMode.PING_PONG
	var offset = platform.rect.get_center()
	for i in range(len(platform._all_waypoints) - 1):
		SUtils.draw_arrow(self, (offset + platform._all_waypoints[i]) * SUtils.TILE_SIZE, (offset + platform._all_waypoints[i + 1]) * SUtils.TILE_SIZE, color, width, arrow_length, arrow_angle, double_sided)
	if platform.loop_mode == Platform.LoopMode.LOOP:
		SUtils.draw_arrow(self, (offset + platform._all_waypoints[-1]) * SUtils.TILE_SIZE, (offset + platform._all_waypoints[0]) * SUtils.TILE_SIZE, color, width, arrow_length, arrow_angle)
