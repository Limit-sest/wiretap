extends TextureButton

func _on_pressed() -> void:
	WiringManager.start_wire(self)
