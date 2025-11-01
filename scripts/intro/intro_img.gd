extends Sprite2D

func fade_to(target_alpha: float, duration: float):
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", target_alpha, duration)
	await tween.finished

func _on_label_next_img(id: int) -> void:
	await fade_to(0, 1)
	if id != 0:
		self.texture = load("res://assets/Sprites/intro%s.png" % id)
		fade_to(1, 0.5)
	
