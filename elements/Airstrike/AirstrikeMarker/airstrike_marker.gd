extends Node2D

var projectile_scene: PackedScene
var damage: int
var radius: float
var delay: float

func setup(projectile_scene_: PackedScene, dmg: int, rad: float, delay_: float):
	projectile_scene = projectile_scene_
	damage = dmg
	radius = rad
	delay = delay_
	_show_marker()

func _show_marker():
	var circle = $Sprite2D
	var tween = create_tween()
	tween.tween_property(circle, "modulate:a", 0.6, delay * 0.8)
	await get_tree().create_timer(delay).timeout
	_spawn_projectile()
	queue_free()

func _spawn_projectile():
	var p = projectile_scene.instantiate()
	get_tree().current_scene.add_child(p)
	p.global_position = global_position - Vector2(0, 1500)
	p.target_y = global_position.y
	p.damage = damage
	p.radius = radius
