extends CanvasLayer

@onready var ammo_label: Label = $Control/MarginContainer/HBoxContainer/ammo_label
@onready var texture_rect: TextureRect = $Control/MarginContainer/HBoxContainer/TextureRect

@export var player: CharacterBody2D

func _ready() -> void:
	if player != null:
		player.ammo_changed.connect(update_hud)
		
		if player.current_weapon != null:
			update_hud(player.current_ammo, player.current_weapon.hud_icon)

func update_hud(current_ammo: int, icon: Texture2D) -> void:
	ammo_label.text = str(current_ammo) 
	if icon != null:
		texture_rect.texture = icon
