extends CharacterBody2D
class_name Player

@onready var camera = $Camera2D as Camera2D
@onready var springjump_particles = $"springjump particles"

const SPEED = 3000.0

const MAX_SPEED = 300.0
const LONG_JUMP_MAX_SPEED = 200.0 # add
const GLOBAL_MAX_SPEED = 700.0

const JUMP_VELOCITY_MULTIPLIER_BY_SPEED = 400.0 # divider, if max speed is higher than it, jump velocity will be higher
const JUMP_VELOCITY = -450.0
const BOOSTED_JUMP_VELOCITY = -750.0
const LONG_JUMP_VELOCITY = 10000.0

const COYOTE_TIME = 0.1
const JUMP_BUFFER = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $sprite
@onready var hitbox = $hitbox

var isTall := true
var canBoost := false
var just_jumped := false
var just_jumped_timer := 0.0
var coyote_timer := 0.0
var jump_buffer := 0.0
var walljump_timer := 0.0

var current_direction := 0.0
var current_max_speed := 0.0
var max_velocity_cap := 10000.0

var can_switch = true
@export var is_dead = false

var is_climbing_wall = false
var last_wall_normal_x = 1.0

var wall_sound_timer = 0.0

@export var override_abilities = false
@export var jump_enabled = false
@export var wall_enabled = false
@export var complex_enabled = false
@export var wall_complex_enabled = false

@export var default_camera_zoom = 1.0
@export var smooth_camera = false

var sl : soundline

func _ready():
	# reset shape size
	hitbox.shape.size = Vector2(22.5, 47.5)
	
	camera.zoom = Vector2.ONE * default_camera_zoom
	camera.reset_smoothing()
	camera.set_deferred("limit_smoothed", smooth_camera)
	current_max_speed = MAX_SPEED
	
	# get soundline
	sl = get_node("/root/Soundline") as soundline
	
	if (override_abilities):
		return
	
	# set stuff
	var game_c = get_node("/root/GameController") as GameController
	jump_enabled = game_c.jump_enabled || jump_enabled
	wall_enabled = game_c.wall_enabled || wall_enabled
	complex_enabled = game_c.complex_enabled || complex_enabled
	wall_complex_enabled = game_c.wall_complex_enabled || wall_complex_enabled

func _jump(direction : float, no_just_jump : bool):
	jump_buffer = 0.0
	coyote_timer = 0.0
	walljump_timer = 0.1
	
	if (isTall && canBoost):
		var additional_boost = 1.20 if current_max_speed >= JUMP_VELOCITY_MULTIPLIER_BY_SPEED else 1.0
		velocity.y = BOOSTED_JUMP_VELOCITY * additional_boost
		canBoost = false
		just_jumped = false
		
		if (additional_boost != 1.0):
			springjump_particles.emitting = true
			sl.play_one_shot_2D("jump", "PLAYER")
			sl.play_one_shot_2D("boostjump", "PLAYER")
		else:
			sl.play_one_shot_2D("jump", "PLAYER")
		return
	
	if (!isTall && canBoost && complex_enabled && !is_climbing_wall || !isTall && canBoost && wall_complex_enabled && is_climbing_wall):
		current_max_speed += LONG_JUMP_MAX_SPEED
		velocity.x += LONG_JUMP_VELOCITY * direction
		canBoost = false
		is_climbing_wall = false
		just_jumped = false
		sl.play_one_shot_2D("jump", "PLAYER")
		velocity.y = JUMP_VELOCITY
		return
	
	if (is_climbing_wall):
		velocity.x = SPEED * direction
		velocity.y = JUMP_VELOCITY
		is_climbing_wall = false
		just_jumped = false
		sl.play_one_shot_2D("walljump", "PLAYER")
		return
	
	sl.play_one_shot_2D("jump", "PLAYER")
	velocity.y = JUMP_VELOCITY
	
	if (!no_just_jump):
		just_jumped = true
		just_jumped_timer = 0.075
	
func _switch_between_states():
	# jump when holding space and switching while climbing the wall, also confusing
	#if (isTall && Input.is_action_pressed("jump") && is_climbing_wall):
	#	_jump(last_wall_normal_x)
	
	isTall = !isTall
	sl.play_one_shot_2D("switch", "PLAYER")

	var state_tweener = get_tree().create_tween()
	state_tweener.set_parallel(true)
	state_tweener.set_trans(Tween.TRANS_BACK)

	if (isTall):
		state_tweener.tween_property(hitbox.shape, "size", Vector2(22.5, 47.5), 0.33)
		state_tweener.tween_property(sprite, "scale", Vector2(0.5, 1.0), 0.33)
		state_tweener.tween_property(sprite, "position", Vector2(0.0, 0.0), 0.33)
	else:
		state_tweener.tween_property(hitbox.shape, "size", Vector2(47.5, 20.0), 0.33)
		state_tweener.tween_property(sprite, "scale", Vector2(1.0, 0.5), 0.33)
		state_tweener.tween_property(sprite, "position", Vector2(0.0, -2.5), 0.33)
	
	# enable boost
	if (!complex_enabled):
		return
	
	canBoost = true
	
	# coyote boosted jump
	if (just_jumped):
		print("AAA")
		_jump(Input.get_axis("left", "right"), true)
		just_jumped = false
	
	await get_tree().create_timer(0.2).timeout
	
	# disable boost
	canBoost = false

