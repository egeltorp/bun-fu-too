extends Node2D

@export var shoot_right: bool = true
@export var fire_time := 2.0        # seconds of firing
@export var idle_time := 1.0        # seconds laser is off
@export var beam_max_length := 5000
@export var ray_collision_mask := 1 # layer that tilemap is on
@onready var line = $Line2D
@onready var timer = $Timer

var laser_on := false

func _ready():
    line.visible = false
    timer.wait_time = idle_time
    timer.start()

func _on_Timer_timeout():
    laser_on = !laser_on
    if laser_on:
        line.visible = true
        timer.wait_time = fire_time
    else:
        line.visible = false
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
    var result = space.intersect_ray(
        from_global, to_global_point,
        [self], ray_collision_mask
    )

    var end_global = result.position if result else to_global_point
    line.points = PackedVector2Array([
        to_local(from_global),
        to_local(end_global)
    ])