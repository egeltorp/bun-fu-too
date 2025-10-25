extends CharacterBody2D

# TWEAKABLE CONSTANTS
const MAX_SPEED = 130.0
const ACCELERATION = 1500.0
const DECELERATION = 1700.0
const AIR_CONTROL = 0.85  # 0 = no air control, 1 = full

#JUMPING LOGIC
const JUMP_CROUCH_MULTIPLIER = 1.328
const GRAVITY = 650.0
const JUMP_VELOCITY = -225
const JUMP_CUT_MULTIPLIER = 0.4

#COYOTE TIME
const MAX_COYOTE_TIME = 0.1
var coyote_time_counter = 0.0

# BASICS
var facing_right := true
var is_dead := false

# GOD MODE
@export var god_mode := false
var cheated := false
@onready var god_mode_label := $"../CanvasLayer/GodMode"

# SPAWN POSITION
var spawn_position: Vector2

# DEPENDENCIES
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tilemap: TileMapLayer = $"../TileMapLayer0"  # if it's a sibling
@onready var camera_2d := $"../Camera2D"

func _ready() -> void:
	spawn_position = global_position  # Save starting location
	is_dead = false
	god_mode_label.visible = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		die(true) # true bool = FORCE death, ignores god_mode
	if Input.is_action_just_pressed("toggle_god_mode"):
		cheated = true
		god_mode = !god_mode
		god_mode_label.visible = god_mode
	if Input.is_action_just_pressed("reload_scene"):
		get_tree().reload_current_scene()
	
	var is_crouching := Input.is_action_pressed("down")
	var _is_jumping := Input.is_action_pressed("jump")

	# Update coyote time counter and jump buffer
	if is_on_floor():
		coyote_time_counter = MAX_COYOTE_TIME  # Reset if on the floor
	else:
		coyote_time_counter -= delta  # Decrease when in air
	
	velocity.y = clamp(velocity.y, -350, 200)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0  # optional: reset Y on floor for snappy jumps

	# Horizontal input
	var direction := Input.get_axis("left", "right")
	var target_speed := direction * MAX_SPEED
	if is_crouching and is_on_floor():
		target_speed *= 0.25

	# Determine acceleration factor
	var accel_factor = ACCELERATION if is_on_floor() else ACCELERATION * AIR_CONTROL
	var decel_factor = DECELERATION if is_on_floor() else DECELERATION * AIR_CONTROL

	# Accelerate or decelerate
	if direction != 0:
		velocity.x = move_toward(velocity.x, target_speed, accel_factor * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, decel_factor * delta)

	# Jumping
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_time_counter > 0):
		if Input.is_action_pressed("down"):
			velocity.y = JUMP_VELOCITY * JUMP_CROUCH_MULTIPLIER
			$JumpSound.play()
		else:
			velocity.y = JUMP_VELOCITY
			$JumpSound.play()
			
	elif Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= JUMP_CUT_MULTIPLIER
			
	# === SPRITE + COLLIDER FLIPPING ===
	if direction != 0:
		var new_facing_right = direction > 0
		if new_facing_right != facing_right:
			facing_right = new_facing_right
			sprite.flip_h = not facing_right
			for shape in [$CollisionShape2D, $CollisionShape2D2]:
				var pos = shape.position
				pos.x *= -1
				shape.position = pos
		
	# === ANIMATION STATES ===
	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0:
		sprite.play("run")
	elif is_crouching:
		sprite.play("crouch")
	else:
		sprite.play("idle")

	# Handle collision + Spikes
	var collision = move_and_slide()
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		var collider = col.get_collider()

		if collider == tilemap:
			var cell_pos = tilemap.local_to_map(col.get_position())
			var tile_data = tilemap.get_cell_tile_data(cell_pos)
			
			if tile_data and tile_data.get_custom_data("isSpike"):
				die()
				return
	
func die(force := false):
	if god_mode and not force:
		return
	if is_dead:
		return
	else:
		camera_2d.shake(2.5, 4.0) # (strength, decay)
		GameTimer.stop()
		print("Player died.")
		is_dead = true
		
		# Disable input
		set_process(false)
		set_physics_process(false)
		
		# Play death sound (assumes you have an AudioStreamPlayer2D named "DeathSound")
		$DeathSound.play()
		
		# Hide the sprite (assumes it's named "AnimatedSprite2D")
		$AnimatedSprite2D.hide()
		
		# Optional: stop all motion
		velocity = Vector2.ZERO
		
		# Wait 1 second, then reload scene
		await get_tree().create_timer(1.0).timeout
		
		print("Respawning.")
		GameTimer.reset()
		global_position = spawn_position
		set_process(true)
		set_physics_process(true)
		$AnimatedSprite2D.show()
		is_dead = false
		
func win():
	print("Win!")
