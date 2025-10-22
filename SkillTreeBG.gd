extends ParallaxBackground

@export var drift_speed: Vector2 = Vector2(5, 2)

func _process(delta):
	scroll_offset += drift_speed * delta
