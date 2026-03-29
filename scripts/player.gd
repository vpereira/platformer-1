extends CharacterBody2D

# Movement
const SPEED : float = 130.0
const ACCELERATION : float = 1200.0
const FRICTION : float = 1000.0
const AIR_ACCELERATION : float = 800.0
const AIR_FRICTION : float = 200.0

# Jumping
const JUMP_VELOCITY : float = -300.0
const COYOTE_TIME : float = 0.1
const JUMP_BUFFER_TIME : float = 0.1
const VARIABLE_JUMP_MULTIPLIER : float = 0.5
const APEX_GRAVITY_MULTIPLIER : float = 0.5
const APEX_THRESHOLD : float = 30.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var last_direction : float = 1.0
var coyote_timer : float = 0.0
var jump_buffer_timer : float = 0.0
var was_on_floor : bool = false


func _ready() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	var on_floor = is_on_floor()

	# Coyote time - allow jumping shortly after leaving platform
	if on_floor:
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	# Jump buffer - remember jump input before landing
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	# Apply gravity with apex modifier for floatier jump peak
	if not on_floor:
		var gravity_multiplier = 1.0
		if abs(velocity.y) < APEX_THRESHOLD:
			gravity_multiplier = APEX_GRAVITY_MULTIPLIER
		velocity += get_gravity() * gravity_multiplier * delta

	# Handle jump with coyote time and jump buffer
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# Variable jump height - release to cut jump short
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= VARIABLE_JUMP_MULTIPLIER

	# Get input direction
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the sprite
	if direction:
		animated_sprite_2d.flip_h = direction < 0

	# Apply movement with acceleration (different on ground vs air)
	if on_floor:
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, AIR_ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)

	was_on_floor = on_floor
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
