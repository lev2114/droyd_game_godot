extends Node2D
@export var fall_speed: float = 3000.0
@export var damage: int
@export var target_y: float
@export var radius: float

@onready var sound = $AudioStreamPlayer2D

func _process(delta: float) -> void:
	position.y += fall_speed * delta
	if position.y >= target_y:
		explode()
		set_process(false)

func explode():
	var sprite = $Sprite2D
	var explosion = $ExplosionParticles
	explosion.emitting = true
	sound.play()
	for body in get_tree().get_nodes_in_group("enemies"):
		if global_position.distance_to(body.global_position) <= radius:
			if body.has_method("take_damage"):
				body.take_damage(damage)
	sprite.hide()
	await get_tree().create_timer(0.5).timeout
	queue_free()
