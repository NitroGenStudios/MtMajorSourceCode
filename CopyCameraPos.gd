extends Node2D


var basePosition = position
var baseCameraY = 0

var parallax = 0.9

@export var player : Player

func _ready():
	baseCameraY = player.camera.get_screen_center_position().y

func _process(_delta):
	position = basePosition + Vector2(0, player.camera.get_screen_center_position().y * parallax - baseCameraY)
