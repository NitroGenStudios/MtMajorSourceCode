extends Node2D

@onready var level_root = $".."
@onready var enter_anim = $enter/AnimationPlayer

@export var next_level = "lvl_0"

@export var set_game_state := 0

var can_enter = false

func _enter():
	# save lobby position into global
	var lobby = level_root as Lobby
	var gc = get_node("/root/GameController") as GameController
	gc.save_lobby_position(lobby.player.position)
	
	gc.game_state = set_game_state - 1
	
	# load level
	gc.load_level(next_level, level_root, true)

func _process(_delta):
	if (can_enter && Input.is_action_just_pressed("enter")):
		_enter()
		can_enter = false
		
func _on_hitbox_body_entered(body):
	if (!body.is_in_group("player")):
		return
	
	enter_anim.play("enter_on")
	can_enter = true
	
func _on_hitbox_body_exited(body):
	if (!body.is_in_group("player")):
		return
	
	enter_anim.play("enter_off")
	can_enter = false
