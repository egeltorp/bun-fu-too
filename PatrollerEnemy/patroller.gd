extends CharacterBody2D

const GRAVITY = 650.0

@export var is_deadly := true
@export var speed := 50
@export var patrol_range := 64 # pixels left + right relative to start

var start_pos: Vector2
var direction := 1

func _ready():
	start_pos = global_position

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	$AnimatedSprite2D.play("walk")
	$AnimatedSprite2D.flip_h = direction == -1
	
	# reverse if exceeded patrol bounds
	if direction == 1 and global_position.x > start_pos.x + patrol_range:
		direction = -1
	elif direction == -1 and global_position.x < start_pos.x - patrol_range:
		direction = 1

	velocity.x = direction * speed
	move_and_slide()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_deadly:
		if body.has_method("die"):
			body.die()
	else:
		return
