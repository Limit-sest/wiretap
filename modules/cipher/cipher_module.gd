extends "res://modules/base/base_module.gd"

var _cipher_history = []
@onready var beep_sfx: AudioStreamPlayer = %BeepSfx

func encode(text_in: String, step: int) -> String:
	var text_out: String = _do_encode(text_in)
	_cipher_history.append({"original": text_in, "step": step })
	return text_out

func _do_encode(text_in) -> String:
	# Is overwritten in modules
	return text_in

# Decode
func _on_signal_recieved(_text: String, step: int) -> void:
	var correct_entry
	for hist_entry in _cipher_history:
		if hist_entry.step == step:
			correct_entry = hist_entry
	
	if correct_entry:
		await _animate_success()
		super._on_signal_recieved(correct_entry.original, step)
	else:
		await _animate_error()
		
func _animate_error() -> void:
	var pins = [self.find_child("pin1"), self.find_child("pin2"), self.find_child("pin3")]
	
	for pin in pins:
		if pin:
			pin.modulate.g = 0.1
			pin.modulate.b = 0.0

	for i in range(5):
		beep_sfx.pitch_scale = 0.8
		beep_sfx.play()
		
		for pin in pins:
			if pin:
				pin.visible = true
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		
		for pin in pins:
			if pin:
				pin.visible = false
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		
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