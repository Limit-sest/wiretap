extends Control

signal send_signal(text: String, step: int)

func _on_signal_recieved(text: String, step: int) -> void:
	send_signal.emit(text, step + 1)
