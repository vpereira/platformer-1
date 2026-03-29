extends Node2D

signal level_completed

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var door_area: Area2D = $DoorArea

var door_open: bool = false
var total_coins: int = 0
var collected_coins: int = 0


func _ready() -> void:
	# Count all coins in the scene
	await get_tree().process_frame
	var coins = get_tree().get_nodes_in_group("coins")
	total_coins = coins.size()
	print("Castle: Found ", total_coins, " coins")

	# Connect to each coin's collected signal
	for coin in coins:
		if coin.has_signal("collected"):
			coin.collected.connect(_on_coin_collected)
			print("Castle: Connected to coin ", coin.name)

	door_area.body_entered.connect(_on_door_body_entered)


func _on_coin_collected() -> void:
	collected_coins += 1
	print("Castle: Coin collected! ", collected_coins, "/", total_coins)
	if collected_coins >= total_coins and total_coins > 0:
		_open_door()


func _open_door() -> void:
	door_open = true
	animated_sprite.play("open_door")
	print("Castle: Door opened!")


func _on_door_body_entered(body: Node2D) -> void:
	print("Castle: Body entered door area: ", body.name, " door_open=", door_open)
	if not door_open:
		return
	if not body.is_in_group("player"):
		print("Castle: Body not in player group")
		return

	# Disable player input
	body.set_physics_process(false)

	# Fade out and complete level
	var tween = create_tween()
	tween.tween_property(body, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_complete_level)


func _complete_level() -> void:
	level_completed.emit()
	print("Level completed!")
	# You can add scene transition here, e.g.:
	# get_tree().change_scene_to_file("res://scenes/level_complete.tscn")
