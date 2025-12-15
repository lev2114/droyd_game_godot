extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

func _on_start_pressed():
	get_tree().paused = false
	queue_free()

func _on_quit_pressed():
	get_tree().quit(0)
