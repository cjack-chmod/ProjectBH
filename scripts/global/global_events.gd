extends Node

#####################################
# Building Signals
#####################################
signal spawn_building(tilemap_coords: Vector2)

#####################################
# Player Signals
#####################################
signal toggle_player_movement_mode


#####################################
# Building Emit Signal Functions
#####################################
func emit_spawn_building(_tilemap_coords: Vector2) -> void:
	spawn_building.emit(_tilemap_coords)


#####################################
# Player Emit Signal Functions
#####################################
func emit_toggle_player_movement_mode() -> void:
	toggle_player_movement_mode.emit()
