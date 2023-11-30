extends Node2D


func _ready():
	if ((get_node("/root/GameController") as GameController).game_state != 0):
		return
	
	await get_tree().create_timer(0.01).timeout
	
	var sl = (get_node("/root/Soundline") as Soundline)
	
	$Sprite2D.visible = true
	$AnimationPlayer.play("intro")
	
	sl.play_one_shot_2D("intro", "PLAYER")
	
	await get_tree().create_timer(2.0).timeout
	
	sl.low_pass_fade_in(0.33, "Ambient")
	sl.play_one_shot_2D("sub", "PLAYER")
