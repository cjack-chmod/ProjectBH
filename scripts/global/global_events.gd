extends Node

#####################################
# Building Signals
#####################################
signal spawn_building(tilemap_coords: Vector2)
signal toogle_bullet_shoot_mode
signal bullet_jump

#####################################
# Player Signals
#####################################
signal toggle_player_movement_mode
signal player_health_changed(_cur_health: float, _max_health: float)


#####################################
# Building Emit Signal Functions
#####################################
func emit_spawn_building(_tilemap_coords: Vector2) -> void:
	spawn_building.emit(_tilemap_coords)


func emit_toogle_bullet_shoot_mode() -> void:
	toogle_bullet_shoot_mode.emit()


func emit_bullet_jump() -> void:
	bullet_jump.emit()


#####################################
# Player Emit Signal Functions
#####################################
func emit_toggle_player_movement_mode() -> void:
	toggle_player_movement_mode.emit()


func emit_player_health_changed(_cur_health: float, _max_health: float) -> void:
	player_health_changed.emit(_cur_health, _max_health)
