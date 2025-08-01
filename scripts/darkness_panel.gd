extends Sprite2D

enum Difficulty {
	OFF,
	EASY,
	NORMAL,
	HARD
}

@export var difficulty: Difficulty
var is_pressed: bool = false

func _process(delta: float) -> void:
	match difficulty:
		Difficulty.OFF:
			visible = false
		Difficulty.EASY:
			visible = true
			scale = Vector2(20, 20)
		Difficulty.NORMAL:
			visible = true
			scale = Vector2(10, 10)
		Difficulty.HARD:
			visible = true
			scale = Vector2(3, 3)
	if Input.is_key_pressed(KEY_SHIFT):
		if !is_pressed:
			difficulty = (difficulty + 1) % 4
		is_pressed = true
	else:
		is_pressed = false
