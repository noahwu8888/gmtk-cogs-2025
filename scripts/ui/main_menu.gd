extends Control

@onready var play_button: Button = $TitleScreen/PlayButton
@onready var settings_button: Button = $TitleScreen/SettingsButton
@onready var quit_button: Button = $TitleScreen/QuitButton 

@onready var title_screen: Control = $TitleScreen
@onready var settings_screen: SettingsMenu = $Settings
@onready var level_select_screen: Control = $LevelSelect


@export var default_stream : AudioStream
@export var settings_stream : AudioStream
@export var level_select_stream : AudioStream

@onready var audio_visualizer: AudioVisualizer = $AudioVisualizer
@onready var audio_track_manager: AudioTrackManager = $AudioTrackManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_track_manager.set_active_tracks([default_stream])


func _on_play_button_pressed() -> void:
	audio_track_manager.set_active_tracks([default_stream,level_select_stream])
	title_screen.visible = false
	level_select_screen.visible = true


func _on_back_button_pressed() -> void:
	audio_track_manager.set_active_tracks([default_stream])
	title_screen.visible = true
	level_select_screen.visible = false


func _on_settings_button_pressed() -> void:
	audio_track_manager.set_active_tracks([default_stream,settings_stream])
	title_screen.visible = false
	settings_screen.visible = true
	
func _on_settings_settings_menu_closed() -> void:
	audio_track_manager.set_active_tracks([default_stream])
	
func _on_quit_button_pressed() -> void:
	pass # Replace with function body.
