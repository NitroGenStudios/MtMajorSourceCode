extends StaticBody2D

@onready var animation_player = $AnimationPlayer

var is_player_colliding := false
var has_crumbled := false
var player

@export var is_wall : bool

func _process(_delta):
	if (!is_wall && is_player_colliding && player.coyote_timer >= -0.05 && !has_crumbled) or (is_wall && is_player_colliding && player.is_climbing_wall && !has_crumbled):
		has_crumbled = true
		Crumble()
		

func Crumble():
	animation_player.play("rockfall")

func _on_area_2d_body_entered(body):
	if (!body.is_in_group("player")):
		return
	
	is_player_colliding = true
	player = body as Player

func _on_area_2d_body_exited(body):
	if (!body.is_in_group("player")):
		return
	
	is_player_colliding = false
