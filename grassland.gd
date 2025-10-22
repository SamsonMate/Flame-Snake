extends Node2D

@onready var grassland = $"."
@onready var time_label = $UI/TimeCounter/Label
@onready var ashes_label = $UI/AshesCounter/Label
@onready var Main = get_tree().current_scene

signal show_skill_tree()

var game_timer: Timer

func _ready():
	# Setup game timer
	game_timer = Timer.new()
	game_timer.wait_time = Main.game_time
	game_timer.one_shot = true
	add_child(game_timer)
	game_timer.start()
	
	# Setup UI
	time_label.text = str(game_timer.wait_time)
	ashes_label.text = "Ashes: " + str(Main.ashes)

func _process(_delta):
	time_label.text = ("%0.1f" % game_timer.time_left)
	if game_timer.time_left <= 0.0: end_game()

func end_game():
	print("Ending game...")
	show_skill_tree.emit()
