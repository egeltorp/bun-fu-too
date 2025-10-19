extends CharacterBody2D

@export var speed: float = 100.0
@export var roam_radius: float = 300.0
@export var time_between_targets: float = 2.0
@export var is_deadly := true

var spawn_position: Vector2
var target_position: Vector2
var timer := 0.0

func _ready():
	spawn_position = global_position
	pick_new_target()

func _physics_process(delta):
	timer += delta
	if timer >= time_between_targets or global_position.distance_to(target_position) < 10:
		pick_new_target()
		timer = 0.0
		
	if is_on_floor():
		target_position.y -= 16 

	# Move toward target
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func pick_new_target():
	var angle = randf_range(0, TAU)  # TAU = 2π
	var distance = randf_range(0, roam_radius)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	target_position = spawn_position + offset
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_deadly:
		if body.has_method("die"):
			body.die()
	else:
		return
