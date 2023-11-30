extends CanvasLayer
class_name GameUI

@onready var control = $Control
@onready var deaths_text = $Control/MarginContainer/VBoxContainer/HBoxContainer2/deaths
@onready var timer_text = $Control/MarginContainer/VBoxContainer2/HBoxContainer/timer
@onready var levelname_text = $Control/MarginContainer/VBoxContainer/HBoxContainer/levelname

@onready var finaltime_text = $EndUI/MarginContainer/CenterContainer/VBoxContainer/finaltime
@onready var totaldeaths_text = $EndUI/MarginContainer/CenterContainer/VBoxContainer/totaldeaths

@onready var pause_menu = $PauseMenu
@onready var puase_time_text = $PauseMenu/CenterContainer/VBoxContainer/time
@onready var pause_deaths_text = $PauseMenu/CenterContainer/VBoxContainer/deaths

@onready var master = $PauseMenu/CenterContainer/VBoxContainer/master
@onready var music = $PauseMenu/CenterContainer/VBoxContainer/music
@onready var sfx = $PauseMenu/CenterContainer/VBoxContainer/sfx


var is_running = false
var deaths = 0
var timer = 0.0
var is_paused = false

var game_c : GameController
var sl : soundline

func _ready():
	game_c = get_node("/root/GameController") as GameController
	game_c.ui = self
	
	sl = get_node("/root/Soundline") as soundline

func _process(delta):
	if (is_running):
		timer += delta

	deaths_text.text = "%d" % [deaths + 1]
	timer_text.text = _format_to_time(timer)
	
	if (Input.is_action_just_pressed("pause") && !game_c._is_loading):
		is_paused = !is_paused
		
		if (is_paused):
			AudioServer.get_bus_effect(0, 0).cutoff_hz = 300
			pause_menu.visible = true
			pause_deaths_text.text = "Deaths: %d" % (game_c.global_deaths + deaths)
			puase_time_text.text = "Time: %s" % _format_to_time(game_c.ingame_time + timer)
			Engine.time_scale = 0.0
		else:
			AudioServer.get_bus_effect(0, 0).cutoff_hz = 20500
			pause_menu.visible = false
			Engine.time_scale = 1.0

func _format_to_time(t) -> String:
	var minutes = t / 60
	var seconds = fmod(t, 60)
	var milliseconds = fmod(t, 1) * 100
	
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func set_level_name(n : String):
	levelname_text.text = n

func start():
	is_running = true
	show_ui()

func pause():
	is_running = false

func add_death():
	deaths += 1

func reset_stats():
	deaths = 0
	timer = 0.0
	pause()
	hide_ui()

func show_ui():
	control.visible = true

func hide_ui():
	control.visible = false

func save_stats():
	game_c.ingame_time += timer
	game_c.global_deaths += deaths

func show_end_screen():
	finaltime_text.text = "Final time: %s" % _format_to_time(game_c.ingame_time)
	totaldeaths_text.text = "Total deaths: %d" % game_c.global_deaths
	$AnimationPlayer.play("fade_out")


func _on_master_value_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_sfx_value_changed(value):
	AudioServer.set_bus_volume_db(3, linear_to_db(value))

func _on_reset_save_data_button_down():
	game_c.reset_save()
	get_tree().quit()

func _on_quit_button_down():
	get_tree().quit()

func _on_fullscreen_toggled(button_pressed):
	if (button_pressed):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
