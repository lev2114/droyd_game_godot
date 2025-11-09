extends CanvasLayer

@export var fade_time: float = 3
@onready var root_control: Control = $MarginContainer

func _ready() -> void:
	fade_in()
	process_mode = Node.PROCESS_MODE_ALWAYS
	show_death()

func show_death():
	get_tree().paused = true

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func fade_in() -> void:
	root_control.modulate.a = 0.0 
	var tween = create_tween()
	tween.tween_property(root_control, "modulate:a", 1.0, fade_time)
