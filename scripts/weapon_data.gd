class_name WeaponData
extends Resource

@export var weapon_name: String = "Pistol"
@export var is_automatic: bool = false
@export var fire_rate: float = 0.5
@export var bullet_speed: float = 600.0
@export var hud_icon: Texture2D
@export var walk_animation: StringName = &"walk_pistol"
@export var shoot_animation: StringName = &"shot_pistol"
@export var idle_animation:  StringName = &"idle_pistol"
@export var ammo: int = 20
@export var  pickup_icon: Texture2D
@export var shoot_sound: AudioStream
