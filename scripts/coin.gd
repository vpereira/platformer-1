extends Area2D

signal collected

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sound: AudioStreamPlayer2D = $PickupSound


func _ready() -> void:
	add_to_group("coins")


func _on_body_entered(_body: Node2D) -> void:
	collected.emit()
	_play_collect_effect()


func _play_collect_effect() -> void:
	# Disable collision immediately
	collision.set_deferred("disabled", true)

	# Play sound
	sound.play()

	# Store original position
	var start_pos = sprite.position

	# Create tween for the effect
	var tween = create_tween()
	tween.set_parallel(true)

	# Flash white briefly
	sprite.modulate = Color(2, 2, 2, 1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.3)

	# Pop up then shrink
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.05)
	tween.chain().tween_property(sprite, "scale", Vector2(0, 0), 0.25)

	# Float upward
	tween.tween_property(sprite, "position:y", start_pos.y - 20, 0.3)

	# Spin faster
	tween.tween_property(sprite, "speed_scale", 8.0, 0.3)

	# Delete when done
	tween.chain().tween_callback(queue_free)
