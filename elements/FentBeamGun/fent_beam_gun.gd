extends Node2D

@export var beam_scene: PackedScene = preload("res://elements/FentBeam/FentBeam.tscn")
@export var fire_rate: float = 6         # время между выстрелами
@export var beam_duration: float = 5.0  # длительность действия луча 
@export var beam_range: float = 1000.0       # длина луча
@export var beam_damage: int = 40            # урон
@export var level: int = 1  # на будущее, для апгрейдов
@export var charge_time = 2.8            

@onready var timer: Timer = $Timer
@onready var muzzle: Marker2D = $Muzzle     # точка, откуда выходит луч
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	timer.wait_time = fire_rate
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	var target = get_nearest_enemy()
	if not target:
		return

	# Фаза зарядки: звук и свечение
	play_charge_effect()
	await get_tree().create_timer(charge_time).timeout

	# Создаём луч
	if not is_instance_valid(target) or not target.is_inside_tree():
		target = get_nearest_enemy()
		fire_beam(target)
	else: 
		fire_beam(target)


	# Вибрация камеры
	trigger_camera_shake(10, 5)

	timer.start()

func play_charge_effect() -> void:
	audio_player.play()
	# можно добавить лёгкое свечение у дула:
	var tween = create_tween()
	tween.tween_property(muzzle, "modulate", Color(1.5, 1.2, 1.2), charge_time).as_relative()

# Ищет ближайшего врага по расстоянию
func get_nearest_enemy() -> CharacterBody2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var nearest: CharacterBody2D = null
	var nearest_dist: float = INF

	for e in enemies:
		var dist = global_position.distance_to(e.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = e

	return nearest

func trigger_camera_shake(intensity: float, duration: float) -> void:
	# ищем первую попавшуюся камеру
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return

	var original_offset = camera.offset
	var time := 0.0

	while time < duration:
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		camera.offset = offset
		await get_tree().process_frame
		time += get_process_delta_time()

	camera.offset = original_offset

# Создаёт и активирует луч
func fire_beam(target: CharacterBody2D) -> void:
	if (beam_scene == null) or (target == null):
		return

	var beam = beam_scene.instantiate()
	get_tree().current_scene.add_child(beam)
	
	var dir = (target.global_position - global_position).normalized()
	# позиция и направление
	beam.global_position = muzzle.global_position

	if target:
		beam.rotation = dir.angle()
		muzzle.rotation = dir.angle()
	else:
		# если врагов нет — стреляем прямо вперёд
		beam.rotation = rotation

	# передаём параметры
	beam.length = beam_range
	beam.damage = beam_damage
	beam.dir = dir
	beam.duration = beam_duration
	beam.follow_node = muzzle  # луч следует за пушкой

	# перезапуск таймера
	timer.start()
