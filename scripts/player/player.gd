extends CharacterBody2D

####################################################
# Cals Comment
# Code in this script is used for the player
# It controls the two different movement states based on this flag "_free_move"
# Also toggles the movement state based on connected signals from the buttons in place_holder_ui.gd
####################################################

# Bullet timing
@export var timed_bullet_spawn_interval: float = 1.5
@export var player_can_shoot_with_mouse: bool = true
@export var player_shots_per_turn: int = 2

# Health Variables
var _max_health: float = 100.0
var _current_health: float = 100.0
var _player_shots_per_turn_remaining: float = player_shots_per_turn

# Movement Variables
var _move_speed: float = 250.0

# Flags
var _free_move: bool = true
var _hex_input_paused: bool = false
var _bullets_jump_with_player: bool = false

# gets the tile map of the current scene (want a better way to do this in the future)
@onready var tile_map: TileMap = get_parent().get_node("HexTilemap")


func _ready() -> void:
	# Connecting events so toggle buttons work
	GlobalEvents.toogle_bullet_shoot_mode.connect(_set_hex_shoot_flags)
	GlobalEvents.toggle_player_movement_mode.connect(_toggle_movement)

	# Setting current health and UI bar
	_current_health = _max_health
	GlobalEvents.emit_player_health_changed(_current_health, _max_health)

	# Starts the bullet timer since that is the default mode
	$BulletJumpTimer.wait_time = timed_bullet_spawn_interval


# Input Function To Call Movement Function When Relevant Movement Key is pressed in hex based mode
# Definitely want to refactor this a bit smarter
func _input(_event: InputEvent) -> void:
	# hex based mode only
	if !_free_move and !_hex_input_paused:
		if Input.is_action_just_pressed("up"):
			_find_and_move_to_adjacent_tile(GlobalTileFunctions.HEXDIR.UP)
		elif Input.is_action_just_pressed("down"):
			_find_and_move_to_adjacent_tile(GlobalTileFunctions.HEXDIR.DOWN)
		elif Input.is_action_just_pressed("left"):
			_find_and_move_to_adjacent_tile(GlobalTileFunctions.HEXDIR.LEFT_DOWN)
		elif Input.is_action_just_pressed("left_up"):
			_find_and_move_to_adjacent_tile(GlobalTileFunctions.HEXDIR.LEFT_UP)
		elif Input.is_action_just_pressed("right"):
			_find_and_move_to_adjacent_tile(GlobalTileFunctions.HEXDIR.RIGHT_DOWN)
		elif Input.is_action_just_pressed("right_up"):
			_find_and_move_to_adjacent_tile(GlobalTileFunctions.HEXDIR.RIGHT_UP)

	# If mouse button and can shoot
	if _event is InputEventMouseButton and player_can_shoot_with_mouse:
		# If LMB Pressed
		if _event.button_index == MOUSE_BUTTON_LEFT and _event.is_pressed():
			# find vector from player to mouse and emits the shoot signal with that
			var _dir: Vector2 = (get_global_mouse_position() - self.global_position).normalized()

			# If player is in free move or bullets jump with player and has some remaining
			if !_bullets_jump_with_player or _player_shots_per_turn_remaining > 0:
				_player_shots_per_turn_remaining -= 1
				GlobalEvents.emit_player_shoot(_dir)


# Applies velocity if player can free move
func _physics_process(_delta: float) -> void:
	# Free movement code
	if _free_move:
		# Find Direction of Player Input
		var _move_input: Vector2 = Input.get_vector("left", "right", "up", "down")
		# Move Player
		velocity = _move_input * _move_speed
		move_and_slide()


func _toggle_movement() -> void:
	# Reset shot count
	_player_shots_per_turn_remaining = player_shots_per_turn

	# Code to set player to locked in centre of tile
	if _free_move:
		# Setting vel to 0
		velocity = Vector2.ZERO

		# finding current tile
		var _current_tile_coords: Vector2 = GlobalTileFunctions.find_tile_coordinates(
			self.global_position, tile_map
		)

		# Moving to new tile
		_move_to_tile_centre(_current_tile_coords, 0.2)

	# Toggles Flag
	_free_move = !_free_move


# function that takes a tile coord and moves player to centre of tile
func _move_to_tile_centre(_tile_coords: Vector2, _tween_weight: float) -> void:
	# Pauses movement input while moving
	_hex_input_paused = true

	# Calls global move function
	GlobalTileFunctions.move_to_tile_centre(self, _tile_coords, tile_map, _tween_weight)

	# Allows movement again
	_hex_input_paused = false


# Function to find and move to the adjacent tile to the player given just direction
# This is called whenever a qweasd key input is registered while in hex jump movement mode
func _find_and_move_to_adjacent_tile(_direction: GlobalTileFunctions.HEXDIR) -> void:
	# Finding Current Player Tile
	var _current_tile: Vector2 = GlobalTileFunctions.find_tile_coordinates(
		self.global_position, tile_map
	)

	# finding adjacent tile based on direction
	var _new_tile: Vector2 = GlobalTileFunctions.find_adjacent_tile(
		_current_tile, _direction, tile_map
	)

	# moving to centre of that tile
	_move_to_tile_centre(_new_tile, 0.3)

	# Emit signal for bullet jump if in that mode and reset shot count
	if _bullets_jump_with_player:
		_player_shots_per_turn_remaining = player_shots_per_turn
		GlobalEvents.emit_bullet_jump()


# Minus Health and die if less than 0
func take_damage(_damage: float) -> void:
	_current_health -= _damage

	# visual and sound
	_damage_flash()
	if !$HurtSound.playing:
		$HurtSound.play()

	GlobalEvents.emit_player_health_changed(_current_health, _max_health)
	if _current_health <= 0:
		_die()


# flashes player sprite
func _damage_flash() -> void:
	# Flashing Char Red When Being Damaged
	$ColorRect.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	$ColorRect.modulate = Color.WHITE


# reload if die
func _die() -> void:
	await get_tree().create_timer(0.2).timeout
	get_tree().call_deferred("reload_current_scene")


# Timer that makes the bullets jump if in timed mode
func _on_bullet_jump_timer_timeout() -> void:
	if !_bullets_jump_with_player:
		GlobalEvents.emit_bullet_jump()


# Function to manage flags when hex shoot button is toggled
func _set_hex_shoot_flags() -> void:
	# reset shooting flags
	_player_shots_per_turn_remaining = player_shots_per_turn

	if !_free_move:
		_bullets_jump_with_player = !_bullets_jump_with_player

	# Setting Timer to play if in time based hex mode
	if !_bullets_jump_with_player:
		$BulletJumpTimer.start()
	else:
		$BulletJumpTimer.stop()
