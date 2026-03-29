extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# if we need the variable, rename it to body again 
func _on_body_entered(_body: Node2D) -> void:
	animation_player.play("pickup_animation")
