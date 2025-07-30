extends Node2D
class_name Room

@export var bg_color: Color = Color.BLACK

@export_group("Dependencies")
@export var fore_layer: TileMapLayer
@export var main_layer: TileMapLayer
@export var bg_layer: TileMapLayer
@export var region: CameraRegion2D


func _ready() -> void:
	RenderingServer.set_default_clear_color(bg_color)
