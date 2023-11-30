extends Polygon2D

@onready var level_root = $".."
const transition = preload("res://Prefabs/transition.tscn")

@export var next_level = "lvl_0"
const scene_path = "res://Scenes/"

@export var set_jump_enabled = false
@export var set_wall_enabled = false
@export var set_complex_enabled = false
@export var set_wall_complex_enabled = false

func _on_hitbox_body_entered(body):
	if (!body.is_in_group("player")):
		return
	
	# get gamecontroller
	var game_c = get_node("/root/GameController") as GameController
	game_c.ui.pause()
	
	# load level
	if (next_level == "lobby"):
		game_c.load_level(next_level, level_root, true)
	elif (next_level == "surface"):
		game_c.load_surface(next_level, level_root)
	else:
		game_c.load_level(next_level, level_root, false)
	
	# set game variables
	game_c.jump_enabled = true if set_jump_enabled else game_c.jump_enabled
	game_c.wall_enabled = true if set_wall_enabled else game_c.wall_enabled
	game_c.complex_enabled = true if set_complex_enabled else game_c.complex_enabled
	game_c.wall_complex_enabled = true if set_wall_complex_enabled else game_c.wall_complex_enabled
