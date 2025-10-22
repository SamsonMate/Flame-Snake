extends Node2D

@onready var label = $Label

func show_damage(amount: int, color: Color = Color.RED):
	label.text = str(amount)
	label.modulate = color
	animate()

func animate():
	var tween = get_tree().create_tween()
	var offset = Vector2(randf_range(-10, 10), randf_range(-35, -25))
	var end_pos = position + offset

	tween.tween_property(self, "position", end_pos, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Label, "modulate:a", 0.0, 0.6)

	await tween.finished
	queue_free()
