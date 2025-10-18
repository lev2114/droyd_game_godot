extends CharacterBody2D

@export var speed: float = 130.0
@export var max_hp: int = 2
var hp: int

@export var attack_damage: int = 20

@onready var player: CharacterBody2D = null
var can_attack = true

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemies")
	hp = max_hp

func _on_attack_area_body_entered(body) -> void:
	print("1. Враг: тело вошло в зону - ", body.name)
	
	if body.is_in_group("player"):
		print("2. Враг: это игрок! Вызываем take_damage")
		if body.has_method("take_damage"):
			print("3. Враг: метод take_damage существует!")
			body.take_damage(10)
		else:
			print("3. ОШИБКА: у игрока нет метода take_damage!")
	else:
		print("2. Враг: это НЕ игрок, а - ", body.name)

func take_damage(damage: int) -> void:
	hp -= damage
	if hp <= 0:
		queue_free()

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if player == null:
		return
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
