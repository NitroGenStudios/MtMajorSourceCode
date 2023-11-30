extends Node

@export var destroy_node : Node
@export var duration : float

func _ready():
	await get_tree().create_timer(duration).timeout
	
	destroy_node.queue_free()

