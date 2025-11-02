extends Node2D

@export var antenna: Node
@export var display: Node
@onready var tutorial_label: Label = %TutorialLabel

var sent_count = 0
var tutorial_text = ["",
"Now the antenna module is sending encoded data to the display through the wire.",
"Try connecting the antenna to the numbers decoder by dragging the wire.",
"In order for us to see the output, the data needs to flow into the display. Connect the number decoder output with the display.",
"Good job! You can now see the decoded text"]
var current_text = 0

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

func _ready():
	await get_tree().process_frame
	var antenna_output = antenna.find_child("Output")
	var display_input = display.find_child("Input")
	WiringManager.create_wire(antenna_output, display_input)


func _on_antenna_send_signal(_text: String, _step: int) -> void:
	sent_count += 1
	if sent_count == 1:
		_set_tutorial(1)
	elif sent_count == 3:
		_set_tutorial(2)


func _on_base_module_send_signal(_text: String, _step: int) -> void:
	_set_tutorial(3)


func _on_display_send_signal(_text: String, step: int) -> void:
	if step == 2:
		_set_tutorial(4)
		$Button.visible = true

func _on_button_pressed() -> void:
	SceneManager.change_scene("res://main.tscn")
