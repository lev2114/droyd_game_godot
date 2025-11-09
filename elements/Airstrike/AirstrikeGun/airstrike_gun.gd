extends Node2D

@export var marker_scene: PackedScene = preload("res://elements/Airstrike/AirstrikeMarker/AirstrikeMarker.tscn")
@export var projectile_scene: PackedScene = preload("res://elements/Airstrike/AirstrikeProjectile/AirstrikeProjectile.tscn")

@export var fire_rate: float = 5.0
@export var delay_before_strike: float = 1.0
@export var explosion_radius: float = 200
@export var damage: int = 5
@export var level: int = 4


@onready var audio = $AudioStreamPlayer2D
@onready var timer: Timer = $Timer

func check_level():
	match level:
		0: fire_rate = INF
		1: fire_rate = 5
		2: fire_rate = 4
		3: 
			fire_rate = 4
			damage = 10
		
		4: fire_rate = 3
	timer.wait_time = fire_rate
	

func _ready():
	check_level()
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	if level < 4:
		call_strike()
	else:
		call_double_strike()
		
func get_nearest_enemy() -> Vector2:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return Vector2(0,0)
	var nearest: CharacterBody2D = null
	var nearest_dist: float = INF
	for e in enemies:
		var dist: float = global_position.distance_to(e.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = e
	return nearest.global_position

func call_strike():
	var pos = get_nearest_enemy()
	var marker = marker_scene.instantiate()
	get_tree().current_scene.add_child(marker)
	audio.playing = true
	marker.global_position = pos
	marker.setup(projectile_scene, damage, explosion_radius, delay_before_strike)

func get_two_nearest_enemies() -> Array:
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemies.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	return enemies.slice(0, min(2, enemies.size()))

func call_double_strike():
	var targets = get_two_nearest_enemies()
	for t in targets:
		var pos = t.global_position
		var marker = marker_scene.instantiate()
		get_tree().current_scene.add_child(marker)
		audio.playing = true
		marker.global_position = pos
		marker.setup(projectile_scene, damage, explosion_radius, delay_before_strike)
	
