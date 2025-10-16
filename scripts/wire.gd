extends Node2D

var is_drawing = false
var start_port = null

@onready var line = $Line2D
@onready var port1 = $Port1
@onready var port2 = $Port2

func _input(event):
	if is_drawing and event is InputEventMouseButton and not event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			#is_drawing = false
			#line.clear_points()

func _process(delta):
	if is_drawing:
		line.set_point_position(1, line.to_local(get_global_mouse_position()))

func handle_port_click(event: InputEvent, node) -> void:
	if event.is_pressed() and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			if not is_drawing:
				is_drawing = true
				start_port = node
				line.add_point(line.to_local(node.global_position))
				line.add_point(line.to_local(get_global_mouse_position()))
			else:
				if start_port == node:
					is_drawing = false
					line.clear_points()
				else:
					line.set_point_position(1, line.to_local(node.global_position))
					is_drawing = false
					start_port = null
			

func _on_port_1_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	handle_port_click(event, port1)

func _on_port_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	handle_port_click(event, port2)
