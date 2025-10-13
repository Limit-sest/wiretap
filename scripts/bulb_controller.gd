extends Sprite2D

@onready var bulb = $Bulb

func _on_button_toggled(toggled_on: bool) -> void:
	bulb.visible = toggled_on
