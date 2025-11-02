extends "res://modules/cipher/cipher_module.gd"

const ALPHABET = " abcdefghijklmnopqrstuvwxyz1234567890.,?!:-"

func _do_encode(text_in) -> String:
	var final_string = ""
	for c in text_in.to_lower():
		var index = ALPHABET.find(c)
		if index == -1: 
			final_string += c + " "
			continue
		final_string += str(index) + " "
	return final_string.strip_edges()
