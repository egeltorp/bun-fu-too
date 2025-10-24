extends Node2D

@export var shoot_right: bool = true
@export var fire_time := 2.0
@export var idle_time := 1.0
@export var beam_max_length := 5000
@export var ray_collision_mask := 1

@onready var line = $Line2D
@onready var timer = $Timer
@onready var hitbox = $Hitbox
@onready var shape = $Hitbox/CollisionShape2D.shape

var laser_on := false

func _ready():
    line.visible = false
    hitbox.monitoring = false  # start inactive
    timer.wait_time = idle_time
    timer.start()

func _on_Timer_timeout():
    laser_on = !laser_on
    if laser_on:
        line.visible = true
        hitbox.monitoring = true      # <--- now hitbox goes live
        timer.wait_time = fire_time
    else:
        line.visible = false
        hitbox.monitoring = false     # <--- disable when off
        timer.wait_time = idle_time
    timer.start()

func _physics_process(_delta):
    if laser_on:
        _update_laser()

func _update_laser():
    var muzzle_local = Vector2(shoot_right ? 8 : -8, 0)
    var from_global = to_global(muzzle_local)
    var dir = Vector2(shoot_right ? 1 : -1, 0)
    var to_global_point = from_global + dir * beam_max_length

    var space = get_world_2d().direct_space_state
    var result = space.intersect_ray(from_global, to_global_point, [self], ray_collision_mask)

    var end_global = result.position if result else to_global_point

    # VISUAL beam
    line.points = PackedVector2Array([to_local(from_global), to_local(end_global)])

    # HITBOX auto-resizes
    var length = (end_global - from_global).length()
    shape.size = Vector2(length, 8)  # 8px tall beam
    hitbox.global_position = from_global + (end_global - from_global) * 0.5
    hitbox.rotation = 0  # horizontal only

func _on_Hitbox_body_entered(body):
    if body.has_method("die"):
        body.die()