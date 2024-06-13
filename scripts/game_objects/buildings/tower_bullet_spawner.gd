extends StaticBody2D

# this is temporary bandaid because the tileset i was using isn't symmetrical :(
const Y_ELONGATION: float = 1  #+ (110.0 / 96.0 - 1) / 2.5 commenting out

@export var hex_shoot_interval: float = 1.2

var hex_shoot_speed: int = 475
# Bullet Scene
var _bullet: PackedScene = preload("res://scenes/game_objects/bullet/bullet.tscn")
var _bullet_speed: float = 250.0

# Hex Direction Vectors
var _hex_vel_dirs: Array[Vector2] = [
	Vector2(0, 1),
	Vector2(0, -1),
	Vector2(sin(PI / 3), cos(PI / 3) * Y_ELONGATION).normalized(),
	Vector2(sin(2 * PI / 3), cos(2 * PI / 3) * Y_ELONGATION).normalized(),
	Vector2(sin(4 * PI / 3), cos(4 * PI / 3) * Y_ELONGATION).normalized(),
	Vector2(sin(5 * PI / 3), cos(5 * PI / 3) * Y_ELONGATION).normalized()
]

@onready var tile_map: TileMap = get_parent().get_parent().get_node("HexTilemap")
@onready var rotater: Node2D = $Rotater

#############################################
# General Functions
#############################################


func _ready() -> void:
	_clear_previous_spawners()
	# Setting pos to centre of tile
	var _curr_tile: Vector2i = GlobalTileFunctions.find_tile_coordinates(
		self.global_position, tile_map
	)
	self.global_position = GlobalTileFunctions.find_centre_of_tile(_curr_tile, tile_map)

	# Connect Toggle and setup first pattern
	_setup_new_hex_pattern(hex_shoot_speed, hex_shoot_interval)
	GlobalEvents.bullet_jump.connect(_hex_shoot_shoot)


func _clear_previous_spawners() -> void:
	for s: Node2D in rotater.get_children():
		s.queue_free()


#############################################
# Hex Shoot Functions
#############################################
func _setup_new_hex_pattern(_speed: float, _shoot_interval: float) -> void:
	var _step: float = 2 * PI / 6

	# Set variables
	rotater.rotation = 0.0
	_bullet_speed = _speed

	# Creating spawn points
	for i: int in range(6):
		var _spawn_point: Node2D = Node2D.new()
		# Set Spawn Points to Centre of Hex
		var _curr_tile: Vector2i = GlobalTileFunctions.find_tile_coordinates(
			self.position, tile_map
		)
		_spawn_point.global_position = GlobalTileFunctions.find_centre_of_tile(_curr_tile, tile_map)
		rotater.add_child(_spawn_point)


func _hex_shoot_shoot() -> void:
	var i: int = 0
	for s: Node2D in rotater.get_children():
		var _scene: Node2D = _bullet.instantiate()
		_scene.can_free_move = false
		_scene.tile_map = tile_map
		get_parent().add_child(_scene)
		_scene.velocity = _bullet_speed * _hex_vel_dirs[i]
		_scene.last_dir = GlobalTileFunctions.hex_dirs[i]
		i += 1
		_scene.position = s.position
