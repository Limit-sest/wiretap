extends "res://modules/port.gd"

signal signal_recieved(text: String)

func recieve_signal(text: String):
  signal_recieved.emit(text)
  