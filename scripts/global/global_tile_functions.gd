extends Node

enum HEXDIR { UP, DOWN, LEFT_UP, LEFT_DOWN, RIGHT_UP, RIGHT_DOWN }

@onready var tile_map: Node = get_tree().get_root().get_node("/root/Main/HexTilemap")


# Finds tile coords given a global pos
func find_tile_coordinates(_global_pos: Vector2) -> Vector2:
	return tile_map.local_to_map(tile_map.to_local(_global_pos))


# Finds the global pos of the centre of the tile given the tile coords
func find_centre_of_tile(_tile_coords: Vector2) -> Vector2:
	return tile_map.map_to_local(tile_map.to_global(_tile_coords))


# Function to find the adjacent tile based on the input hexdir adjacency
func find_adjacent_tile(_tile_coords: Vector2, _direction: HEXDIR) -> Vector2:
	# Find surrounding cells
	var _surrounding_cells: Array[Vector2i] = tile_map.get_surrounding_cells(_tile_coords)
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
