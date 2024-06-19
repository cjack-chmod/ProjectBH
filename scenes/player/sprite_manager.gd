extends Sprite2D
# Modulates sprite color to white [0,1], where 1 is completely white, 0 is default color
@export var sprite_flash_intensity: float = 0

func _set_sprite_flash_intensity(intensity: float) -> void:
	material.set("shader_parameter/intensity", sprite_flash_intensity)