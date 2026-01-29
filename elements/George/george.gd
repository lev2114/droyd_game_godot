extends CharacterBody2D

@export var speed: float = 200.0
@export var max_health: int = 30
@export var current_health: int = max_health
@export var experience: int = 0
@export var amount_needed = 100
@export var level = 1
@onready var magnet_area: Area2D = $MagnetArea

signal health_changed(current_health, max_health)
signal lvl_up(level)
signal xp_changed(current_xp: float, xp_to_next: float)

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	add_to_group("player")
	var health_bar = get_tree().get_first_node_in_group("health_bar")
	
	if health_bar:
		health_changed.connect(health_bar.update_health)
		health_changed.emit(current_health, max_health)

func _on_magnet_body_entered(body):
	if body.is_in_group("exp_orb"):
		body.set_target(self)

@warning_ignore("unused_parameter")
func _physics_process(delta: float):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector.x > 0:
		$AnimatedSprite2D.flip_h = false  
	elif input_vector.x < 0:
		$AnimatedSprite2D.flip_h = true

	velocity = input_vector * speed
	move_and_slide()

func take_damage(damage: int) -> void:
	current_health -= damage
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		die()

func add_exp(amount: int) -> void:
	experience += amount
	xp_changed.emit(experience, amount_needed)
	check_exp()

func check_exp() -> void:
	if experience >= amount_needed:
		level += 1
		lvl_up.emit(level)
		experience -= amount_needed
		amount_needed *= 1.5
	xp_changed.emit(experience, amount_needed)

func die() -> void:
	get_tree().paused = true
	get_parent().gameover()
