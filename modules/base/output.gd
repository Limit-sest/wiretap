extends "res://modules/base/port.gd"

var next_node

func _on_send_signal(text: String, step: int) -> void:
	print("output reached")
	print(next_node)
	if next_node:
		next_node.recieve_signal(text, step)
