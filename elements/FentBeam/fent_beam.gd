extends Area2D
signal finished

@export var length: float = 1200.0
@export var thickness: float = 100.0
@export var damage: int = 10
@export var dir: Vector2
@export var damage_interval: float = 0.1
@export var duration: float = 5.0
@export var follow_node: Node2D
@export var rotation_offset: float = 0.0   # ← добавили смещение

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var line: Line2D = $Line2D
@onready var fx: CPUParticles2D = $CPUParticles2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var timer: Timer
var elapsed_time: float = 0.0
var base_rotation: float = 0.0

func _ready() -> void:
	var rect := RectangleShape2D.new()
	rect.size = Vector2(length, thickness)
	col.shape = rect
	col.position = Vector2(length / 2, 0)

	line.points = [Vector2.ZERO + dir * 30, Vector2(length, 0)]
	line.width = thickness * 0.9
	line.default_color = Color(0.5, 1.0, 1.0, 0.8)
	_flash_in()

	fx.position = global_position + dir * 30
	fx.emitting = true
	if audio.stream:
		audio.play()

	base_rotation = dir.angle()

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = damage_interval
	timer.timeout.connect(_on_damage_tick)
	timer.start()

	await end()

func _physics_process(delta: float) -> void:
	if follow_node:
		global_transform = follow_node.global_transform
		elapsed_time += delta
		var rotation_speed = TAU / duration
		rotation += base_rotation + rotation_speed * elapsed_time + rotation_offset  # ← вот это всё, что нужно

func _on_damage_tick() -> void:
	deal_damage()

func deal_damage() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("enemies"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
			else:
				body.queue_free()

func end() -> void:
	await get_tree().create_timer(duration).timeout
	timer.stop()
	_flash_out()
	await get_tree().create_timer(0.2).timeout
	emit_signal("finished")
	queue_free()

func _flash_in() -> void:
	var t = create_tween()
	t.tween_property(line, "modulate:a", 1.0, 0.15)

func _flash_out() -> void:
	var t = create_tween()
	t.tween_property(line, "modulate:a", 0.0, 0.25)
	if audio.playing:
		audio.stop()
