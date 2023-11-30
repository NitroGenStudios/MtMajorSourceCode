extends Node2D

@export var state := 0
@export var node : Resource

func _ready():
	if ((get_node("/root/GameController") as GameController).game_state == state):
		add_child(node.instantiate())
