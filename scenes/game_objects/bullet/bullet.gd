extends CharacterBody2D

####################################################
# Cals Comment
# This script deals with all bullet related code after
#they have been spawned and made one initial jump
####################################################

# Setting up variables to be used for jumps
var tile_map: TileMap
var bullet_tween_weight: float = 0.15
var last_dir: GlobalTileFunctions.HEXDIR
var _current_tile: Vector2i
var _ready_for_jump: bool = false


# Connecting jump signal
func _ready() -> void:
	GlobalEvents.bullet_jump.connect(_bullet_jump)


# function that passes dmg to player
func _on_hurt_box_body_entered(body: Node2D) -> void:
	# function to damage on a collision
	if body.has_method("take_damage"):
		body.take_damage(10.0)
		call_deferred("queue_free")


func _on_timer_timeout() -> void:
	# destroys bullet if timed out (to prevent lag)
	call_deferred("queue_free")


# I dont remember what this logic here is but it breaks without it
# refactor out later
func _on_hex_start_timer_timeout() -> void:
	_current_tile = GlobalTileFunctions.find_tile_coordinates(self.global_position, tile_map)
	GlobalTileFunctions.move_to_tile_centre(self, _current_tile, tile_map, 0.01)
	_ready_for_jump = true


# this function orchestrates each jump, finds new dir based on old,
#finds what square that is, then moves to that square
func _bullet_jump() -> void:
	if _ready_for_jump:
		_ready_for_jump = false
		_current_tile = GlobalTileFunctions.find_tile_coordinates(global_position, tile_map)
		var _new_dir: GlobalTileFunctions.HEXDIR = _find_next_dir(last_dir)
		var _next_tile: Vector2i = GlobalTileFunctions.find_adjacent_tile(
			_current_tile, _new_dir, tile_map
		)
		GlobalTileFunctions.move_to_tile_centre(self, _next_tile, tile_map, bullet_tween_weight)
		_ready_for_jump = true
		last_dir = _new_dir


# Basic probablity of forward and +- 1 to the left
# we would want to expand to make cool patterns
func _find_next_dir(_last_dir: GlobalTileFunctions.HEXDIR) -> GlobalTileFunctions.HEXDIR:
	# Choosing next choice of bullet
	var _choice: Array[GlobalTileFunctions.HEXDIR] = []

	if _last_dir == GlobalTileFunctions.HEXDIR.UP:
		_choice = [
			GlobalTileFunctions.HEXDIR.UP,
			GlobalTileFunctions.HEXDIR.LEFT_UP,
			GlobalTileFunctions.HEXDIR.RIGHT_UP
		]
	elif _last_dir == GlobalTileFunctions.HEXDIR.DOWN:
		_choice = [
			GlobalTileFunctions.HEXDIR.DOWN,
			GlobalTileFunctions.HEXDIR.RIGHT_DOWN,
			GlobalTileFunctions.HEXDIR.LEFT_DOWN
		]
	elif _last_dir == GlobalTileFunctions.HEXDIR.LEFT_DOWN:
		_choice = [
			GlobalTileFunctions.HEXDIR.DOWN,
			GlobalTileFunctions.HEXDIR.LEFT_UP,
			GlobalTileFunctions.HEXDIR.LEFT_DOWN
		]
	elif _last_dir == GlobalTileFunctions.HEXDIR.LEFT_UP:
		_choice = [
			GlobalTileFunctions.HEXDIR.LEFT_DOWN,
			GlobalTileFunctions.HEXDIR.LEFT_UP,
			GlobalTileFunctions.HEXDIR.UP
		]
	elif _last_dir == GlobalTileFunctions.HEXDIR.RIGHT_DOWN:
		_choice = [
			GlobalTileFunctions.HEXDIR.DOWN,
			GlobalTileFunctions.HEXDIR.RIGHT_DOWN,
			GlobalTileFunctions.HEXDIR.RIGHT_UP
		]
	else:
		_choice = [
			GlobalTileFunctions.HEXDIR.UP,
			GlobalTileFunctions.HEXDIR.RIGHT_DOWN,
			GlobalTileFunctions.HEXDIR.RIGHT_UP
		]

	var rand_index: int = randi() % _choice.size()
	return _choice[rand_index]
