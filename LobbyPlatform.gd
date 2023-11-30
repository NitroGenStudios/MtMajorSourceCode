extends Node2D

var is_moving_up = false
var is_enabled = false

func _ready():
	is_enabled = GameController.game_state >= 10

func _process(delta):
	if (is_moving_up && is_enabled):
		$mover.position.y -= 100.0 * delta
	elif (!is_moving_up && is_enabled):
		$mover.position.y += 100.0 * delta
	
	$mover.position.y = clamp($mover.position.y, -600.0, 0.0)

func _on_area_2d_body_entered(body):
	if (!body.is_in_group("player")):
		return
	
	is_moving_up = true

func _on_area_2d_body_exited(body):
	if (!body.is_in_group("player")):
		return
	
	is_moving_up = false
