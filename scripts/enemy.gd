extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var current_weapon: WeaponData
@export var bullet: PackedScene
@export var target: CharacterBody2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var weapon_drop_scene: PackedScene
var is_dead: bool = false
const SPEED = 300.0

func _ready() -> void:
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	pass
	

func handle_hit():
	print("Inimigo acertado!")
	is_dead = true
	animated_sprite.play("death")
	collision_shape_2d.set_deferred("disabled",true)
	drop_weapon()

func drop_weapon():
	if weapon_drop_scene != null and current_weapon != null:
		var pickup = weapon_drop_scene.instantiate()
		pickup.weapon_data = current_weapon
		pickup.global_position = global_position
		get_parent().call_deferred("add_child", pickup)
	
