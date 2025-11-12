extends Node2D

@export var bullet_scene: PackedScene = preload("res://elements/RegularGun/bullet/bullet.tscn")
@export var fire_rate: float = 1
@export var bullet_speed: float = 500.0
@export var level: int = 1
@export var is_enemy_gun: bool = true
@onready var timer: Timer = $Timer

func _ready() -> void:
	var parent = get_parent()
	if parent and parent.is_in_group("enemies"):
		is_enemy_gun = true
	elif parent and parent.is_in_group("player"):
		is_enemy_gun = false
	
	timer.wait_time = fire_rate
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	print("GUN READY:", get_parent().name, "is_enemy_gun =", is_enemy_gun)

func _on_timer_timeout() -> void:
	if is_enemy_gun:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			shoot(player)
		return 
	else:
		var enemies = get_tree().get_nodes_in_group("enemies")
		if enemies.is_empty():
			return

	match level:
		1:
			var target = get_nearest_enemy()
			if target:
				shoot(target)
		2, 3:
			var target = get_nearest_enemy()
			if target:
				shoot(target)
				await get_tree().create_timer(0.1).timeout
				shoot(target) # второй выстрел
		4:
			var targets = get_two_nearest_enemies()
			for t in targets:
				shoot(t)
				await get_tree().create_timer(0.1).timeout
				shoot(t)

func get_nearest_enemy() -> CharacterBody2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	var nearest: CharacterBody2D = null
	var nearest_dist: float = INF
	for e in enemies:
		var dist: float = global_position.distance_to(e.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = e
	return nearest

func get_two_nearest_enemies() -> Array:
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemies.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	return enemies.slice(0, min(2, enemies.size()))

func shoot(target: CharacterBody2D) -> void:
	if bullet_scene == null or target == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	var dir = (target.global_position - global_position).normalized()
	bullet.global_position = global_position + dir * 30.0
	bullet.direction = dir
	bullet.speed = bullet_speed
	bullet.rotation = atan2(dir.y, dir.x) + PI / 2

	# увеличенный урон только на 3 уровне
	if level >= 3:
		bullet.damage *= 2
	
	# --- ЭФФЕКТЫ ---
	# звук
	var audio = $AudioStreamPlayer2D
	audio.pitch_scale = randf_range(0.95, 1.05) # лёгкое разнообразие
	audio.play()

	# вспышка
	var flash = $Sprite2D
	flash.rotation = atan2(dir.y, dir.x)
	flash.global_position = global_position + dir * 30.0
	flash.modulate.a = 1.0
	await get_tree().create_timer(0.05).timeout  # длительность вспышки
	flash.modulate.a = 0.0
	
	bullet.is_enemy_bullet = is_enemy_gun
