extends RichTextLabel

var enabled_decipher = false
var print_text = "Cheeeeeeeeeeeeeeeeeese"

func _on_button_toggled(toggled_on: bool) -> void:
	enabled_decipher = toggled_on

func rand_str(input: String) -> String:
	var chars = "abcdefghijklmnopqrstuvwxyz-"
	var random_string = ""
	for i in range(input.length()):
		random_string += chars[randi() % chars.length()]
	return random_string

func _on_timer_timeout() -> void:
	if enabled_decipher:
		append_text("\n"+print_text)
	else:
		append_text("\n"+rand_str(print_text))
		
