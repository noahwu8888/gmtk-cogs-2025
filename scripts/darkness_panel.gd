extends Sprite2D

var is_pressed: bool = false

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		if !is_pressed:
			visible = !visible
		is_pressed = true
	else:
		is_pressed = false
