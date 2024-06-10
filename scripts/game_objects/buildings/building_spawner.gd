extends Node


func _ready() -> void:
	# Connecting signal
	GlobalEvents.spawn_building.connect(_spawn_building)


# Function to spawn building at target location
func _spawn_building(_pos: Vector2) -> void:
	# For now just preloads the one building type
	var _building: PackedScene = preload("res://scenes/game_objects/towers/ExampleTower.tscn")

	# TODO add in some logic to check if one already exists
	if true:
		var _scene: StaticBody2D = _building.instantiate()
		self.add_child(_scene)
		_scene.global_position = _pos

		print("hello")

		print("goodbye")