func _process(delta):
	if (is_dead):
		return
	
	coyote_timer -= delta
	jump_buffer -= delta
	just_jumped_timer -= delta
	walljump_timer -= delta
	
	if (just_jumped_timer < 0.0):
		just_jumped = false
	
	# reset coyote time
	if (is_on_floor()):
		coyote_timer = COYOTE_TIME
	
	# calculate input
	var direction = Input.get_axis("left", "right")
	
	# handle wall climbing
	if (is_on_wall_only() && wall_enabled && walljump_timer <= 0.0):
		is_climbing_wall = true
	elif (is_climbing_wall):
		is_climbing_wall = false
	
	# jump buffer when input for smoother gameplay
	if (Input.is_action_just_pressed("jump")):
		jump_buffer = JUMP_BUFFER
	
	# handle jumping
	if (jump_buffer > 0.0 && jump_enabled):
		if (is_climbing_wall && !isTall):
			# fix walljump bug, last wall normal gets out of sync sometimes and causes a no-jump
			if (get_wall_normal().x != 0.0):
				last_wall_normal_x = get_wall_normal().x
				
			_jump(last_wall_normal_x, false)
		elif (coyote_timer > 0.0):
			_jump(direction, false)
	
	# handle switching between states
	if (Input.is_action_just_pressed("switch") && can_switch):
		_switch_between_states()
	
	# handle even more state switching (confusing) 
	#if (is_climbing_wall):
	#	if (Input.is_action_pressed("down") && isTall || Input.is_action_just_pressed("up") && !isTall):
	#		_switch_between_states()
	
	# cheat xdd
	if (Input.is_action_just_pressed("cheat_enable")):
		jump_enabled = true
		wall_enabled = true
		complex_enabled = true
		wall_complex_enabled = true
	
func _physics_process(delta):
	if (is_dead):
		velocity = Vector2.ZERO
		return
	
	# add gravity
	if (!is_on_floor() && !is_climbing_wall):
		velocity.y += gravity * delta
	
	# calculate direction
	var direction = Input.get_axis("left", "right")
	
	# lerp direction for *smoothness*
	if is_on_floor():
		current_direction = lerpf(current_direction, direction, 15.0 * delta)
	else:
		current_direction = lerpf(current_direction, direction, 5.0 * delta)
	
	# lerp max speed back to reasonable levels when grounded
	if (is_on_floor()):
		current_max_speed = lerpf(current_max_speed, MAX_SPEED, 15.0 * delta)
		
		if (direction == 0.0): # deceleration
			velocity.x = move_toward(velocity.x, 0.0, SPEED * delta)
	
	# do some velocity stuff
	velocity.x += current_direction * SPEED * delta
	velocity.x = clamp(velocity.x, -current_max_speed, current_max_speed)
	
	# calculate velocity cap based on velocity
	max_velocity_cap = lerp(MAX_SPEED, GLOBAL_MAX_SPEED, abs(velocity.x) / MAX_SPEED)
	
	# clamp max speed to avoid an infinite max speed buildup with longjumps
	current_max_speed = clamp(current_max_speed, MAX_SPEED, max_velocity_cap)
	#print(current_max_speed)
	
	# handle wall climbing
	if (is_climbing_wall && wall_enabled):
		# reset max speed and velocity
		current_max_speed = MAX_SPEED
		velocity = Vector2.ZERO
		velocity.x = -get_wall_normal().x * 100.0 # this is not necessary but it's nice to have
		
		# set wall normal, make sure it's never 0.0
		if (get_wall_normal().x != 0.0):
			last_wall_normal_x = get_wall_normal().x
		
		# sound stuff
		wall_sound_timer -= delta
		
		# handle climbing Y axis
		if (isTall && (Input.is_action_pressed("jump"))): # climbing
			velocity.y = -300.0
			# play sound
			if (wall_sound_timer <= 0):
				sl.play_one_shot_2D("wallclimb", "PLAYER")
				wall_sound_timer = randf_range(0.15, 0.25)
		elif (!isTall):
			velocity.y = 200.0
			# play sound
			if (wall_sound_timer <= 0):
				sl.play_one_shot_2D("wallslide", "PLAYER")
				wall_sound_timer = randf_range(0.25, 0.35)
	
	# do the movement
	move_and_slide()
