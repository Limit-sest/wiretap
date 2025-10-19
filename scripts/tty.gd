extends RichTextLabel

@onready var string_print = ""
@onready var print_index = -1

func print_tty(string: String) -> void:
	if print_index == -1:
		string_print = string
		append_text("\n\n")
		print_index = 0

func _process(_delta: float) -> void:
	if print_index != -1:
		append_text(string_print[print_index])
		print_index += 1
		if print_index >= string_print.length(): print_index = -1
