extends Node

var time := 0.0
var active := true

func _process(delta):
	if active:
		time += delta

func reset():
	time = 0.0
	active = true

func stop():
	active = false
