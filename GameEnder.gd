extends Node

@export var time = 0.0

func _ready():
	await get_tree().create_timer(time).timeout
	
	var game_c = get_node("/root/GameController") as GameController
	
	game_c.ui.show_end_screen()
	game_c.get_current_lobby().player.is_dead = true
