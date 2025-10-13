extends RichTextLabel
func _ready():
	text = "Hello from the world of GDScript!"


func _on_button_pressed() -> void:
	append_text("\nStarting terminal.")
