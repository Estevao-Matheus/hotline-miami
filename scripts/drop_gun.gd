extends Area2D
class_name WeaponDrop
@export var weapon_data: WeaponData
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if weapon_data != null and weapon_data.pickup_icon != null:
		sprite.texture = weapon_data.pickup_icon
	rotation = randf_range(0, TAU)

func _on_body_entered(body: Node2D) -> void:
	print("Algo entrou no WeaponDrop: ", body.name, " | Grupos: ", body.get_groups())
	if body.is_in_group("player"):
		body.nearby_weapon = self

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.nearby_weapon == self:
		body.nearby_weapon = null
