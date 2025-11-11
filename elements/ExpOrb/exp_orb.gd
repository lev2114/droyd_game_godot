extends Node2D

@export var exp_amount: int = 10

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_exp(exp_amount)
		queue_free()
