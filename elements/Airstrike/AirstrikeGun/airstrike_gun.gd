extends Node2D

@export var marker_scene: PackedScene = preload("res://elements/Airstrike/AirstrikeMarker/AirstrikeMarker.tscn")
@export var projectile_scene: PackedScene = preload("res://elements/Airstrike/AirstrikeProjectile/AirstrikeProjectile.tscn")

@export var fire_rate: float = 5.0
@export var delay_before_strike: float = 1.0
@export var explosion_radius: float = 200
@export var damage: int = 10
@export var level: int = 1


@onready var audio = $AudioStreamPlayer2D
@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = fire_rate
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

func call_double_strike():
	for i in range(2):
		await get_tree().create_timer(0.2 * i).timeout
		call_strike()
