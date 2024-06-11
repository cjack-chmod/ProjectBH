extends Control


func _ready() -> void:
	GlobalEvents.player_health_changed.connect(_update_health_bar)


func _on_toggle_player_movement_pressed() -> void:
	GlobalEvents.emit_toggle_player_movement_mode()


func _update_health_bar(_current_health: float, _max_health: float) -> void:
	$ProgressBar.max_value = _max_health
	$ProgressBar.value = _current_health
