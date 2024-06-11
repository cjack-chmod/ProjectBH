extends Control


func _on_toggle_player_movement_pressed() -> void:
	GlobalEvents.emit_toggle_player_movement_mode()
