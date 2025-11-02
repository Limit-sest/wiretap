extends "res://modules/base/base_module.gd"

var ciphered_text: String
@export var original_text: String = "test"
@export var encode_number: int = 1

func _ready() -> void:
	ciphered_text = original_text
	var cipher_modules = get_tree().get_nodes_in_group('cipher_module')
	for i in range(min(encode_number, cipher_modules.size())):
		var module = cipher_modules[randi_range(0, cipher_modules.size() - 1)]
		cipher_modules.erase(module)
		ciphered_text = module.encode(ciphered_text, (encode_number - 1) - i)

func _on_signal_send_timeout() -> void:
	await _animate_success()
	print("sending: " + ciphered_text)
	send_signal.emit(ciphered_text, 0)

func _animate_success() -> void:
	var pins = [self.find_child("pin1"), self.find_child("pin2"), self.find_child("pin3")]
	
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

	for pin in pins:
		if pin:
			pin.visible = false
