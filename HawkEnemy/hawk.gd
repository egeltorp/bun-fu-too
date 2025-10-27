extends CharacterBody2D

@export var hawk: bool = true
@export var brick: bool = false
@export var speed: float = 120.0			# movement speed toward the orbit point
@export var orbit_speed: float = 1.0		# angular speed (radians/sec)
@export var semi_major: float = 16.0		# radius // a
@export var eccentricity: float = 0.0		# e in [0, 1), if 0 = perfect circle
@export var rotation_deg: float = 0.0		# rotate ellipse in world space
@export var clockwise: bool = false			# reverse direction if true
@export var is_deadly := true
@export var roam_radius: float = 32.0
@export var time_between_targets: float = 2.0

var spawn_position: Vector2
var orbit_angle: float = 0.0
var target_position: Vector2 = Vector2.ZERO
var timer := 0.0

func _ready():
	spawn_position = global_position

func _physics_process(delta):
	if hawk:
		ellipse_movement(delta)
	elif brick:
		brick_movement(delta)
	move_and_slide()

func ellipse_movement(delta):
		# advance parameter
	var dir := -1.0 if clockwise else 1.0
	orbit_angle = fmod(orbit_angle + dir * orbit_speed * delta, TAU)

	# compute ellipse radii from (a, e): b = a*sqrt(1 - e^2)
	var a = max(semi_major, 0.0)
	var e = clamp(eccentricity, 0.0, 0.999)
	var b = a * sqrt(1.0 - e * e)

	# local ellipse point (centered at origin, unrotated)
	var local := Vector2(cos(orbit_angle) * a, sin(orbit_angle) * b)

	# rotate ellipse in world space by rotation_deg
	var rot := deg_to_rad(rotation_deg)
	var rotated := Vector2(
		local.x * cos(rot) - local.y * sin(rot),
		local.x * sin(rot) + local.y * cos(rot)
	)

	# world-space target on the orbit
	target_position = spawn_position + rotated

	# optional floor fail-safe
	if is_on_floor():
		target_position.y -= 16

	# steer toward orbit point
	var direction := (target_position - global_position)
	if direction.length() > 0.001:
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO
		
func brick_movement(delta):
	timer += delta
	if timer >= time_between_targets or global_position.distance_to(target_position) < 10:
		pick_new_target()
		timer = 0.0
		
	if is_on_floor():
		target_position.y -= 16 

	# Move toward target
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed

func pick_new_target():
	var angle = randf_range(0, TAU)  # TAU = 2π
	var distance = randf_range(0, roam_radius)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	target_position = spawn_position + offset

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_deadly and body.has_method("die"):
		print(name)
		body.die()
