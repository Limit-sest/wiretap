extends Control

signal send_signal(text: String, step: int)
@onready var beep_sfx: AudioStreamPlayer = %BeepSfx

func _on_signal_recieved(text: String, step: int) -> void:
	await _animate_success()
	send_signal.emit(text, step + 1)

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