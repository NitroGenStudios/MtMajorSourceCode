extends Node2D
class_name Key

@export var lock : Node2D

func _on_area_2d_body_entered(body):
	if (!body.is_in_group("player")):
		return
	
	# stop animation
	$AnimationPlayer.stop()
	
	# play animation
	$AnimationPlayer.play("pickup")
	
	# disable collision
	$Area2D.set_deferred("monitoring", false)
	
	# play sound
	var sl = get_node("/root/Soundline") as soundline
	sl.play_one_shot_2D("key_pickup", "PLAYER")
	
	# unlock the lock
	var l = lock as Lock
	l.remove_lock()
