extends CharacterBody2D

var speed: float = 250.0
var can_free_move: bool = false
var tile_map: TileMap
var last_dir: GlobalTileFunctions.HEXDIR
var _current_tile: Vector2i
var _ready_for_jump: bool = false


func _ready() -> void:
	GlobalEvents.bullet_jump.connect(_bullet_jump)


func _physics_process(_delta: float) -> void:
	if velocity != Vector2.ZERO:
		move_and_slide()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	# function to damage on a collision
	if body.has_method("take_damage"):
		body.take_damage(10.0)
		call_deferred("queue_free")


func _on_timer_timeout() -> void:
	# destroys bullet if timed out (to prevent lag)
	call_deferred("queue_free")


func _on_hex_start_timer_timeout() -> void:
	if !can_free_move:
		velocity = Vector2.ZERO
		_current_tile = GlobalTileFunctions.find_tile_coordinates(self.global_position, tile_map)
		_move_to_tile_centre(_current_tile, 0.01)
		_ready_for_jump = true


# function that takes a tile coord and moves player to centre of tile
func _move_to_tile_centre(_tile_coords: Vector2i, _tween_weight: float) -> void:
	# finding centre of tile to set
	var _new_position: Vector2 = GlobalTileFunctions.find_centre_of_tile(_tile_coords, tile_map)

	# tweening position
	var _tween: Tween = get_tree().create_tween()
	_tween.tween_property(self, "global_position", _new_position, _tween_weight)
	await _tween.finished
	_ready_for_jump = true


func _bullet_jump() -> void:
	if _ready_for_jump:
		_ready_for_jump = false
		_current_tile = GlobalTileFunctions.find_tile_coordinates(global_position, tile_map)
		# this signal orchestrates each jump, finds new dir based on old,
		#finds what square that is, then moves to that square
		var _new_dir: GlobalTileFunctions.HEXDIR = _find_next_dir(last_dir)
		var _next_tile: Vector2i = _find_new_tile(_new_dir)
		_move_to_tile_centre(_next_tile, 0.15)


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


func _find_new_tile(_new_dir: GlobalTileFunctions.HEXDIR) -> Vector2i:
	# finding adjacent tile based on direction
	return GlobalTileFunctions.find_adjacent_tile(_current_tile, _new_dir, tile_map)
