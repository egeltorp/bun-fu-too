extends Camera2D

@export var target_path: NodePath  # Set this in the editor to point to your player
@export var vertical_deadzone := 0  # Pixels above or below the camera center before it follows
@onready var player = get_node(target_path)

var shake_strength: float = 0.0
var shake_decay: float = 5.0

func _process(delta):
	if not player:
		return

	if shake_strength > 0:
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength = max(shake_strength - shake_decay * delta, 0)
	else:
		offset = Vector2.ZERO

	var player_pos = player.global_position
	var cam_pos = global_position

	# Always follow on X
	cam_pos.x = player_pos.x

	# Only follow on Y if player leaves the deadzone
	var y_diff = player_pos.y - cam_pos.y

	if abs(y_diff) > vertical_deadzone:
		# Move camera toward the player to bring them back within deadzone
		var direction = sign(y_diff)
		cam_pos.y += (abs(y_diff) - vertical_deadzone) * direction

	global_position = cam_pos

func shake(strength: float = 5.0, decay: float = 5.0):
	shake_strength = strength
	shake_decay = decay
