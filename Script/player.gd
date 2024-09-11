extends CharacterBody2D


var speed = 150.0
const JUMP_VELOCITY = -300.0
const MAX_JUMP_TIME = 0.5 
var is_jumping = false
var jump_time = 0.0
var jump_held = false


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var modified_gravity = gravity

@export var Camera: Camera2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		$AnimatedSprite2D.play("jump")
		velocity.y += modified_gravity * delta
		if not is_jumping:
			$AnimatedSprite2D.play("jump")
			is_jumping = true

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		$AnimatedSprite2D.play("jump")
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		jump_time = 0.0
		jump_held = true

	if Input.is_action_pressed("ui_accept") and is_jumping and jump_held and jump_time < MAX_JUMP_TIME:
		jump_time += delta
		velocity.y = JUMP_VELOCITY * (1.0 - jump_time / MAX_JUMP_TIME)
		modified_gravity = gravity * (0.5 + jump_time / MAX_JUMP_TIME)  # Augmente la gravité en fonction du temps de saut

	if Input.is_action_just_released("ui_accept"):
		is_jumping = false
		jump_held = false
		modified_gravity = gravity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * speed
		if is_on_floor():
			$AnimatedSprite2D.play("run")
			if Input.is_action_pressed("Shift"):
				$AnimatedSprite2D.speed_scale = 2
				speed = 200
			else:
				$AnimatedSprite2D.speed_scale = 1
				speed = 150
		if velocity.x < 0:
			$AnimatedSprite2D.scale.x = 1
		elif velocity.x > 0:
			$AnimatedSprite2D.scale.x = -1
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if is_on_floor():
			$AnimatedSprite2D.play("idle")
			
	if is_on_ceiling():
		velocity.y = 100 # Force the player to fall down
		is_jumping = false
		modified_gravity = gravity

	if is_on_floor():
		is_jumping = false
		jump_held = false
		modified_gravity = gravity

	Camera.position.x = position.x
	Camera.position.y = Camera.position.y
	
	move_and_slide()
