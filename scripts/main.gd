extends Node2D

@onready var bullet_manager: Node2D = $BulletManager
@onready var player: CharacterBody2D = $Player
@onready var dialog_box: CanvasLayer = $Dialog_box
@onready var cutscene_player: AnimationPlayer = $CutscenePlayer
@onready var cutscene_trigger: Area2D = $Cutscene_trigger
@onready var boss: CharacterBody2D = $Inimigos/Boss


var retrato_player = preload("res://assets/portraits/PC _ Computer - Hotline Miami 2_ Wrong Number - Mugshots - Biker (Helmet).png")
var retrato_chefe = preload("res://assets/portraits/1.png")
var falas = [
		{"name": "Player:", "text": "Vim terminar o que comecei.", "icon": retrato_player}
	]
func _ready() -> void:
	$Inimigos/Boss/CollisionShape2D.set_deferred("disabled", true)
	randomize()
	player.player_fired_bullet.connect(bullet_manager.handle_bullet_spawned)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var ia = enemy.get_node_or_null("IA")
		if ia != null and ia.has_signal("enemy_fired_bullet"):
			ia.enemy_fired_bullet.connect(bullet_manager.handle_bullet_spawned)
	await get_tree().process_frame
	dialog_box.start_dialog(falas)
	await dialog_box.dialog_finished

func _process(delta: float) -> void:
	pass

func disparar_dialogo_final() -> void:
	cutscene_player.pause()
	player.look_at(boss.global_position)
	var falas_final = [
		{"name": "CHEFE", "text": "Depois de tanto tempo eles mandaram você?", "icon": retrato_chefe},
		{"name": "PLAYER:", "text": "Sim, eu vim terminar o que comecei anos atrás.", "icon": retrato_player},
		{"name": "CHEFE", "text": "Quanto estão te pagando eu dobro?", "icon": retrato_chefe},
		{"name": "PLAYER:", "text": "Voce sabe que dinheiro nao me tiraria da aposentadoria, agora já chega voce ja falou demais.", "icon": retrato_player},
		{"name": "CHEFE", "text": "Entao faca logo o que tem que  fazer", "icon": retrato_chefe},
	]
	dialog_box.start_dialog(falas_final)
	await dialog_box.dialog_finished
	cutscene_player.play() 

func mudar_para_proxima_cena() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _on_cutscene_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		cutscene_trigger.set_deferred("monitoring", false)
		$Inimigos/Boss/CollisionShape2D.set_deferred("disabled", false)
		player.set_physics_process(false)
		player.set_process_unhandled_input(false)
		player.velocity = Vector2.ZERO
		
		player.look_at(boss.global_position)
		boss.look_at(player.global_position)
		
		cutscene_player.play("final_cutscene")
