extends StaticBody2D

####################################################
# Cals Comment
# This script initially spawns in the bullets to the SpawnPoint node
# then shoots them each in a different hex direction
####################################################

# Interval bullets are fired at
@export var hex_shoot_interval: float = 1.2

var hex_shoot_speed: int = 475
# Bullet Scene
var _bullet: PackedScene = preload("res://scenes/game_objects/bullet/bullet.tscn")

# Getting nodes that are needed
@onready var tile_map: TileMap = get_parent().get_parent().get_node("HexTilemap")
@onready var spawn_point: Node2D = $SpawnPoint


func _ready() -> void:
	# Clear anything previous to be safe
	_clear_previous_spawners()

	# Setting tower position to centre of tile
	var _curr_tile: Vector2i = GlobalTileFunctions.find_tile_coordinates(
		self.global_position, tile_map
	)
	self.global_position = GlobalTileFunctions.find_centre_of_tile(_curr_tile, tile_map)

	# Connect shoot first wave on start and connect jump signal for the movement controlled shooting
	_hex_shoot_shoot()
	GlobalEvents.bullet_jump.connect(_hex_shoot_shoot)


# Function to clear spawned nodes (useful for deleted towers or when reloading after death)
func _clear_previous_spawners() -> void:
	for s: Node2D in spawn_point.get_children():
		s.queue_free()


# Function that shoots a bullet in each direction
func _hex_shoot_shoot() -> void:
	# For each newly created bullet, sets their needed variables and calls a first jump
	for i: int in range(len(GlobalTileFunctions.hex_dirs)):
		# Instatiate and set vars and spawn
		var _scene: Node2D = _bullet.instantiate()
		_scene.tile_map = tile_map
		spawn_point.add_child(_scene)
		_scene.global_position = self.global_position

		# Do first jump
		_scene._current_tile = GlobalTileFunctions.find_tile_coordinates(
			_scene.global_position, tile_map
		)
		var _next_dir: GlobalTileFunctions.HEXDIR = GlobalTileFunctions.hex_dirs[i]
		var _new_tile: Vector2i = GlobalTileFunctions.find_adjacent_tile(
			_scene._current_tile, _next_dir, tile_map
		)
		GlobalTileFunctions.move_to_tile_centre(
			_scene, _new_tile, tile_map, _scene.bullet_tween_weight
		)
		_scene.last_dir = _next_dir
