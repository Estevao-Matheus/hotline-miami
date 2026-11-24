extends Node2D
@onready var player_detection: Area2D = $PlayerDetection
signal enemy_fired_bullet(bullet, position, direction, weapon_data)
@onready var end_of_gun: Marker2D = $"../EndOfGun"
@onready var cooldown: Timer = $"../Cooldown"
@onready var enemy_body: CharacterBody2D = get_parent()
@onready var animated_sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var patrol_timer: Timer = $PatrolTimer
@onready var navigation_agent_2d: NavigationAgent2D = $"../NavigationAgent2D"
@onready var navigation_timer: Timer = $"../NavigationAgent2D/Navigation_Timer"
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var shoot_sound: AudioStreamPlayer2D = $"../shoot_sound"

signal state_changed(new_state)
enum State{
	PATROL,
	ENGAGE,
	FOLLOW
}
var current_state: State = State.PATROL: set = set_state
var player = null
#Variaveis Patrulha
var origin: Vector2 = Vector2.ZERO
var patrol_location: Vector2 = Vector2.ZERO
var patrol_location_reached: bool = false
	
func _ready() -> void:
	ray_cast_2d.add_exception(enemy_body)
	if enemy_body.current_weapon != null:
		cooldown.wait_time = enemy_body.current_weapon.fire_rate
	set_state(State.PATROL)


func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			if player != null and can_see_player() and !enemy_body.is_dead:
				set_state(State.ENGAGE)
				return
				
			if not patrol_location_reached and !enemy_body.is_dead:
				if navigation_agent_2d.is_navigation_finished():
					patrol_location_reached = true
					enemy_body.velocity = Vector2.ZERO
					animation_player.play(enemy_body.current_weapon.idle_animation)
					animated_sprite.play(enemy_body.current_weapon.idle_animation)
					patrol_timer.start()
					return
				var nex_path_pos = navigation_agent_2d.get_next_path_position()
				var direction = enemy_body.global_position.direction_to(nex_path_pos)
				enemy_body.velocity = direction * 100
				enemy_body.move_and_slide()
				enemy_body.rotation = lerp_angle(enemy_body.rotation, direction.angle(), 10.0 * delta)
				animation_player.play(enemy_body.current_weapon.walk_animation)
				animated_sprite.play(enemy_body.current_weapon.walk_animation)
				
		State.ENGAGE:
			if player != null and !enemy_body.is_dead:
				if not can_see_player():
					set_state(State.FOLLOW)
					return
					
				var angle_to_player = enemy_body.global_position.direction_to(player.global_position)
				enemy_body.rotation = lerp(enemy_body.rotation,angle_to_player.angle(),1.0)
				if abs(angle_difference(enemy_body.rotation,angle_to_player.angle())) < 0.1:
					animation_player.play(enemy_body.current_weapon.shoot_animation)
					animated_sprite.play(enemy_body.current_weapon.shoot_animation)
					shoot()
				else:
					animation_player.play(enemy_body.current_weapon.idle_animation)
					animated_sprite.play(enemy_body.current_weapon.idle_animation)
			else:
				set_state(State.PATROL)	
		State.FOLLOW:
			if player != null and !enemy_body.is_dead:
				if can_see_player() and player_detection.overlaps_body(player):
					navigation_timer.stop()
					set_state(State.ENGAGE)
					return
				navigation_agent_2d.target_position = player.global_position
				
				if not navigation_agent_2d.is_navigation_finished():
					var next_path_position = navigation_agent_2d.get_next_path_position()
					var direction = enemy_body.global_position.direction_to(next_path_position)
					
					enemy_body.velocity = direction * 180
					enemy_body.move_and_slide()
					enemy_body.rotation = lerp(enemy_body.rotation,direction.angle(),1.0)
					animated_sprite.play(enemy_body.current_weapon.walk_animation)
					animation_player.play(enemy_body.current_weapon.walk_animation)

func set_state(new_state: int):
	if new_state == State.PATROL:
		origin = enemy_body.global_position
		patrol_location_reached =true
		patrol_timer.start()
	elif new_state == State.FOLLOW:
		navigation_timer.start()
		
	current_state = new_state
	state_changed.emit(current_state)
	
func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and !enemy_body.is_dead:
		player = body
		if current_state == State.FOLLOW and can_see_player():
			navigation_timer.stop()
			set_state(State.ENGAGE)
		

func shoot() -> void:
	if enemy_body.current_weapon == null or enemy_body.bullet == null:
		return
		
	if cooldown.is_stopped():
		var bullet_instance = enemy_body.bullet.instantiate()
		bullet_instance.shooter = enemy_body
		var direction_to_player = end_of_gun.global_position.direction_to(player.global_position)
		enemy_fired_bullet.emit(bullet_instance, end_of_gun.global_position, direction_to_player, enemy_body.current_weapon)
		cooldown.wait_time = enemy_body.current_weapon.fire_rate
		if enemy_body.current_weapon.shoot_sound != null:
			shoot_sound.stream = enemy_body.current_weapon.shoot_sound
			shoot_sound.play()
		cooldown.start()


func _on_player_detection_body_exited(body: Node2D) -> void:
	if player and body == player and !enemy_body.is_dead:
		if current_state == State.ENGAGE:
			set_state(State.FOLLOW)
		elif current_state == State.PATROL:
			player = null


func _on_patrol_timer_timeout() -> void:
	var random_x = randf_range(-100,+100)
	var random_y = randf_range(-100,+100)
	patrol_location = Vector2(random_x,random_y) + origin
	navigation_agent_2d.target_position = patrol_location
	patrol_location_reached = false


func _on_navigation_timer_timeout() -> void:
	if current_state == State.FOLLOW and !enemy_body.is_dead:
		if not player_detection.overlaps_body(player):
			player = null
		animation_player.play(enemy_body.current_weapon.idle_animation)	
		animated_sprite.play(enemy_body.current_weapon.idle_animation)
		
		set_state(State.PATROL)

func can_see_player() -> bool:
	if player == null:
		return false
	var direction_to_player = ray_cast_2d.global_position.direction_to(player.global_position)
	var distance_to_player = ray_cast_2d.global_position.distance_to(player.global_position)
	ray_cast_2d.target_position = ray_cast_2d.to_local(ray_cast_2d.global_position + direction_to_player * (distance_to_player + 20.0))
	ray_cast_2d.force_raycast_update()
	return ray_cast_2d.get_collider() == player
