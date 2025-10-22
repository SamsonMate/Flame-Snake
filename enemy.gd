extends Node2D
class_name Enemy

@onready var Main = get_tree().current_scene
@onready var particles = $GPUParticles2D
@onready var collision: Area2D = $Area2D

# These are the class variables
@export var hp: int
# Value is stored in main for easy changes

signal died()

func _ready():
	pass
func _process(_delta):
	pass

func _on_area_2d_area_entered(area):
	# Check if entity can deal damage
	var entity = area.get_parent()
	if not entity.has_meta("is_head"): return
	
	take_damage(entity)
	
	if hp <= 0:
		die()

func take_damage(entity):
	if not entity.has_meta("is_head"): return
	
	# Determine damage amount
	var dmg
	if entity.get_meta("is_head"):
		dmg = Main.head_damage
	else:
		dmg = Main.body_damage
	
	# Deal damage
	hp -= dmg
	entity.spawn_damage_number(dmg)

func die():
	printerr("Dying is not implemented for: " + str(self))

func kill_self():
	queue_free()
