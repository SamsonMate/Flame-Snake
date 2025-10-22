extends TextureRect

func _process(_delta: float) -> void:
	# Get the global mouse position relative to the UI
	global_position = get_viewport().get_mouse_position()
