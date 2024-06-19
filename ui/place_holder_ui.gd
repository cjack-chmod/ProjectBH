extends Control


# Connects signal for health change
func _ready() -> void:
	GlobalEvents.player_health_changed.connect(_update_health_bar)


# emits signal for movement toggle button
func _on_toggle_player_movement_pressed() -> void:
	GlobalEvents.emit_toggle_player_movement_mode()


# emits signal for shoot type toggle button
func _on_toggle_bullet_mode_pressed() -> void:
	GlobalEvents.emit_toogle_bullet_shoot_mode()


# Updates health ui
func _update_health_bar(_current_health: float, _max_health: float) -> void:
	$ProgressBar.max_value = _max_health
	$ProgressBar.value = _current_health
