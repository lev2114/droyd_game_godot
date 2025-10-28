extends Node2D

@export var shuriken_scene: PackedScene = preload("res://elements/Jewriken/jewrikenProj/jewriken.tscn")
@export var fire_rate: float = 9999
@export var spread_angle: float = 20
@export var count: int = 3
@export var shuriken_speed: float = 550.0
@export var shuriken_damage: int = 1
@export var level: int = 1

@onready var timer: Timer = $Timer
@onready var muzzle: Marker2D = $Muzzle

func _ready() -> void:
	check_level()
	timer.wait_time = fire_rate
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func check_level():
	match level:
		0: fire_rate = INF
		1: shuriken_damage = 1
		2: count = 5
		3: shuriken_damage = 3
		4: pass

func _on_timer_timeout() -> void:
	if level < 4:
		fire_spread()
	else:
		spawn_orbiting_shurikens()
	timer.start()

func get_nearest_enemy() -> CharacterBody2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var nearest: CharacterBody2D = null
	var nearest_dist: float = INF

	for e in enemies:
		var d = global_position.distance_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e

	return nearest

# --- обычная стрельба сюрикена ---
func fire_spread() -> void:
	var target = get_nearest_enemy()
	var base_dir: Vector2

	# если враг найден — летим к нему, иначе просто вперёд
	if target:
		base_dir = (target.global_position - global_position).normalized()
	else:
		base_dir = Vector2.RIGHT.rotated(rotation)

	for i in count:
		var angle_offset = deg_to_rad(randf_range(-spread_angle, spread_angle))
		var s = shuriken_scene.instantiate()
		get_tree().current_scene.add_child(s)
		s.global_position = muzzle.global_position
		s.direction = base_dir.rotated(angle_offset)
		s.speed = shuriken_speed
		s.damage = shuriken_damage

# --- режим 4 уровня: большие вращающиеся сюрикены ---
var orbiting_shurikens: Array = []  # храним текущие орбитальные сюрикены

func spawn_orbiting_shurikens() -> void:
	var orbit_count = 2
	var orbit_radius = 250.0
	var orbit_speed = 0.5  # оборотов в секунду
	orbiting_shurikens.clear()

	for i in orbit_count:
		var s = shuriken_scene.instantiate()
		s.lifetime = 1.2
		get_tree().current_scene.add_child(s)

		s.scale = Vector2(2, 2)
		s.speed = 0.0
		s.damage = shuriken_damage * 3

		var angle = TAU * i / orbit_count
		s.set_meta("angle", angle)
		s.set_meta("radius", orbit_radius)
		s.set_meta("speed", orbit_speed)
		s.global_position = global_position + Vector2(orbit_radius, 0).rotated(angle)

		orbiting_shurikens.append(s)

# Обновляем орбитальные сюрикены каждый кадр
func _process(delta: float) -> void:
	for s in orbiting_shurikens:
		if not is_instance_valid(s):
			continue
		var angle = s.get_meta("angle")
		var radius = s.get_meta("radius")
		var speed = s.get_meta("speed")

		angle += TAU * speed * delta
		s.set_meta("angle", angle)
		s.global_position = global_position + Vector2(radius, 0).rotated(angle)
		s.rotation = angle + PI / 2
