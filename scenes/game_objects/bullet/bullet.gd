extends CharacterBody2D

var starting_x_vel: float = 0.0
var starting_y_vel: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector2(starting_x_vel, starting_y_vel)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(10.0)
		call_deferred("queue_free")
