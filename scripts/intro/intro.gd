extends Node2D

@onready var static_audio: AudioStreamPlayer = %StaticAudio

func _next_scene():
  SceneManager.change_scene("res://tutorial.tscn")
