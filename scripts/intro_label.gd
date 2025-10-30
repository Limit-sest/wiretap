extends Label

signal next_img(id: int)
signal next_scene()

@onready var print_timer: Timer = self.find_child("PrintTimer")
@onready var next_timer: Timer = self.find_child("NextTimer")
var id: int = 0
var intro_text = ["The old Blackwood House doesn't give up its secrets easily.", "", "They say it's empty. Abandoned.", "But you know better. You've felt it.", "A coldness that doesn't come from the drafty windows.", "", "The air itself is thick with echoes...", "...voices trapped between the walls, desperate to be heard.", "They are reaching out. Sending signals.", "You brought the equipment. Now, you just have to listen."]
var img_map = [{3: 2}, {8: 3}, {10: 0}]

func fade_to(target_alpha: float, duration: float):
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", target_alpha, duration)
	await tween.finished

func _print(new_text: String):
	self.text = new_text
	self.visible_characters = 0
	self.modulate.a = 1
	print_timer.start()

func _ready() -> void:
	await _print(intro_text[id])

func _on_next_timer_timeout() -> void:
	id += 1
	# Get image id from img map
	for d in img_map:
		if d.has(id):
			next_img.emit(d[id])
	await fade_to(0, 1)
	
	if id > intro_text.size()-1:
		next_scene.emit()
	else:
		_print(intro_text[id])


func _on_print_timer_timeout() -> void:
	if self.visible_characters < self.text.length():
		self.visible_characters += 1
	else:
		print_timer.stop()
		next_timer.start()
