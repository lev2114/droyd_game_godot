extends Node2D

@onready var timer = $Timer
@onready var enemy_scene = preload("res://elements/Enemy/Enemy.tscn")
@onready var police_scene = preload("res://elements/Police/Police.tscn")
@onready var player = $George
@onready var player_camera = $George/Camera2D
@onready var gameover_scene= preload("res://game/gameover_scene.tscn")
@onready var lvlup_scene = preload("res://elements/UI/LevelUpUI/LevelUp.tscn")
@onready var mainUi = preload("res://elements/UI/MainUi/MainUI.tscn")
@onready var pause_scene = preload("res://elements/UI/Pause/PauseUI.tscn")
@onready var main_menu_scene = preload("res://elements/UI/MainMenu/MainMenu.tscn")

@export var global_time = 0
@export var enemy_power_multiplier := 1.0
var time_passed := 0.0
var spawn_interval := 1.5
var enemies_per_spawn := 1

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		open_pause()

func open_pause():
	if get_tree().paused:
		return
	var pause_ui = pause_scene.instantiate()
	add_child(pause_ui)


@warning_ignore("shadowed_variable")
func spawn_enemy_near_player(player: Node2D, camera: Camera2D) -> void:
	if not player or not is_instance_valid(player):
		return

	var visible_size = get_viewport_rect().size

	var half_width = visible_size.x * 0.5
	var half_height = visible_size.y * 0.5
	var camera_center = camera.global_position

	var spawn_position: Vector2

	while true:
		var x = randf_range(camera_center.x - half_width, camera_center.x + half_width)
		var y = randf_range(camera_center.y - half_height, camera_center.y + half_height)
		spawn_position = Vector2(x, y)

		if spawn_position.distance_to(player.global_position) >= 500:
			break

	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_position

	enemy.apply_difficulty(enemy_power_multiplier)
	enemy.give_exp.connect($George.add_exp)

func _ready() -> void:
	var ui = mainUi.instantiate()
	add_child(ui)
	var menu = main_menu_scene.instantiate()
	add_child(menu)
	timer.wait_time = 1
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	spawn_enemy_near_player(player, player_camera)


func _process(delta):
	time_passed += delta
	update_difficulty()

func update_difficulty():
	var stage := int(time_passed / 30.0)

	enemies_per_spawn = 1 + stage
	enemy_power_multiplier = 1.0 + stage * 0.25

	timer.wait_time = max(0.25, 1.2 - stage * 0.1)

func _on_timer_timeout():
	for i in enemies_per_spawn:
		spawn_enemy_near_player(player, player_camera)

func gameover() -> void:
	add_child(gameover_scene.instantiate())

@warning_ignore("unused_parameter")
func _on_george_lvl_up(level: Variant) -> void:
	var ui = lvlup_scene.instantiate()
	get_tree().current_scene.add_child(ui)
	ui.upgrade_chosen.connect(_on_upgrade_selected)

func _on_upgrade_selected(upgradeName: String):
	get_tree().paused = false
	var weapon = $George.get_node(upgradeName)
	weapon.upgrade()
