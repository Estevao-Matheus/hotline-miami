extends Area2D

@onready var timer: Timer = $Timer
@export var speed:int 
var shooter: Node2D = null
var direction := Vector2.ZERO

func _ready() -> void:
	timer.start()


func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		global_position += velocity * delta

func set_direction(direction: Vector2, weapon_data: WeaponData):
	self.direction = direction
	rotation = direction.angle()
	speed = weapon_data.bullet_speed


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return
	if body.has_method("handle_hit"):
		body.handle_hit()
		queue_free()
	else:
		queue_free()
