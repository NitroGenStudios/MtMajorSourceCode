extends Node2D

var game_state = 0

var _lobby_pos : Vector2

var _current_level = "lobby"
var current_lobby : Lobby
var ui : GameUI

var ingame_time = 0.0
var global_deaths = 0

var jump_enabled = false
var wall_enabled = false
var complex_enabled = false
var wall_complex_enabled = false

const transition = preload("res://Prefabs/transition.tscn")
const surface_transition = preload("res://Prefabs/slow_transition.tscn")
const slow_transition = preload("res://Prefabs/slow_transition.tscn")
const scene_path = "res://Scenes/"

var sl : soundline

var _is_loading = false

func _ready():
	sl = get_node("/root/Soundline") as soundline
	load_game()

func save_lobby_position(pos : Vector2):
	_lobby_pos = pos

func set_current_level(level):
	current_lobby = level
	_current_level = level.name

func get_lobby_position() -> Vector2:
	return _lobby_pos

func  get_current_lobby() -> Lobby:
	return current_lobby

func get_current_level() -> String:
	return _current_level

func start_music(music_name : String):
	sl.music_fade_out(0.45)
	sl.low_pass_fade_in(0.5, "Music")
	await get_tree().create_timer(0.5).timeout
	sl.music_set(music_name, "MUSIC", true)
	sl.music_start()

func update_state():
	match game_state:
		1: # in major
			sl.low_pass_fade_in(0.5, "Music")
			await get_tree().create_timer(0.5).timeout
			sl.music_set("major", "MUSIC", true)
			sl.music_start()
		2: # after major, in lobby
			save_game()
			sl.low_pass_fade_in(1.0, "Ambient")
		3: # in lydian
			start_music("lydian")
		4: # after lydian in lobby
			save_game()
			sl.low_pass_fade_in(1.0, "Ambient")
		5: # in mixolydian
			start_music("mixolydian")
		6: # after mixolydian in lobby
			save_game()
			sl.low_pass_fade_in(1.0, "Ambient")
		7: # in dorian
			start_music("dorian")
		8: # after dorian in lobby
			save_game()
			sl.low_pass_fade_in(1.0, "Ambient")
		9: # in aeolian
			start_music("aeolian")
		10: # after aeolian in lobby
			save_game()
			sl.low_pass_fade_in(1.0, "Ambient")
		11: # in phrygian
			start_music("phrygian")
		12: # after phrygian in lobby
			save_game()
			sl.low_pass_fade_in(1.0, "Ambient")
		13: # in locrian
			start_music("locrian")
		14: # surface
			pass # handled elsewhere

func increment_state():
	game_state += 1
	update_state()
	
func load_level(next_level, level_root, increment : bool):
	if (_is_loading):
		return
	
	_is_loading = true
	
	# spawn transition
	var transition_scene = transition.instantiate()
	call_deferred("add_child", transition_scene)
	
	if (increment && _current_level == "lobby"):
		sl.play_one_shot_2D("riser", "MUSIC")
	else:
		sl.low_pass_fade_out(0.75, 200.0, "Ambient")
		sl.low_pass_fade_out(0.75, 200.0, "Music")
	
	await get_tree().create_timer(0.9).timeout
	
	# save stats
	if (_current_level != next_level):
		ui.save_stats()
		ui.reset_stats()
	
	if (increment):
		increment_state()
	
	# spawn new scene
	var instanced_scene = load(scene_path + next_level + ".tscn").instantiate()
	call_deferred("add_child", instanced_scene)

	# set stuff
	_current_level = next_level
	current_lobby = instanced_scene as Lobby
	
	# delete old scene
	level_root.queue_free()
	_is_loading = false
	
	# set UI level name
	ui.set_level_name(current_lobby.level_name)
	
	await get_tree().create_timer(0.5).timeout
	
	if (!increment && _current_level != "lobby"):
		sl.low_pass_fade_in(2.0, "Music")
	
	sl.low_pass_fade_in(2.0, "Ambient")	



func load_surface(next_level, level_root):
	if (_is_loading):
		return
	
	_is_loading = true
	
	# spawn transition
	var transition_scene = surface_transition.instantiate()
	call_deferred("add_child", transition_scene)
	
	sl.low_pass_fade_out(1.0, 200.0, "Ambient")
	sl.low_pass_fade_out(1.0, 200.0, "Music")
	
	await get_tree().create_timer(2.0).timeout
	
	sl.music_fade_out(3.0)

	#increment_state()
	
	# spawn new scene
	var instanced_scene = load(scene_path + next_level + ".tscn").instantiate()
	call_deferred("add_child", instanced_scene)
	
	# save stats
	ui.save_stats()
	ui.reset_stats()
	
	# set stuff
	_current_level = next_level
	current_lobby = instanced_scene as Lobby
	
	# delete old scene
	level_root.queue_free()
	_is_loading = false
	
	await get_tree().create_timer(6.0).timeout
	
	sl.music_set("surface", "MUSIC", true)
	sl.music_start()
	sl.low_pass_fade_in(2.0, "Music")
	sl.low_pass_fade_in(2.0, "Ambient")

func save_game():
	var save_dict = {
		"game_state" : game_state,
		"ingame_time" : ingame_time,
		"global_deaths" : global_deaths,
		"jump_enabled" : jump_enabled,
		"wall_enabled" : wall_enabled,
		"complex_enabled" : complex_enabled,
		"wall_complex_enabled" : wall_complex_enabled,
		"lobby_pos.x" : _lobby_pos.x,
		"lobby_pos.y" : _lobby_pos.y
	}
	
	var sound_dict = {
		"master" : ui.master.value,
		"music" : ui.music.value,
		"sfx" : ui.sfx.value
	}
	
	var json_string = JSON.stringify(save_dict)
	var sound_json_string = JSON.stringify(sound_dict)
	
	# save
	FileAccess.open("user://mtmajor.save", FileAccess.WRITE).store_line(json_string)
	FileAccess.open("user://mtmajor_sound.save", FileAccess.WRITE).store_line(sound_json_string)
	print("saved game!")

func load_game():
	if (FileAccess.file_exists("user://mtmajor.save")):
		var json_string = FileAccess.open("user://mtmajor.save", FileAccess.READ).get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		var data = json.get_data()
		
		game_state = data["game_state"]
		ingame_time = data["ingame_time"]
		global_deaths = data["global_deaths"]
		jump_enabled = data["jump_enabled"]
		wall_enabled = data["wall_enabled"]
		complex_enabled = data["complex_enabled"]
		wall_complex_enabled = data["wall_complex_enabled"]
		_lobby_pos.x = data["lobby_pos.x"]
		_lobby_pos.y = data["lobby_pos.y"]
	
	if (!FileAccess.file_exists("user://mtmajor_sound.save")):
		print("no sound save data found!")
		return
	
	await get_tree().create_timer(0.01).timeout
	
	var sound_json_string = FileAccess.open("user://mtmajor_sound.save", FileAccess.READ).get_line()
	var sound_json = JSON.new()
	var sound_parse_result = sound_json.parse(sound_json_string)
	
	var sound_data = sound_json.get_data()
	ui.master.value = sound_data["master"]
	ui.music.value = sound_data["music"]
	ui.sfx.value = sound_data["sfx"]

func reset_save():
	DirAccess.remove_absolute("user://mtmajor.save")
	
	
