extends CharacterBody2D

signal player_fired_bullet(bullet,position,direction,WeaponData)
signal ammo_changed(current_ammo: int, icon: Texture2D)


@export var bullet :PackedScene
@onready var end_of_gun: Marker2D = $EndOfGun
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cooldown: Timer = $Cooldown
@onready var shoot_sound: AudioStreamPlayer2D = $shoot_sound

@export var current_weapon: WeaponData
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var shooting: bool = false
var is_dead: bool = false
var current_ammo = 0
var nearby_weapon: WeaponDrop = null

func _ready() -> void:
	add_to_group("player")
	if current_weapon != null:
		cooldown.wait_time = current_weapon.fire_rate
		current_ammo = current_weapon.ammo
		ammo_changed.emit(current_ammo, current_weapon.hud_icon)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		direction = direction.normalized()
		velocity = direction * SPEED
		if not shooting:
			animation_player.play(current_weapon.walk_animation)
			animated_sprite.play(current_weapon.walk_animation)
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	if current_weapon != null and current_weapon.is_automatic and !is_dead:
		if Input.is_action_pressed("shoot") and current_ammo > 0:
			shoot()
	look_at(get_global_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("shoot") and current_ammo > 0 and !is_dead:
		shoot()
	if event.is_action_pressed("pick up"):  
		if nearby_weapon != null:
			print("Apertei botão direito! Arma próxima: ", nearby_weapon)
			equip_weapon(nearby_weapon.weapon_data)
			nearby_weapon.queue_free()
			nearby_weapon = null
	if event.is_action_pressed("restart"):
			if is_dead:
				get_tree().reload_current_scene()
			else:
				return
func shoot (): 
	if cooldown.is_stopped():
		shooting = true
		var bullet_instance = bullet.instantiate()
		var direction_to_mouse = Vector2.RIGHT.rotated(global_rotation)
		emit_signal("player_fired_bullet", bullet_instance, end_of_gun.global_position,direction_to_mouse,current_weapon)
		animation_player.play(current_weapon.shoot_animation)
		animated_sprite.play(current_weapon.shoot_animation)
		current_ammo -= 1
		ammo_changed.emit(current_ammo, current_weapon.hud_icon)
		if current_weapon.shoot_sound != null:
			shoot_sound.stream = current_weapon.shoot_sound
			shoot_sound.play()
		cooldown.start()
	else:
		shooting = false

func handle_hit():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false) 
	$CollisionShape2D.set_deferred("disabled", true)
	animated_sprite.play("dead")
	
func equip_weapon(new_weapon: WeaponData) -> void:
	if new_weapon == null:
		return
		
	current_weapon = new_weapon
	cooldown.wait_time = current_weapon.fire_rate
	current_ammo = current_weapon.ammo
	animation_player.play(current_weapon.walk_animation)
	ammo_changed.emit(current_ammo, current_weapon.hud_icon)


func _on_cooldown_timeout() -> void:
	shooting = false
	
