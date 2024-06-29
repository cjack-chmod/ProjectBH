extends Node

@export var player_bullet_speed: float = 200.0

@onready var _bullet: PackedScene = preload("res://scenes/player/PlayerBullet.tscn")
@onready var _player: CharacterBody2D = get_parent()


func _ready() -> void:
	GlobalEvents.player_shoot.connect(shoot_bullet)


func shoot_bullet(_vel: Vector2) -> void:
	$ShootSFX.play()
	var _scene: Node2D = _bullet.instantiate()
	self.add_child(_scene)
	_scene.global_position = _player.global_position
	_scene.velocity = _vel * player_bullet_speed
