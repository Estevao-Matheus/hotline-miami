extends Node2D

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	pass

func handle_bullet_spawned(bullet,position,direction,weapon_data: WeaponData):
	add_child(bullet)
	bullet.global_position = position
	bullet.set_direction(direction,weapon_data)
