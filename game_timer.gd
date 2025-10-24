extends Node

var time := 0.0
var active := true

func _process(delta):
	if active:
		time += delta

func reset():
	print("Timer reset.")
	time = 0.0
	active = true

func stop():
	print("Timer stopped.")
	active = false
