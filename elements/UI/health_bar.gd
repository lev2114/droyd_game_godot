extends ProgressBar


@onready var timer = $Timer
@onready var damage_bar = $DamageBar


var health = 0 : set = _set_health
var maxHealth = health
var currentHealth = maxHealth

func _set_health(newHealth) -> void:
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
	damage_bar.maxDamage = health
	damage_bar.currentDamage = health
	


func _on_timer_timeout() -> void:
	pass # Replace with function body.
