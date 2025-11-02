extends Node2D

@export var antenna: Node
@export var display: Node

func _ready():
	await get_tree().process_frame
	var antenna_output = antenna.find_child("Output")
	var display_input = display.find_child("Input")
	WiringManager.create_wire(antenna_output, display_input)

