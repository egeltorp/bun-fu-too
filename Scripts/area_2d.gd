extends Area2D

@onready var camera = $"../../../Camera2D"

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		camera.reverse_x_offset()
