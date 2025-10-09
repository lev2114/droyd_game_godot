extends Node2D

@export var bullet_scene: PackedScene = preload("res://elements/bullet/bullet.tscn")
@export var fire_rate: float = 1.0
@export var bullet_speed: float = 500.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = fire_rate
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	var target = get_nearest_enemy()
	if target:
		shoot(target)

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
	
func shoot(target: CharacterBody2D) -> void:
	if bullet_scene == null or target == null:
		return
	
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	var dir = (target.global_position - global_position).normalized()
	bullet.global_position = global_position + dir * 70
	bullet.rotation = atan2(dir.y, dir.x) + PI/2
	bullet.direction = dir
	bullet.speed = bullet_speed
