extends Node


#####################################
# Building Signals
#####################################
signal spawn_building(tilemap_coords : Vector2)


#####################################
# Building Emit Signal Functions
#####################################
func emit_spawn_building(_tilemap_coords : Vector2) -> void:
    spawn_building.emit(_tilemap_coords)