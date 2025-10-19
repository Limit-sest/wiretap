extends Node2D

@onready var initial_node = %Antenna/Output
@onready var encoded_string = CipherUtils.encode_random("Hello world")

var decode_functions = {
	"Numbers": CipherUtils.decode_numbers,
	"Morse": CipherUtils.decode_morse,
	"Caesar": CipherUtils.decode_caesar
}

func _get_linked_port(first_port: Area2D): # Get output port in the same module
	var parent = first_port.get_parent()
	return [parent.find_child("Output"), parent.name]

func _get_next_port(output_port: Area2D): # Get connected port with wire
	for connection in WiringManager.connections:
		if connection[1] == output_port:
			return connection[0]

func _on_signal_send_timeout() -> void:
	var current_node = initial_node
	var working_string = encoded_string
	while true:
		var next_node = _get_next_port(current_node)
		if !next_node: 
			break
		elif next_node.get_parent().name == "Display":
			%"tty/Main panel/tty".print_tty(working_string)
		var linked_port = _get_linked_port(next_node)
		current_node = linked_port[0]
		if !current_node: break
		working_string = decode_functions[linked_port[1]].call(working_string)
	
