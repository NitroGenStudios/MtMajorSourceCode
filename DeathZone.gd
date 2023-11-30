extends Node2D

func _on_area_2d_body_entered(body):
	if (!body.is_in_group("player")):
		return
	
	# kill player
	(body as Player).is_dead = true
	
	# play sound
	(get_node("/root/Soundline") as soundline).play_one_shot_2D("die", "PLAYER")
	
	var game_c = get_node("/root/GameController") as GameController
	game_c.current_lobby.reset()
	game_c.ui.add_death()
	game_c.ui.pause()
