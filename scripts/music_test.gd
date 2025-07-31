extends Node
class_name MusicTest

@export var scale: float = 1.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		#if event.keycode == KEY_P:
			#play()
		#elif event.keycode == KEY_S:
			#stop()
		if event.keycode == KEY_O:
			play_sync()
		elif event.keycode == KEY_W:
			stop_sync()


#func play():
	#for child in get_children():
		#if child is AudioStreamPlayer:
			##await get_tree().create_timer(1).timeout
			#child.play()
#
#
#func stop():
	#for child in get_children():
		#if child is AudioStreamPlayer:
			#child.stop()


func play_sync():
	#$"../Synchronized".play()
	$"../EndingFX".play(scale)


func stop_sync():
	#$"../Synchronized".stop()
	$"../EndingFX".play(scale)
