@tool
extends Node2D


var platform: Platform


func _ready() -> void:
	platform = get_parent() as Platform
	queue_redraw()


func _draw() -> void:
	if not (Utils.DEBUG or Engine.is_editor_hint()):
		return
	var color = Color.GREEN
	var width = -1
	var arrow_length = 64
	var arrow_angle = 30
	var double_sided = platform.loop_mode == Platform.LoopMode.PING_PONG
	for i in range(len(platform._all_waypoints) - 1):
		Utils.draw_arrow(self, (platform._all_waypoints[i]) * Utils.TILE_SIZE, (platform._all_waypoints[i + 1]) * Utils.TILE_SIZE, color, width, arrow_length, arrow_angle, double_sided)
	if platform.loop_mode == Platform.LoopMode.LOOP:
		Utils.draw_arrow(self, (platform._all_waypoints[-1]) * Utils.TILE_SIZE, (platform._all_waypoints[0]) * Utils.TILE_SIZE, color, width, arrow_length, arrow_angle)
