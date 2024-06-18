extends CharacterBody2D

# Health Variables
var _max_health: float = 100.0
var _current_health: float = 100.0

# Movement Variables
var _move_speed: float = 250.0

# Flags
var _free_move: bool = true
var _hex_input_paused: bool = false

@onready var tile_map: TileMap = get_parent().get_node("HexTilemap")


func _ready() -> void:
	GlobalEvents.toggle_player_movement_mode.connect(_toggle_movement)
	_current_health = _max_health
	GlobalEvents.emit_player_health_changed(_current_health, _max_health)


# Input Function To Call Movement Function When Relevant Movement Key is pressed in hex based mode
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


func _physics_process(_delta: float) -> void:
	# Free movement code
	if _free_move:
		# Find Direction of Player Input
		var _move_input: Vector2 = Input.get_vector("left", "right", "up", "down")
		# Move Player
		velocity = _move_input * _move_speed
		move_and_slide()
	else:
		pass


func _toggle_movement() -> void:
	# Code to set player to locked in centre of tile
	if _free_move:
		# toggling flag
		_free_move = false

		# Setting vel to 0
		velocity = Vector2.ZERO

		# finding current tile
		var _current_tile_coords: Vector2 = GlobalTileFunctions.find_tile_coordinates(
			self.global_position, tile_map
		)

		# Moving to new tile
		_move_to_tile_centre(_current_tile_coords, 0.2)

	# Code to unlock Player to free movement
	else:
		_free_move = true


# function that takes a tile coord and moves player to centre of tile
func _move_to_tile_centre(_tile_coords: Vector2, _tween_weight: float) -> void:
	# print(_tile_coords)
	_hex_input_paused = true

	# finding centre of tile to set
	var _new_position: Vector2 = GlobalTileFunctions.find_centre_of_tile(_tile_coords, tile_map)

	# tweening position
	var _tween: Tween = get_tree().create_tween()
	_tween.tween_property(self, "global_position", _new_position, _tween_weight)
	await _tween.finished

	_hex_input_paused = false


# Function to find and move to the adjacent tile to the player given just direction
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


func _damage_flash() -> void:
	# Flashing Char Red When Being Damaged
	$ColorRect.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	$ColorRect.modulate = Color.WHITE


# reload if die
func _die() -> void:
	get_tree().call_deferred("reload_current_scene")
