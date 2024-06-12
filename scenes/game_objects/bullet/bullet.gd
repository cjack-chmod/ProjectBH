extends CharacterBody2D

var speed: float = 250.0
var can_free_move: bool = false


func _physics_process(_delta: float) -> void:
	if can_free_move:
		position += transform.x * speed * _delta
	else:
		move_and_slide()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	# function to damage on a collision
	if body.has_method("take_damage"):
		body.take_damage(10.0)
		call_deferred("queue_free")


func _on_timer_timeout() -> void:
	# destroys bullet if timed out (to prevent lag)
	call_deferred("queue_free")
