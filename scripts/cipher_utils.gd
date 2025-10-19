class_name CipherUtils

const ALPHABET = " abcdefghijklmnopqrstuvwxyz1234567890.,?!:-"
const MORSE_CODE = {
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
const MORSE_CODE_REVERSE = {
	".-": "a", "-...": "b", "-.-.": "c", "-..": "d", ".": "e", "..-.": "f",
	"--.": "g", "....": "h", "..": "i", ".---": "j", "-.-": "k", ".-..": "l",
	"--": "m", "-.": "n", "---": "o", ".--.": "p", "--.-": "q", ".-.": "r",
	"...": "s", "-": "t", "..-": "u", "...-": "v", ".--": "w", "-..-": "x",
	"-.--": "y", "--..": "z", ".----": "1", "..---": "2", "...--": "3",
	"....-": "4", ".....": "5", "-....": "6", "--...": "7", "---..": "8",
	"----.": "9", "-----": "0", ".-.-.-": ".", "--..--": ",", "..--..": "?",
	".----.": "'", "-.-.--": "!", "-..-.": "/", "-.--.": "(", "-.--.-": ")",
	".-...": "&", "---...": ":", "-.-.-.": ";", "-...-": "=", ".-.-.": "+",
	"-....-": "-", "..--.-": "_", ".-..-.": "\"", "...-..-": "$",
	".--.-.": "@", "/": " "
}

static func encode_caesar(string: String, shift = 13) -> String:
	var final_string = ""
	for c in string.to_lower():
		var index = ALPHABET.find(c)
		if index == -1: 
			final_string += c
			continue
		index += shift
		if index >= ALPHABET.length():
			index -= ALPHABET.length()
			continue
		elif index < 0:
			index += ALPHABET.length()
			continue
		final_string += ALPHABET[index]
	return final_string

static func decode_caesar(string: String) -> String:
	return encode_caesar(string, -13)

static func encode_numbers(string: String) -> String:
	var final_string = ""
	for c in string.to_lower():
		var index = ALPHABET.find(c)
		if index == -1: 
			final_string += c
			continue
		final_string += str(index) + " "
	return final_string

static func decode_numbers(string: String) -> String:
	var final_string = ""
	for c in string.split(" "):
		if c.is_valid_int():
			final_string += ALPHABET[c.to_int()]
		else:
			final_string += c
	return final_string

static func encode_morse(string: String) -> String:
	var final_string = ""
	for c in string.to_lower():
		if MORSE_CODE.has(c):
			final_string += MORSE_CODE[c] + " "
		else: final_string += c
	return final_string
	
static func decode_morse(string: String) -> String:
	var final_string = ""
		
	for c in string.split(" "):
		if MORSE_CODE_REVERSE.has(c):
			final_string += MORSE_CODE_REVERSE[c]
		else: final_string += c
		
	return final_string

static func encode_random(string: String) -> String:
	var functions = [encode_caesar, encode_numbers, encode_morse]
	var used = []
	var working_string = string
	for i in range(2):
		var index = randi() % 3
		while used.has(index):
			index = randi() % 3
		used.append(index)
		print("encoding with " + str(functions[index]))
		working_string = functions[index].call(working_string)
	return working_string
