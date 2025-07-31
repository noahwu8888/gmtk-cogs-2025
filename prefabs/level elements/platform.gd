extends StaticBody2D

@export var dip_amount := 2.5
@export var dip_time := 0.10
@export var rise_time := 0.10

@export var dip_area: Area2D
@export var dip_control_timer: Timer

var origin: Vector2

func _ready():
	origin = global_position
	dip_area.body_entered.connect(_on_body_entered)
	dip_control_timer.set_wait_time(dip_time + rise_time)
	

func _on_body_entered(body):
	if body.name == "Player" && dip_control_timer.get_time_left() == 0.0:
		dip_control_timer.start()
		var tween = create_tween()
		var dip_pos = origin + Vector2(0, dip_amount)
		tween.tween_property(self, "position", dip_pos, dip_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position", origin, rise_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		dip_control_timer.set_wait_time(dip_time + rise_time)

func _physics_process(delta):
	pass
