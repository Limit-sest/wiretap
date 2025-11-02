extends "res://modules/port.gd"

signal signal_recieved(text: String, step: int)

func recieve_signal(text: String, step: int):
  signal_recieved.emit(text, step)