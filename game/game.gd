extends Node2D

@onready var timer = $Timer
@onready var enemy_scene = preload("res://elements/Enemy/Enemy.tscn")
@onready var player = $George
@onready var player_camera = $George/Camera2D
@onready var gameover_scene= preload("res://game/gameover_scene.tscn")
@onready var lvlup_scene = preload("res://elements/UI/LevelUpUI/LevelUp.tscn")

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



func _ready() -> void:
	timer.wait_time = 1
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	spawn_enemy_near_player(player, player_camera)

func _on_timer_timeout() -> void:
	if player:
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
