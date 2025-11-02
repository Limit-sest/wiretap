extends Node

var active_line: Line2D 
var active_curve: Path2D
var is_drawing: bool = false
var start_port: TextureButton = null
var click_sfx: AudioStreamPlayer
var line_texture = load("res://assets/Sprites/Custom/Wire.png")

var connections = []

func _get_world_mouse_position() -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()

func _get_port_at_mouse() -> TextureButton:
	var world_mouse_pos = _get_world_mouse_position()
	var best_match = null
	var best_distance = 999999.0
	
	for port in get_tree().get_nodes_in_group("ports"):
		if port is TextureButton and port.visible:
			var port_center = port.get_global_rect().get_center()
			var distance = world_mouse_pos.distance_to(port_center)
			if distance < 30 and distance < best_distance:
				best_match = port
				best_distance = distance
	
	return best_match

func _new_line() -> void:
	active_line = Line2D.new()
	active_curve = Path2D.new()
	active_line.width = 5.0
	active_line.default_color = Color.from_hsv(randf(), 0.4, 0.95)
	active_line.texture_mode = active_line.LINE_TEXTURE_TILE
	active_line.begin_cap_mode = active_line.LINE_CAP_ROUND
	active_line.end_cap_mode = active_line.LINE_CAP_ROUND
	active_line.texture = line_texture
	active_line.z_index = 10
	add_child(active_line)
	move_child(active_line, get_child_count()-1)
	add_child(active_curve)
	move_child(active_curve, get_child_count()-1)
	active_curve.curve = Curve2D.new()

func _delete_existing_connection(port) -> void:
	var to_be_deleted = []
	for connection in connections:
		if connection.has(port):
			to_be_deleted.append(connection)
	for connection in to_be_deleted:
		var output_port = connection[1]
		output_port.next_node = null
		
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

func _toggle_other_ports(disabled: bool):
	if not start_port:
		return
	
	var group_name = 'input' if start_port.is_in_group('input') else 'output'
	var nodes: Array[Node] = get_tree().get_nodes_in_group(group_name)
	for node in nodes:
		if node != start_port:
			node.disabled = disabled

func create_wire(p_start_port, p_target_port):
	var line = Line2D.new()
	var curve = Path2D.new()
	line.width = 5.0
	line.default_color = Color.from_hsv(randf(), 0.4, 0.95)
	line.texture_mode = line.LINE_TEXTURE_TILE
	line.begin_cap_mode = line.LINE_CAP_ROUND
	line.end_cap_mode = line.LINE_CAP_ROUND
	line.texture = line_texture
	line.z_index = 10
	add_child(line)
	add_child(curve)
	curve.curve = Curve2D.new()

	var start_pos_global = p_start_port.get_global_rect().get_center()
	var target_pos_global = p_target_port.get_global_rect().get_center()
	
	var start_pos_local = curve.to_local(start_pos_global)
	var target_pos_local = curve.to_local(target_pos_global)
	
	curve.curve.add_point(start_pos_local)
	curve.curve.add_point(target_pos_local)
	
	var delta_vec = target_pos_local - start_pos_local

	if delta_vec.y > 0:
		var out_point = Vector2(0, abs(delta_vec.y) * 0.5)
		var in_point = Vector2(-abs(delta_vec.x) * 0.5 * sign(delta_vec.x), 0.2 * abs(delta_vec.x))
		
		curve.curve.set_point_out(0, out_point)
		curve.curve.set_point_in(1, in_point)
	else:
		var out_point = Vector2(abs(delta_vec.x) * 0.5 * sign(delta_vec.x), 0.2 * abs(delta_vec.x))
		var in_point = Vector2(0, -abs(delta_vec.y) * 0.5 * sign(delta_vec.y))
		
		curve.curve.set_point_out(0, out_point)
		curve.curve.set_point_in(1, in_point)
		
	line.points = curve.curve.tessellate()
	
	var output_port
	var input_port
	
	if p_target_port.is_in_group("input"):
		input_port = p_target_port
		output_port = p_start_port
		connections.append([input_port, output_port, line, curve])
	else:
		input_port = p_start_port
		output_port = p_target_port
		connections.append([input_port, output_port, line, curve])
	
	output_port.next_node = input_port

func _ready():
	click_sfx = AudioStreamPlayer.new()
	click_sfx.stream = load("res://assets/sounds/switch.wav")
	add_child(click_sfx)
	_new_line()

func start_wire(port_node):
	if is_drawing:
		return

	is_drawing = true
	start_port = port_node
	active_curve.curve.clear_points()
	_delete_existing_connection(start_port)
	
	click_sfx.pitch_scale = 1
	click_sfx.play()
	
	_toggle_other_ports(true)

	var start_pos_global = start_port.get_global_rect().get_center()
	var start_pos = active_curve.to_local(start_pos_global)
	var mouse_pos = active_curve.to_local(_get_world_mouse_position())
	active_curve.curve.add_point(start_pos)
	active_curve.curve.add_point(mouse_pos)
	
func _input(event):
	if is_drawing and event is InputEventMouseButton and not event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			var target_port = _get_port_at_mouse()
			
			if target_port and target_port.is_in_group("ports") and target_port != start_port and (target_port.is_in_group("input") != start_port.is_in_group("input")):
				_delete_existing_connection(target_port)
				var target_pos_global = target_port.get_global_rect().get_center()
				var target_pos_local = active_curve.to_local(target_pos_global)
				active_curve.curve.set_point_position(1, target_pos_local)
				_handle_gravity(target_pos_local)
				
				var output_port
				var input_port
				
				if target_port.is_in_group("input"):
					input_port = target_port
					output_port = start_port
					connections.append([input_port, output_port, active_line, active_curve])
				else:
					input_port = start_port
					output_port = target_port
					connections.append([input_port, output_port, active_line, active_curve])
				
				output_port.next_node = input_port
				
				_new_line()
			is_drawing = false
			
			click_sfx.pitch_scale = 0.8
			click_sfx.play()
			
			_toggle_other_ports(false)
			start_port = null
			active_line.clear_points()
			active_curve.curve.clear_points()
			
			get_viewport().set_input_as_handled()
			
func _process(delta):
	if is_drawing:
		var point_1 = active_curve.to_local(_get_world_mouse_position())
		active_curve.curve.set_point_position(1, point_1)
		
		_handle_gravity(point_1)
