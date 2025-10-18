extends Area2D

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("ya")
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		WiringManager.start_wire(self)
