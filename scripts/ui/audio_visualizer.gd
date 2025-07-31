extends AudioStreamPlayer
class_name AudioVisualizer

@export var nodes_to_move: Array[Control]
@export_range(-80, 6) var max_volume: float = 0
@export_range(-80, 6) var min_volume: float = -5
@export var max_size_increase: float = 1.2

var _original_scales: Array[Vector2] = []

func _ready() -> void:
	# Store the original scale of each node
	for node in nodes_to_move:
		_original_scales.append(node.scale)

func _process(delta: float) -> void:
	var music_db = AudioServer.get_bus_peak_volume_left_db(1, 0)
	print(music_db)

	# Normalize volume between min_volume and max_volume
	var t = clamp((music_db - min_volume) / (max_volume - min_volume), 0.0, 1.0)

	# Calculate scale factor
	var scale_factor = lerp(1.0, max_size_increase, t)

	# Apply to all nodes
	for i in nodes_to_move.size():
		var node = nodes_to_move[i]
		var original_scale = _original_scales[i]
		node.scale = original_scale * scale_factor
