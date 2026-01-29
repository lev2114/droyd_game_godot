extends CanvasLayer

@onready var time_label: Label = $Control/VBoxContainer/Label
@onready var game_timer: Timer = $Timer # если таймер в сцене рядом
@onready var player = get_tree().get_first_node_in_group("player")
@onready var xp_bar: ProgressBar = $Control/VBoxContainer/ProgressBar
@onready var msg: Label = $Control/MessageLabel
var total_time := 0.0

func _ready():
	game_timer.timeout.connect(_on_timer_tick)
	msg.visible = false
	if player:
		player.xp_changed.connect(_on_xp_changed)
		_on_xp_changed(player.experience, player.amount_needed)

func _on_timer_tick():
	total_time += game_timer.wait_time
	_update_time_label()

func _update_time_label():
	var minutes = int(total_time / 60)
	var seconds = int(total_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

func _on_xp_changed(current_xp: float, xp_to_next: float):
	xp_bar.max_value = xp_to_next
	xp_bar.value = current_xp

@warning_ignore("unused_parameter")
func on_difficulty_tier_changed(tier: int):
	show_message("Враги стали сильнее")

func show_message(text: String):
	msg.text = text
	msg.visible = true

	# начинаем с нуля
	msg.modulate.a = 0.0

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	# fade in
	tween.tween_property(msg, "modulate:a", 1.0, 0.4)

	# подержать
	tween.tween_interval(0.8)

	# fade out
	tween.tween_property(msg, "modulate:a", 0.0, 0.4)

	# в конце скрыть
	tween.tween_callback(func():
		msg.visible = false)
		
