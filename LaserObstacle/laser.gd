extends Node2D

@export var shoot_right: bool = true
@export var fire_time: float = 2.75 # seconds
@export var idle_time: float = 0.87 * 5 # seconds
@export var beam_max_length: float = 5000.0
@export var ray_collision_mask: int = 1

var can_kill: bool = true 
@export var kill_cooldown: float = 2 # seconds

@onready var line: Line2D = $Line2D
@onready var timer: Timer = $Timer

var laser_on: bool = false

func _ready() -> void:
	timer.timeout.connect(_on_Timer_timeout)
	line.visible = false
	timer.wait_time = idle_time
	timer.start()  # Make sure Timer.timeout is connected

func _on_Timer_timeout() -> void:
	laser_on = !laser_on
	if laser_on:
		$Shoot.play()
		$Idle.stop()
	else:
		$Shoot.stop()
		$Idle.play()
	line.visible = laser_on
	timer.wait_time = fire_time if laser_on else idle_time
	timer.start()

func _physics_process(_delta: float) -> void:
	if not laser_on:
		return
	
	var muzzle_local: Vector2 = Vector2(0, 0) if shoot_right else Vector2(0, 0)
	var from_global: Vector2 = to_global(muzzle_local)
	var dir: Vector2 = Vector2.RIGHT if shoot_right else Vector2.LEFT
	var to_global_point: Vector2 = from_global + dir * beam_max_length

	# Raycast
	var space := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(from_global, to_global_point)
	params.exclude = [self]
	params.collision_mask = ray_collision_mask
	params.collide_with_areas = false

	var result: Dictionary = space.intersect_ray(params)

	var end_global: Vector2 = result["position"] if result else to_global_point

	# VISUAL beam
	line.points = PackedVector2Array([
		to_local(from_global),
		to_local(end_global)
	])

	# INSTANT KILL (with cooldown)
	if can_kill and result and result.has("collider"):
		var target = result.collider
		if target.has_method("die"):
			can_kill = false
			target.die()
			get_tree().create_timer(kill_cooldown).timeout.connect(
			func(): can_kill = true
	)
