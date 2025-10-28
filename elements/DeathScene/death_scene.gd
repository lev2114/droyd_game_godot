extends CanvasLayer

@export var fade_time: float = 0.8

func _ready():
	pass

func show_death():
	get_tree().paused = true
