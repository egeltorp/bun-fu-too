extends Node2D

@export var point_a: Vector2
@export var point_b: Vector2
@export var jump_duration: float = 1.0  # seconds
@export var jump_height: float = 50.0   # peak height of the arc

@onready var sprite: Sprite2D = $Sprite2D

var t := 0.0
var going_to_b := true

func _process(delta):
	t += delta / jump_duration
	if t >= 1.0:
		t = 0.0
		going_to_b = !going_to_b

	var start = point_a if !going_to_b else point_b
	var end = point_b if !going_to_b else point_a
	

	# Linear horizontal interpolation
	var pos = start.lerp(end, t)

	# Arc using a simple parabolic curve: y_offset = -(4 * h) * (t - 0.5)^2 + h
	var arc = -4.0 * jump_height * pow(t - 0.5, 2) + jump_height
	pos.y -= arc  # Subtract to make it go "up"

	# Snap to nearest pixel (optional — adjust to your camera zoom if needed)
	pos = pos.round()
	
	#Flipping Sprites + Colliders
	if going_to_b:
		sprite.flip_h = true
	elif !going_to_b:
		sprite.flip_h = false

	global_position = pos
	
	
