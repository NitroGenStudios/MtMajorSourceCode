extends Node
class_name Lobby

@export var player : Node2D
@export var level_name = "1-1 Jumps"
@export var is_lobby = false
@export var bg_color : Color

@export var camera_bottom_limit = 450.0
@export var camera_top_limit = -450.0

@export var camera_right_limit = 800.0
@export var camera_left_limit = -800.0


const transition = preload("res://Prefabs/transition.tscn")
const scene_path = "res://Scenes/"

func _ready():
	var gc = get_node("/root/GameController") as GameController
	
	RenderingServer.set_default_clear_color(bg_color)
	player.camera.limit_bottom = camera_bottom_limit
	player.camera.limit_top = camera_top_limit
	player.camera.limit_left = camera_left_limit
	player.camera.limit_right = camera_right_limit
		
	
	if (gc.get_current_lobby() == null):
		gc.set_current_level(self)
	
	if (!is_lobby):
		if (name != "surface"):
			gc.ui.start()
		return
	
	gc.ui.save_stats()
	gc.ui.reset_stats()
	var pos = gc.get_lobby_position()
	
	if (pos != Vector2.ZERO):
		player.position = pos

func reset():
	var gc = get_node("/root/GameController") as GameController
	gc.load_level(gc.get_current_level(), self, false)
