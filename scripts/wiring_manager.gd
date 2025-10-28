extends Node

var active_line: Line2D 
var active_curve: Path2D
var is_drawing: bool = false
var start_port: Node2D = null
var line_texture = load("res://assets/Sprites/Custom/Wire.png") 
var inp_en = load("res://assets/Sprites/Custom/input.png")
var inp_dis = load("res://assets/Sprites/Custom/input_disabled.png")
var out_en = load("res://assets/Sprites/Custom/output.png")
var out_dis = load("res://assets/Sprites/Custom/output_disabled.png")

var connections = []

func _get_world_mouse_position() -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()

func _new_line() -> void:
	active_line = Line2D.new()
	active_curve = Path2D.new()
	active_line.width = 5.0
	active_line.default_color = Color.from_hsv(randf(), 0.4, 0.95)
	active_line.texture_mode = active_line.LINE_TEXTURE_TILE
	active_line.begin_cap_mode = active_line.LINE_CAP_ROUND
	active_line.end_cap_mode = active_line.LINE_CAP_ROUND
	active_line.texture = line_texture
	add_child(active_line)
	move_child(active_line, get_child_count()-1)
	add_child(active_curve)
	move_child(active_curve, get_child_count()-1)
	active_curve.curve = Curve2D.new()

func  _delete_existing_connection(port) -> void:
	var to_be_deleted = []
	for connection in connections:
		if connection.has(port):
			to_be_deleted.append(connection)
	for connection in to_be_deleted:
		remove_child(connection[2])
		remove_child(connection[3])
		connections.erase(connection)

func _handle_gravity(point_1):
	var point_0 = active_curve.curve.get_point_position(0)
	var delta_vec = point_1 - point_0

	if delta_vec.y > 0:
		var out_point = Vector2(0, abs(delta_vec.y) * 0.5)
		var in_point = Vector2(-abs(delta_vec.x) * 0.5 * sign(delta_vec.x), 0.2 * abs(delta_vec.x))
		
		active_curve.curve.set_point_out(0, out_point)
		active_curve.curve.set_point_in(1, in_point)
	else:
		var out_point = Vector2(abs(delta_vec.x) * 0.5 * sign(delta_vec.x), 0.2 * abs(delta_vec.x))
		var in_point = Vector2(0, -abs(delta_vec.y) * 0.5 * sign(delta_vec.y))
		
		active_curve.curve.set_point_out(0, out_point)
		active_curve.curve.set_point_in(1, in_point)
		
	active_line.points = active_curve.curve.tessellate()

func _ready():
	_new_line()

func start_wire(port_node: Node2D):
	if is_drawing:
		return

	is_drawing = true
	start_port = port_node
	active_curve.curve.clear_points()
	_delete_existing_connection(start_port)
	
	if start_port.is_in_group('input'):
		var nodes: Array[Node] = get_tree().get_nodes_in_group('input')
		nodes.erase(start_port)
		for node in nodes:
			node.get_child(0).get_child(0).texture = inp_dis
	elif start_port.is_in_group('output'):
		var nodes: Array[Node] = get_tree().get_nodes_in_group('output')
		nodes.erase(start_port)
		for node in nodes:
			node.get_child(0).get_child(0).texture = out_dis

	var start_pos = active_curve.to_local(start_port.global_position)
	var mouse_pos = active_curve.to_local(_get_world_mouse_position())
	active_curve.curve.add_point(start_pos)
	active_curve.curve.add_point(mouse_pos)
	
func _unhandled_input(event):
	if is_drawing and event is InputEventMouseButton and not event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			var space_state = get_tree().root.get_world_2d().direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			query.position = _get_world_mouse_position()
			query.collide_with_areas = true
			query.collision_mask = 2 # ports layer
			
			var result = space_state.intersect_point(query)
			if not result.is_empty():
				# When line is dropped over a port
				var target_port = result[0].collider
				if target_port.is_in_group("ports") and target_port != start_port and (target_port.is_in_group("input") != start_port.is_in_group("input")):
					_delete_existing_connection(target_port)
					active_curve.curve.set_point_position(1, active_curve.to_local(target_port.global_position))
					_handle_gravity(active_curve.to_local(target_port.global_position))
					
					if target_port.is_in_group("input"):
						connections.append([target_port, start_port, active_line, active_curve])
					else:
						connections.append([start_port, target_port, active_line, active_curve])
					# Create new active line
					_new_line()
					print("Connection created!")
			is_drawing = false
#			Make disabled ports enabled again
			if start_port.is_in_group('input'):
				var nodes: Array[Node] = get_tree().get_nodes_in_group('input')
				nodes.erase(start_port)
				for node in nodes:
					node.get_child(0).get_child(0).texture = inp_en
			elif start_port.is_in_group('output'):
				var nodes: Array[Node] = get_tree().get_nodes_in_group('output')
				nodes.erase(start_port)
				for node in nodes:
					node.get_child(0).get_child(0).texture = out_en
			start_port = null
			active_line.clear_points()
			active_curve.curve.clear_points()
			
func _process(delta):
	if is_drawing:
		var point_1 = active_curve.to_local(_get_world_mouse_position())
		active_curve.curve.set_point_position(1, point_1)
		
		_handle_gravity(point_1)
		
