extends TextureRect

var offset := 0.0

func _process(delta):
	offset += delta
	material.set_shader_parameter("scroll_offset", offset)
