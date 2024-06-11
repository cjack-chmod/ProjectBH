extends TileMap

const MAIN_LAYER: int = 0
const MAIN_ATLAS_ID: int = 0

@export var can_click_tile: bool = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and can_click_tile:
		# If LMB Pressed
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# Finds local position of mouse
			var _global_clicked: Vector2 = get_local_mouse_position()
			# Translates to which map coord it is in
			var _pos_clicked: Vector2 = local_to_map(to_local(_global_clicked))
			print(_pos_clicked)
			# Emitting Spawn Building Signal at Centre Target Tile
			var _global_tile_pos: Vector2 = map_to_local(to_global(_pos_clicked))
			GlobalEvents.emit_spawn_building(_global_tile_pos)

			# Calling toggle cell colour fnc
			_toggle_alt_cell(_pos_clicked)


func _toggle_alt_cell(_pos_clicked: Vector2) -> void:
	# Finds the cell in the atlas and its current alt
	var _current_atlas_coords: Vector2 = get_cell_atlas_coords(MAIN_LAYER, _pos_clicked)
	var _current_tile_alt: int = get_cell_alternative_tile(MAIN_LAYER, _pos_clicked)

	# Increments the alternative (loop since there can be multiple alts )
	if _current_tile_alt > -1:
		var _number_of_alts_for_clicked: int = (
			tile_set.get_source(MAIN_ATLAS_ID).get_alternative_tiles_count(_current_atlas_coords)
		)
		set_cell(
			MAIN_LAYER,
			_pos_clicked,
			MAIN_ATLAS_ID,
			_current_atlas_coords,
			(_current_tile_alt + 1) % _number_of_alts_for_clicked
		)
