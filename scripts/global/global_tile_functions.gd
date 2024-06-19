extends Node

####################################################
# Cals Comment
# This script defines a bunch of common variables and functions for use on the tile map grid
####################################################

# enum of the 6 possible hex directions
enum HEXDIR { UP, DOWN, LEFT_UP, LEFT_DOWN, RIGHT_UP, RIGHT_DOWN }

# Array of the hex dirs to order in an array (this can get reworked at some point)
var hex_dirs: Array[GlobalTileFunctions.HEXDIR] = [
	GlobalTileFunctions.HEXDIR.DOWN,
	GlobalTileFunctions.HEXDIR.UP,
	GlobalTileFunctions.HEXDIR.RIGHT_UP,
	GlobalTileFunctions.HEXDIR.RIGHT_DOWN,
	GlobalTileFunctions.HEXDIR.LEFT_DOWN,
	GlobalTileFunctions.HEXDIR.LEFT_UP
]


# Finds tile coords given a global pos
func find_tile_coordinates(_global_pos: Vector2, _tile_map: TileMap) -> Vector2:
	return _tile_map.local_to_map(_tile_map.to_local(_global_pos))


# Finds the global pos of the centre of the tile given the tile coords
func find_centre_of_tile(_tile_coords: Vector2, _tile_map: TileMap) -> Vector2:
	return _tile_map.map_to_local(_tile_map.to_global(_tile_coords))


# Function to find the adjacent tile based on the input hexdir adjacency
func find_adjacent_tile(_tile_coords: Vector2, _direction: HEXDIR, _tile_map: TileMap) -> Vector2:
	# Find surrounding cells
	var _surrounding_cells: Array[Vector2i] = _tile_map.get_surrounding_cells(_tile_coords)
	# return correct one based on direction
	if _direction == HEXDIR.UP:
		return _surrounding_cells[4]
	if _direction == HEXDIR.DOWN:
		return _surrounding_cells[1]
	if _direction == HEXDIR.LEFT_UP:
		return _surrounding_cells[3]
	if _direction == HEXDIR.LEFT_DOWN:
		return _surrounding_cells[2]
	if _direction == HEXDIR.RIGHT_UP:
		return _surrounding_cells[5]
	if _direction == HEXDIR.RIGHT_DOWN:
		return _surrounding_cells[0]

	# else return same
	return _tile_coords


# move to centre of the tile given the new tiles coords, and other necessary params
func move_to_tile_centre(
	object: Node2D, _tile_coords: Vector2i, _tile_map: TileMap, _tween_weight: float
) -> void:
	# finding centre of tile to set
	var _new_position: Vector2 = find_centre_of_tile(_tile_coords, _tile_map)

	# tweening position
	var _tween: Tween = get_tree().create_tween()
	_tween.tween_property(object, "global_position", _new_position, _tween_weight)
	await _tween.finished
