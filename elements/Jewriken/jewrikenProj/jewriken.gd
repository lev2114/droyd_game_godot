extends Area2D

@export var speed: float = 400.0
@export var damage: int = 1
@export var lifetime: float = 5

@onready var Audio = $AudioStreamPlayer

var direction: Vector2

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	position += direction * speed * delta
	rotation += 12 * delta  # красивое вращение

var hitted_bodies: Array = []

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and not hitted_bodies.has(body):
		hitted_bodies.append(body)
		Audio.playing = true

		if body.has_method("take_damage"):
			body.take_damage(damage)
		else:
			body.queue_free()
