extends TileMap

const main_layer : int = 0
const main_atlas_id : int= 0

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		# If LMB Pressed
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# Finds local position of mouse
			var global_clicked : Vector2 = get_local_mouse_position()
			# Translates to which map coord it is in
			var pos_clicked : Vector2 = local_to_map(to_local(global_clicked))

			# Finds the cell in the atlas and its current alt
			var current_atlas_coords : Vector2 = get_cell_atlas_coords(main_layer, pos_clicked)
			var current_tile_alt : int = get_cell_alternative_tile(main_layer, pos_clicked)

			# Increments the alternative (loop since there can be multiple alts )
			if current_tile_alt > -1:
				var number_of_alts_for_clicked : int = tile_set.get_source(main_atlas_id)\
						.get_alternative_tiles_count(current_atlas_coords)
				set_cell(main_layer, pos_clicked, main_atlas_id, current_atlas_coords, 
						(current_tile_alt + 1) %  number_of_alts_for_clicked)