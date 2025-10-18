extends Node2D

@onready var initial_node = %Anthenna/Output
@onready var encoded_string = CipherUtils.encode_random("Hello world")

func _get_linked_port(first_port: Area2D): # Get output port in the same module
	var parent = first_port.get_parent()
	print(parent.name)
	return parent.find_child("Output")

func _get_next_port(output_port: Area2D): # Get connected port with wire
	for connection in WiringManager.connections:
		if connection[1] == output_port:
			return connection[0]

func _on_signal_send_timeout() -> void:
	var current_node = initial_node
	var working_string = encoded_string
	while true:
		var next_node = _get_next_port(current_node)
		if !next_node: break
		current_node = _get_linked_port(next_node)
		if !current_node: break
	
	print(working_string)
