extends Node

@onready var tty = $Sprite2D/tty

func _on_display_send_signal(text, _step):
  tty.print_tty(text)