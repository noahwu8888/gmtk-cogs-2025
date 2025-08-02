extends Node2D
class_name Room

signal finished

@export_group("Music Settings")
## Beats per minute
@export var bpm: float = 136
## Beats per second
var bps: float :
	get: 
		return bpm / 60
## Duration of the room in beats
@export var beat_count: int = 32
## Duration of the room in seconds
var duration: float :
	get:
		return beat_count / bpm * 60
## When the player completes the level,
## the level will transition once the beat 
## reaches a specific multiple.
@export var transition_beat_interval: int = 4
@export var bg_tracks: Array[AudioStream]
@export var active_tracks: Array[AudioStream]

@export var bg_color: Color = Color.BLACK

@export_group("Dependencies")
@export var region: CameraRegion2D

var goal: Goal
var spawn: Node2D


func _ready() -> void:
	RenderingServer.set_default_clear_color(bg_color)
	_deferrred_ready.call_deferred()


func _deferrred_ready():
	spawn = Utils.get_node_by_group(self, "spawn")
	if spawn == null:
		push_error("Room missing a spawn point!")
	spawn.visible = false
	goal = Utils.get_node_by_type(self, "Goal")
	if goal == null:
		push_error("Room missing a goal!")
	goal.player_entered.connect(finished.emit)
