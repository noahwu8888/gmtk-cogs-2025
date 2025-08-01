extends Control

@onready var play_button: Button = $PlayButton
@onready var settings_button: Button = $SettingsButton
@onready var quit_button: Button = $QuitButton
@onready var audio_visualizer: AudioVisualizer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	pass


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	pass # Replace with function body.

#region Audio Visualizer add


func _on_play_button_mouse_entered() -> void:
	audio_visualizer.nodes_to_move.append(play_button)


func _on_play_button_mouse_exited() -> void:
	audio_visualizer.nodes_to_move.erase(play_button)
	play_button.scale = Vector2.ONE


func _on_settings_button_mouse_entered() -> void:
	audio_visualizer.nodes_to_move.append(settings_button)


func _on_settings_button_mouse_exited() -> void:
	audio_visualizer.nodes_to_move.erase(settings_button)
	settings_button.scale = Vector2.ONE


func _on_quit_button_mouse_entered() -> void:
	audio_visualizer.nodes_to_move.append(quit_button)


func _on_quit_button_mouse_exited() -> void:
	audio_visualizer.nodes_to_move.erase(quit_button)
	quit_button.scale = Vector2.ONE

#endregion
