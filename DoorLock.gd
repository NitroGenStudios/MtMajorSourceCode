extends Node2D
class_name Lock

@export var triggerArea : Area2D

func remove_lock():
	# enable hitbox of trigger
	triggerArea.monitoring = true
	
	# disable area
	$Area2D.monitoring = false
	
	# play animation
	$AnimationPlayer.play("unlock")



func _on_area_2d_body_entered(body):
	if (!body.is_in_group("player")):
		return
	
	# play anim
	$AnimationPlayer.stop()
	$AnimationPlayer.play("locked")
	
	# play sound
	var sl = get_node("/root/Soundline") as soundline
	sl.play_one_shot_2D("locked", "PLAYER")
