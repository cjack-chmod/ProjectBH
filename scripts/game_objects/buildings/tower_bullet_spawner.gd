extends StaticBody2D

# this is temporary bandaid because the tileset i was using isn't symmetrical :(
const Y_ELONGATION: float = 1 + (110.0 / 96.0 - 1) / 2.5

@export_group("Free Shoot Variables")
@export var num_spawn_points: int = 4
@export var free_shoot_speed: int = 250
@export var free_shoot_interval: float = 0.2
@export var free_shoot_rotation: float = 50.0

@export_group("Hex Shoot Variables")
@export var hex_shoot_speed: int = 300
@export var hex_shoot_interval: float = 1.0

var _rotater_free_shoot_rotate_speed: float = 100.0

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

# Flags
var _free_shoot: bool = true

@onready var tile_map: TileMap = get_parent().get_parent().get_node("HexTilemap")
@onready var shoot_timer: Timer = $ShootTimer
@onready var rotater: Node2D = $Rotater

#############################################
# General Functions
#############################################


func _ready() -> void:
	# Setting pos to centre of tile
	var _curr_tile: Vector2i = GlobalTileFunctions.find_tile_coordinates(
		self.global_position, tile_map
	)
	self.global_position = GlobalTileFunctions.find_centre_of_tile(_curr_tile, tile_map)

	# Connect Toggle and setup first pattern
	GlobalEvents.toogle_bullet_shoot_mode.connect(_toggle_shoot_mode)
	if _free_shoot:
		_setup_new_freeshoot_pattern(
			num_spawn_points, free_shoot_speed, free_shoot_interval, free_shoot_rotation
		)


# Rotating spawner in free mode
func _physics_process(delta: float) -> void:
	if _free_shoot:
		rotater.rotation_degrees += _rotater_free_shoot_rotate_speed * delta


# Code to toggle
func _toggle_shoot_mode() -> void:
	if _free_shoot:
		_free_shoot = false
		_clear_previous_spawners()
		_setup_new_hex_pattern(hex_shoot_speed, hex_shoot_interval)
	else:
		_free_shoot = true
		_clear_previous_spawners()
		_setup_new_freeshoot_pattern(
			num_spawn_points, free_shoot_speed, free_shoot_interval, free_shoot_rotation
		)


# Bullet Spawn Code
func _on_shoot_timer_timeout() -> void:
	# Code to spawn bullet and set its variables and rotation to work in free move
	if _free_shoot:
		_free_shoot_shoot()

	# Code to spawn bullet if
	else:
		_hex_shoot_shoot()


func _clear_previous_spawners() -> void:
	for s: Node2D in rotater.get_children():
		s.queue_free()


#############################################
# Free Shoot Functions
#############################################


func _setup_new_freeshoot_pattern(
	_num_spawn_points: int, _speed: float, _shoot_interval: float, _rotation: float
) -> void:
	var _step: float = 2 * PI / _num_spawn_points

	# Set variables
	_rotater_free_shoot_rotate_speed = _rotation
	_bullet_speed = _speed

	for i: int in range(_num_spawn_points):
		var _spawn_point: Node2D = Node2D.new()
		var _pos: Vector2 = Vector2(30, 0).rotated(_step * i)
		_spawn_point.position = _pos + self.position
		_spawn_point.rotation = _pos.angle()
		rotater.add_child(_spawn_point)

	shoot_timer.wait_time = _shoot_interval
	shoot_timer.start()


func _free_shoot_shoot() -> void:
	for s: Node2D in rotater.get_children():
		var _scene: Node2D = _bullet.instantiate()
		get_tree().root.add_child(_scene)
		_scene.speed = _bullet_speed
		_scene.can_free_move = true
		_scene.position = s.position
		_scene.rotation_degrees = fmod(s.rotation_degrees + rotater.rotation_degrees, 360)


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

	# Set Timer
	shoot_timer.wait_time = _shoot_interval
	shoot_timer.start()


func _hex_shoot_shoot() -> void:
	var i: int = 0
	for s: Node2D in rotater.get_children():
		var _scene: Node2D = _bullet.instantiate()
		get_tree().root.add_child(_scene)
		_scene.can_free_move = false
		_scene.velocity = _bullet_speed * _hex_vel_dirs[i]
		i += 1
		_scene.position = s.position
