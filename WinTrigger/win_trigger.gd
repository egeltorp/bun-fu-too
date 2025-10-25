extends Node2D

var has_won: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("win") and !has_won:
		# makes sure win trigger won't get spammed
		has_won = true
		
		# basically just prints "Win!" in chat
		# it's a cheap way to make sure only player can win the game
		body.win()
		
		$"../CanvasLayer/Win!".show()
		
		# timer funcs
		GameTimer.stop()
		save_time_to_file(GameTimer.time)
		
func save_time_to_file(time_value: float):
	var file_path = "user://speedruns.txt"

	# Format time to 4 decimals
	var time_string = "%.4f" % time_value
	if $"../Player".cheated:
		time_string += "  (GOD MODE)"

	# Load old times but STRIP numbering + labels
	var times: Array = []
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var raw_lines = file.get_as_text().split("\n", false)
		file.close()

		for line in raw_lines:
			if line.strip_edges() == "":
				continue
			# Remove leading "1. " / "2. " etc. before we store raw value
			var clean = line.split(". ", true, 1)
			if clean.size() > 1:
				times.append(clean[1])
			else:
				times.append(line)

	# Add new time
	times.append(time_string)

	# Sort numerically (float parse BEFORE any "(GOD MODE)")
	times.sort_custom(func(a, b):
		return float(a.split(" ")[0]) < float(b.split(" ")[0])
	)

	# Keep only top 10
	if times.size() > 10:
		times = times.slice(0, 10)

	# Write clean numbered results back
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	for i in range(times.size()):
		file.store_string(str(i + 1) + ". " + times[i] + "\n")
	file.close()

	print("Saved run:", time_string)
