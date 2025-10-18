class_name CipherUtils

const ALPHABET = " abcdefghijklmnopqrstuvwxyz"
const MORSE_CODE_MAP_LOWER = {
	"a": ".-", "b": "-...", "c": "-.-.", "d": "-..", "e": ".", "f": "..-.",
	"g": "--.", "h": "....", "i": "..", "j": ".---", "k": "-.-", "l": ".-..",
	"m": "--", "n": "-.", "o": "---", "p": ".--.", "q": "--.-", "r": ".-.",
	"s": "...", "t": "-", "u": "..-", "v": "...-", "w": ".--", "x": "-..-",
	"y": "-.--", "z": "--..", "1": ".----", "2": "..---", "3": "...--",
	"4": "....-", "5": ".....", "6": "-....", "7": "--...", "8": "---..",
	"9": "----.", "0": "-----", ".": ".-.-.-", ",": "--..--", "?": "..--..",
	"'": ".----.", "!": "-.-.--", "/": "-..-.", "(": "-.--.", ")": "-.--.-",
	"&": ".-...", ":": "---...", ";": "-.-.-.", "=": "-...-", "+": ".-.-.",
	"-": "-....-", "_": "..--.-", "\"": ".-..-.", "$": "...-..-", "@": ".--.-.",
	" ": "/"
}

static func encode_caesar(string: String, shift = 3) -> String:
	var final_string = ""
	for c in string.to_lower():
		var index = ALPHABET.find(c)
		if index == -1: 
			final_string += c
			continue
		index += shift
		if index > ALPHABET.length():
			index -= ALPHABET.length()
		elif index < 0:
			index += ALPHABET.length()
		final_string += ALPHABET[index]
	return final_string

static func decode_caesar(string: String) -> String:
	return encode_caesar(string, -3)

static func encode_numbers(string: String) -> String:
	var final_string = ""
	for c in string.to_lower():
		var index = ALPHABET.find(c)
		if index == -1: 
			final_string += c
			continue
		final_string += index
		final_string += " "
	return final_string

static func decode_numbers(string: String) -> String:
	var final_string = ""
	for c in string.split(" "):
		if c.is_valid_int():
			final_string += ALPHABET[c.to_int()]
		else:
			final_string += c
	return final_string
