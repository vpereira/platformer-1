extends Area2D


# if we need the variable, rename it to body again 
func _on_body_entered(_body: Node2D) -> void:
	queue_free()
