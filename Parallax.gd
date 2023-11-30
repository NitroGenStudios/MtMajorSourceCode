extends Node2D

@export var camera : Node2D

func _process(delta):
	position.y = ((camera.global_position.y - 185.0) / 8.0) - 1000.0
