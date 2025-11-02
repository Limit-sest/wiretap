extends Area2D

func _on_input_event(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		WiringManager.start_wire(self)
