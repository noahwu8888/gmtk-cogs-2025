extends AudioStreamPlayer
class_name AudioVisualizer

@export var nodes_to_move: Array[Control]
@export_range(20, 20000) var frequency_low: float = 30
@export_range(20, 20000) var frequency_high: float = 250
@export_range(0.0, 1.0) var sensitivity: float = 1.0
@export var max_size_increase: float = 1.5
@export var smoothing_speed: float = .2

var _original_scales: Array[Vector2] = []
var _current_scale_factor := 1.0
var _analyzer: AudioEffectSpectrumAnalyzerInstance

func _ready() -> void:
	for node in nodes_to_move:
		_original_scales.append(node.scale)

	# Access the analyzer from the correct bus (e.g., "Music")
	var bus_index = AudioServer.get_bus_index("Music")
	var effect_index = 0 # first effect slot on the bus
	var effect = AudioServer.get_bus_effect(bus_index, effect_index)
	if effect is AudioEffectSpectrumAnalyzer:
		_analyzer = AudioServer.get_bus_effect_instance(bus_index, effect_index)

func _process(delta: float) -> void:
	if _analyzer == null:
		return

	# Check for new nodes added at runtime
	while _original_scales.size() < nodes_to_move.size():
		var new_index = _original_scales.size()
		_original_scales.append(nodes_to_move[new_index].scale)

	# Get the magnitude from the analyzer
	var magnitude = _analyzer.get_magnitude_for_frequency_range(frequency_low, frequency_high)
	var volume = magnitude.length() * sensitivity

	# Clamp and scale
	var t = clamp(volume, 0.0, 1.0)
	var target_scale_factor = lerp(1.0, max_size_increase, t)
	_current_scale_factor = move_toward(_current_scale_factor, target_scale_factor, delta * smoothing_speed)

	# Apply scaling
	for i in nodes_to_move.size():
		nodes_to_move[i].scale = _original_scales[i] * _current_scale_factor
