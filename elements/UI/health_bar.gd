extends ProgressBar

@onready var timer = $Timer

func _ready():
	global_position.x -= 38
	global_position.y -= 58
	add_to_group("health_bar")
	
var health = 0 : set = set_health
var maxHealth = health
var currentHealth = maxHealth

func update_health(current_health, max_health):
	value = current_health
	max_value = max_health

func set_health(newHealth) -> void:
	var preveousHealth = health
	health = min(maxHealth, newHealth)
	currentHealth = health
	
	if health <= 0:
		queue_free()

	if health < preveousHealth:
		timer.start()

func init_health(_health) -> void:
	health = _health
	maxHealth = health
	currentHealth = health
	
func _on_timer_timeout() -> void:
	pass # Replace with function body.
