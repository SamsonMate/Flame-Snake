extends Node

# Screens/Areas
const MAIN_MENU = preload("res://main_menu.tscn")
const SKILL_TREE = preload("res://skill_tree.tscn")
const GRASSLAND = preload("res://grassland.tscn")

# Important game objects (Initialized in _ready as main.gd loads before scene tree)
var camera: Camera2D

##
##	GAME MENU MANAGER
##
var current_screen: Node = null
var camera_target: Node = null

func _process(_delta):
	if camera_target:
		if camera_target is Node2D:
			camera.position = camera_target.position
		elif camera_target is Control:
			camera.position = camera_target.global_position

func update_camera(node):
	camera_target = node

func _ready():
	camera = find_child("Camera")
	if camera: show_main_menu() # ready runs on autoload load and game load

# Wrappers for screen switching
func show_main_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	camera.zoom = Vector2(1, 1)
	_switch_screen(MAIN_MENU)
	camera.position = Vector2(640,360)

func show_skill_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	camera.zoom = Vector2(1, 1)
	_switch_screen(SKILL_TREE)
	for node in current_screen.get_children():
		if node is SkillNode:
			camera_target = node
	
func show_grassland():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	camera.zoom = Vector2(3, 3)
	_switch_screen(GRASSLAND)
	camera_target = current_screen.get_node("Snake")

# Helper function for switching screens/scenes
func _switch_screen(new_scene: PackedScene):
	# Remove old data
	if current_screen:
		current_screen.queue_free()
	if camera_target:
		camera_target = null

	current_screen = new_scene.instantiate()
	add_child(current_screen)

	# Connect signals for scene switching and camera
	if current_screen.has_signal("update_camera"):
		current_screen.connect("update_camera", Callable(self, "update_camera"))
	
	if current_screen.has_signal("show_grassland"):
		current_screen.connect("show_grassland", Callable(self, "show_grassland"))
	elif current_screen.has_signal("show_skill_tree"):
		current_screen.connect("show_skill_tree", Callable(self, "show_skill_tree"))
	elif current_screen.has_signal("return_to_menu"):
		current_screen.connect("return_to_menu", Callable(self, "show_main_menu"))

##
##	GAME DATA / DATA HANDLERS
##
var ashes: int = 10000#0
var game_time: float = 10.0

var head_damage: float = 5
var body_damage: float = 3
var player_speed: float = 100.0

var grass_hp: int = 9
var grass_value: int = 1
var num_grass_spawn: int = 2 # Starts lagging around 500-700

var growthUnlock: bool = false
var growth_orb_chance: float = 0.10

var tree_hp: int = 25
var tree_value: int = 20
var num_tree_spawn: int = 0

##
##	SKILLS TABLE
##
##	NOTE:
##	- All cost and effect fields must be a function
##	- All cost functions must return an int
##
var Skills: Dictionary = {
	"Increase Grass Spawn Amount":{
		"level": 0,
		"max_level": 10,
		"prereq_level": -1, # Since first node should always be unlocked
		"description": "+1 grass spawn each spawn tick",
		"cost": func(): return 10 + 10*Skills["Increase Grass Spawn Amount"]["level"],
		"effect": func(): num_grass_spawn += 1
	},
	"Unlock Growth":{
		"level": 0,
		"max_level": 1,
		"prereq_level": 1, 
		"description": "Unlock the ability to grow using growth orbs (10% chance per spawn)",
		"cost": func(): return 20,
		"effect": func(): growthUnlock = true
	},
	"More Ash":{
		"level": 0,
		"max_level": 3,
		"prereq_level": 3,
		"description": "x2 ash when burning grass",
		"cost": func(): return 50 * 2**Skills["More Ash"]["level"],
		"effect": func(): grass_value *= 2
	},
	"Move Faster":{
		"level": 0,
		"max_level": 5,
		"prereq_level": 1,
		"description": "+20% move speed",
		"cost": func(): return 50 + 25*Skills["Move Faster"]["level"],
		"effect": func(): player_speed += 20
	},
	"More Time":{
		"level": 0,
		"max_level": 4,
		"prereq_level": 1,
		"description": "+2.5s each game",
		"cost": func(): return 50 + 50*Skills["More Time"]["level"],
		"effect": func(): game_time += 2.5
	},
	"Increase Growth Orb Chance":{
		"level": 0,
		"max_level": 2,
		"prereq_level": 1,
		"description": "+10% chance for Growth Orbs to spawn",
		"cost": func(): return 50 + 75*Skills["Increase Growth Orb Chance"]["level"],
		"effect": func(): growth_orb_chance += 0.1
	},
	"More Grass":{
		"level": 0,
		"max_level": 10,
		"prereq_level": 10,
		"description": "+10 grass spawn each spawn tick",
		"cost": func() -> int: return 500 * 1.5**Skills["More Grass"]["level"],
		"effect": func(): num_grass_spawn += 10
	},
	"Bulky Grass":{
		"level": 0,
		"max_level": 7,
		"prereq_level": 4,
		"description": "x2 grass value but 2x grass health",
		"cost": func(): return 250 * 3**Skills["Bulky Grass"]["level"],
		"effect": func(): grass_value *= 2; grass_hp *= 2;
	},
	"Spawn Trees":{
		"level": 0,
		"max_level": 3,
		"prereq_level": 3,
		"description": "+1 tree spawn each spawn tick. More hp = bigger reward!",
		"cost": func(): return 250 * 3**Skills["Spawn Trees"]["level"],
		"effect": func(): num_tree_spawn += 1
	},
	"More Damage":{
		"level": 0,
		"max_level": 5,
		"prereq_level": 2,
		"description": "x1.5 damage",
		"cost": func(): return 250 * 3**Skills["More Damage"]["level"],
		"effect": func(): head_damage *= 1.5; body_damage *= 1.5; print(str(head_damage) + " " + str(body_damage))
	},
}
