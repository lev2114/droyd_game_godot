extends Node2D

@export var beam_scene: PackedScene = preload("res://elements/FentBeam/FentBeam.tscn")
@export var fire_rate: float = 6.0           # время между выстрелами
@export var beam_duration: float = 5.0       # длительность действия луча
@export var beam_range: float = 1000.0       # длина луча
@export var beam_damage: int = 40            # урон
@export var level: int = 1                   # на будущее, для апгрейдов

@onready var timer: Timer = $Timer
@onready var muzzle: Marker2D = $Muzzle      # точка, откуда выходит луч

func _ready() -> void:
	timer.wait_time = fire_rate
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	var target = get_nearest_enemy()
	fire_beam(target)

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

# Создаёт и активирует луч
func fire_beam(target: CharacterBody2D) -> void:
	if beam_scene == null:
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
