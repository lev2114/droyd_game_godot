extends Node2D

@export var fade_time: float = 0.8
@onready var image: TextureRect = $Image

func _ready():
	image.modulate.a = 0.0
	visible = false

func show_death():
	visible = true
	get_tree().paused = true

	var t = create_tween()
	t.tween_property(image, "modulate:a", 1.0, fade_time)
