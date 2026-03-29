extends CharacterBody2D


const SPEED : float = 130.0
const JUMP_VELOCITY : float = -300.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var last_direction : float = 1.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction -1, 0, -1
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the sprite
	if direction:
		animated_sprite_2d.flip_h = direction < 0

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Update animations
	_update_animation(direction)


func _update_animation(direction: float) -> void:
	if not is_on_floor():
		animated_sprite_2d.play("jump")
	elif direction != 0 and direction != last_direction and last_direction != 0:
		animated_sprite_2d.play("turn")
	elif direction != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	if direction != 0:
		last_direction = direction
