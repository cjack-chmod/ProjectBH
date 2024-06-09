extends CharacterBody2D

var _move_speed : float = 200.0

func _physics_process(_delta : float) -> void:
	
	# Find Direction of Player Input
	var _move_input : Vector2 = Input.get_vector("left","right", "up", "down")

	# Move Player	
	velocity = _move_input * _move_speed
	move_and_slide()