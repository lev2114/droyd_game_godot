extends CharacterBody2D

@export var speed: float = 130.0
@onready var player: CharacterBody2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemies")

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = (direction * speed)
	move_and_slide()
