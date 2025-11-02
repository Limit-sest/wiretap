extends Area2D

func _on_pressed() -> void:
	WiringManager.start_wire(self)
