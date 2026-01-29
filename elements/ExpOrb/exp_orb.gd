extends Node2D

@export var exp_amount: int = 10
@export var magnet_speed: float = 300.0

var target: Node2D = null
func _ready():
	set_physics_process(false)
	add_to_group("exp_orb")

func _process(delta):
	if target and is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		global_position += dir * magnet_speed * delta

func set_target(player: Node2D):
	target = player
	set_physics_process(true)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_exp(exp_amount)
		queue_free()
