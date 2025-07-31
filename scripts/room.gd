extends Node2D
class_name Room

@export_group("Music Settings")
@export var bpm = 136
@export var beat_count = 32
@export var loop_bar : LoopBar

@export var bg_tracks : Array[AudioStream]

@export var bg_color: Color = Color.BLACK

@export_group("Dependencies")
@export var fore_layer: TileMapLayer
@export var main_layer: TileMapLayer
@export var bg_layer: TileMapLayer
@export var region: CameraRegion2D



func _ready() -> void:
	RenderingServer.set_default_clear_color(bg_color)
	
	
	if loop_bar:
		loop_bar.bpm = self.bpm
		loop_bar.beats = self.beat_count
