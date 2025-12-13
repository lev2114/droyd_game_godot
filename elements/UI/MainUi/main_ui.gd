extends CanvasLayer

@onready var time_label: Label = $Control/VBoxContainer/Label
@onready var game_timer: Timer = $Timer # если таймер в сцене рядом
@onready var player = get_tree().get_first_node_in_group("player")
@onready var xp_bar: ProgressBar = $Control/VBoxContainer/ProgressBar

var total_time := 0.0

func _ready():
	game_timer.timeout.connect(_on_timer_tick)
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
