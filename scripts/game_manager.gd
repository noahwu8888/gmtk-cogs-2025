extends Node
class_name GameManager

@export var camera_region_controller: CameraRegionController2D
@export var player: Player
@export var room: Room


func _ready() -> void:
	change_room(room)

func change_room(new_room: Room):
	room.region.reparent(camera_region_controller)
