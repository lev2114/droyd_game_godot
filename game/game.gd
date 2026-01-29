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
@export var wave_len: float = 25.0          # длина волны (сек)
@export var interval_start: float = 1.2     # интервал в начале волны
@export var interval_end: float = 0.65      # интервал в конце волны (не ниже разумного)
@export var max_pack: int = 3               # максимум врагов за спавн
@export var power_step: float = 0.20        # прирост силы на каждый tier
@export var base_power: float = 1.0
@export var enemy_power_multiplier := 1.0
var time_passed := 0.0
var spawn_interval := 1.5
var enemies_per_spawn := 1

signal difficulty_tier_changed(tier: int)

var current_tier: int = 0

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

	var view_size = get_viewport_rect().size
	var cam_pos = camera.global_position

	var half_w = view_size.x * 0.5
	var half_h = view_size.y * 0.5

	var spawn_margin = 200  # насколько далеко за экраном

	var side = randi() % 4
	var spawn_position: Vector2

	match side:
		0: # сверху
			spawn_position = Vector2(
				randf_range(cam_pos.x - half_w, cam_pos.x + half_w),
				cam_pos.y - half_h - spawn_margin
			)
		1: # снизу
			spawn_position = Vector2(
				randf_range(cam_pos.x - half_w, cam_pos.x + half_w),
				cam_pos.y + half_h + spawn_margin
			)
		2: # слева
			spawn_position = Vector2(
				cam_pos.x - half_w - spawn_margin,
				randf_range(cam_pos.y - half_h, cam_pos.y + half_h)
			)
		3: # справа
			spawn_position = Vector2(
				cam_pos.x + half_w + spawn_margin,
				randf_range(cam_pos.y - half_h, cam_pos.y + half_h)
			)
			
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_position

	enemy.apply_difficulty(enemy_power_multiplier)
	enemy.give_exp.connect($George.add_exp)

func _ready() -> void:
	var ui = mainUi.instantiate()
	add_child(ui)
	difficulty_tier_changed.connect(ui.on_difficulty_tier_changed)
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
	# tier = сколько полных волн прошло
	var tier := int(time_passed / wave_len)
	var phase := fmod(time_passed, wave_len) / wave_len  # 0..1 внутри волны

	# 1) частота растёт внутри волны, потом сбрасывается (потому что phase снова 0)
	timer.wait_time = lerp(interval_start, interval_end, phase)

	# 2) пачка слегка растёт внутри волны (1..max_pack)
	enemies_per_spawn = clamp(1 + int(phase * float(max_pack - 1)), 1, max_pack)

	# 3) сила растёт только от tier
	enemy_power_multiplier = base_power + float(tier) * power_step

	# 4) событие конца волны: tier увеличился
	if tier != current_tier:
		current_tier = tier
		difficulty_tier_changed.emit(current_tier)

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
