extends Node2D

@onready var initial_node = %Antenna/Output
@onready var encoded_string = CipherUtils.encode_numbers("You now know how the connection system works. Good job!")
@onready var beep_sfx: AudioStreamPlayer = %BeepSfx
@onready var tutorial_label: Label = %TutorialLabel

var sent_count = 0

var decode_functions = {
	"Numbers": CipherUtils.decode_numbers,
}

var tutorial_text = ["", "Now the antenna module is sending encoded data to the display through the wire.", "Try connecting the antenna to the numbers decoder by dragging the wire.", "In order for us to see the output, the data needs to flow into the display. Connect the number decoder output with the display."]
var current_text = 0

func _ready():
	# Create default connection from Antenna to Display
	var antenna_output = %Antenna/Output
	var display_input = $CanvasGroup/Display/Input
	
	var line = Line2D.new()
	var path = Path2D.new()
	path.curve = Curve2D.new()
	line.width = 5.0
	line.default_color = Color.from_hsv(0.65, 0.4, 0.95)
	line.texture_mode = line.LINE_TEXTURE_TILE
	line.texture = WiringManager.line_texture
	line.begin_cap_mode = line.LINE_CAP_ROUND
	line.end_cap_mode = line.LINE_CAP_ROUND
	WiringManager.add_child(line)
	WiringManager.add_child(path)
	
	var start_pos = path.to_local(antenna_output.global_position)
	var end_pos = path.to_local(display_input.global_position)

	path.curve.add_point(start_pos)
	path.curve.add_point(end_pos)
	
	var delta_vec = end_pos - start_pos
	
	if delta_vec.y > 0:
		var out_point = Vector2(0, abs(delta_vec.y) * 0.5)
		var in_point = Vector2(-abs(delta_vec.x) * 0.5 * sign(delta_vec.x), 0)
		
		path.curve.set_point_out(0, out_point)
		path.curve.set_point_in(1, in_point)
	else:
		var out_point = Vector2(abs(delta_vec.x) * 0.5 * sign(delta_vec.x), 0)
		var in_point = Vector2(0, -abs(delta_vec.y) * 0.5 * sign(delta_vec.y))
		
		path.curve.set_point_out(0, out_point)
		path.curve.set_point_in(1, in_point)
			
		
	line.points = path.curve.tessellate()
	
	WiringManager.connections.append([display_input, antenna_output, line, path])

func _get_linked_port(first_port: Area2D): # Get output port in the same module
	var parent = first_port.get_parent()
	return [parent.find_child("Output"), parent.name]

func _get_next_port(output_port: Area2D): # Get connected port with wire
	for connection in WiringManager.connections:
		if connection[1] == output_port:
			return connection[0]

func _animate_module_pins(module: Node2D) -> void:
	var pins = [module.find_child("pin1"), module.find_child("pin2"), module.find_child("pin3")]
	
	beep_sfx.pitch_scale = randf_range(0.9, 1.1)
	beep_sfx.play()
	
	for i in range(3):
		if pins[i]:
			for pin in pins:
				if pin:
					pin.visible = false
			pins[i].visible = true
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame

	
	
	# Hide all pins after animation
	for pin in pins:
		if pin:
			pin.visible = false
			
func _set_tutorial(id: int) -> void:
	if current_text < id:
		var tween: Tween = create_tween()
		tween.tween_property(tutorial_label, "modulate:a", 0.0, 0.5)
		await tween.finished
		tutorial_label.text = tutorial_text[id]
		current_text = id
		var tween2: Tween = create_tween()
		tween2.tween_property(tutorial_label, "modulate:a", 1.0, 0.5)
		await tween.finished

func _on_signal_send_timeout() -> void:
	var current_node = initial_node
	var working_string = encoded_string
	
	if %"tty/Sprite2D/tty".print_index != -1:
		return
	
	sent_count += 1
	if sent_count == 1:
		_set_tutorial(1)
	elif sent_count == 3:
		_set_tutorial(2)
	
	# Animate the starting module (Antenna)
	await _animate_module_pins(current_node.get_parent())
	
	while true:
		var next_node = _get_next_port(current_node)
		if !next_node: 
			break
		elif next_node.get_parent().name == "Numbers":
			_set_tutorial(3)
		elif next_node.get_parent().name == "Display":
			%"tty/Sprite2D/tty".print_tty(working_string)
			await _animate_module_pins(next_node.get_parent())
			break
		var linked_port = _get_linked_port(next_node)
		current_node = linked_port[0]
		if !current_node: break
		working_string = decode_functions[linked_port[1]].call(working_string)
		# Animate the current module
		await _animate_module_pins(current_node.get_parent())
	
