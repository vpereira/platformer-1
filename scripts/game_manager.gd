extends Node2D

const LEVELS = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
]

var current_level_index: int = 0
var current_level: Node = null


func _ready() -> void:
	load_level(current_level_index)


func load_level(index: int) -> void:
	# Remove current level if exists
	if current_level:
		current_level.queue_free()
		await current_level.tree_exited

	# Load new level
	var level_scene = load(LEVELS[index])
	current_level = level_scene.instantiate()
	add_child(current_level)

	# Connect to castle's level_completed signal
	var castle = current_level.get_node_or_null("Castle")
	if castle:
		castle.level_completed.connect(_on_level_completed)

	print("Loaded level ", index + 1)


func _on_level_completed() -> void:
	current_level_index += 1

	if current_level_index >= LEVELS.size():
		print("Game complete!")
		# Loop back to level 1 for now
		current_level_index = 0

	load_level(current_level_index)
