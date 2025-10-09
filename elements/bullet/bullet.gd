extends Area2D

@export var speed: float = 500.0
@export var life_time: float = 5.0
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	await get_tree().create_timer(life_time).timeout
	queue_free()

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("enemies"):
		body.queue_free()
		queue_free()
