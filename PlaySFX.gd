extends Node

@export var bank_name = "bank_name"
@export var sound_name = "sound_name"

func _ready():
	var sl = get_node("/root/Soundline") as soundline
	sl.play_one_shot_2D(sound_name, bank_name)
