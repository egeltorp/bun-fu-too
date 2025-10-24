extends RichTextLabel

# Press T to hide Timer

var show_timer := false

func _ready():
	visible = false  # start hidden

func _process(_delta):
	var t = GameTimer.time
	var minutes = int(t / 60)
	var seconds = int(t) % 60
	var ms = int((t - int(t)) * 100)
	text = "%02d:%02d.%02d" % [minutes, seconds, ms]  # ALWAYS fixed width (8 chars)

func _input(event):
	if event.is_action_pressed("toggle_timer"):  # we'll bind this next
		show_timer = !show_timer
		visible = show_timer
