extends "res://modules/port.gd"

var next_node

func _on_send_signal(text: String, step: int) -> void:
	next_node.recieve_signal(text, step)
