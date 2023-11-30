extends Area2D

const playermovement = preload("res://Scripts/PlayerMovement.gd")

@export var zoom_speed = 1.0
@export var zoom_in = 1.0
@export var zoom_out = 2.0

@export_subgroup("limits")
@export var change_limits = false
@export var bottom = 0.0
@export var top = 0.0

var camera_cache : Camera2D
var bottom_limit_cache = 0.0
var top_limit_cache = 0.0
var current_tween : Tween

var speedMult = 0.0

func _ready():
	await get_tree().create_timer(0.1).timeout
	speedMult = 1.0

func _on_body_entered(body : Node2D):
	if (!body.is_in_group("player")):
		return
	
	# get camera
	if (camera_cache == null):
		var player = body as playermovement
		camera_cache = player.camera as Camera2D
		bottom_limit_cache = camera_cache.limit_bottom
		top_limit_cache = camera_cache.limit_top
	
	if (current_tween != null && current_tween.is_running()):
		current_tween.kill()

	current_tween = create_tween()
	current_tween.set_trans(Tween.TRANS_QUAD)
	current_tween.tween_property(camera_cache, "zoom", Vector2.ONE * zoom_in, zoom_speed * speedMult)
	
	if (!change_limits):
		return
	
	camera_cache.limit_bottom = bottom
	camera_cache.limit_top = top
	
	if (speedMult == 0.0):
		camera_cache.reset_smoothing()


func _on_body_exited(body):
	if (!body.is_in_group("player")):
		return
		
	if (current_tween.is_running()):
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.set_trans(Tween.TRANS_QUAD)
	current_tween.tween_property(camera_cache, "zoom", Vector2.ONE * zoom_out, zoom_speed)
		
	if (!change_limits):
		return
	
	camera_cache.limit_bottom = bottom_limit_cache
	camera_cache.limit_top = top_limit_cache
