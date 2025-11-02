extends Node

var current_scene: Node = null
var fade_layer: CanvasLayer = null
var fade_rect: ColorRect = null
var is_transitioning: bool = false
var fade_duration: float = 0.5

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	_setup_fade()

func _setup_fade() -> void:
	fade_layer = CanvasLayer.new()
	fade_layer.layer = 100
	add_child(fade_layer)
	
	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.modulate.a = 0.0
	fade_layer.add_child(fade_rect)

func change_scene(scene_path: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	await _fade_to_black()
	call_deferred("_deferred_change_scene", scene_path)

func _deferred_change_scene(scene_path: String) -> void:
	WiringManager.remove_all_wires()
	if current_scene:
		current_scene.free()
	
	var new_scene = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene = new_scene
	
	await _fade_from_black()
	is_transitioning = false

func _fade_to_black() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_duration)
	await tween.finished

func _fade_from_black() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, fade_duration)
	await tween.finished

func reload_current_scene() -> void:
	if current_scene:
		var scene_path = current_scene.scene_file_path
		change_scene(scene_path)
