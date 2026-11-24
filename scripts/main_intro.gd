extends Node2D
@onready var player: CharacterBody2D = $Player
@onready var dialog_box: CanvasLayer = $Dialog_box
@onready var cutscene_player: AnimationPlayer = $Cutscene_Player
@onready var cutscene_trigger: Area2D = $Cutscene_trigger


@export var caminho_level1: String = "res://scenes/level1.tscn"
var retrato_player = preload("res://assets/portraits/PC _ Computer - Hotline Miami 2_ Wrong Number - Mugshots - Biker (Helmet).png")
var retrato_boss = preload("res://assets/portraits/PC _ Computer - Hotline Miami 2_ Wrong Number - Mugshots - Jones.png")

func _ready() -> void:
	$Boss/CollisionShape2D.set_deferred("disabled", true)




func _process(delta: float) -> void:
	pass

func _on_cutscene_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		cutscene_trigger.set_deferred("monitoring", false)
		player.set_physics_process(false)
		player.set_process_unhandled_input(false)
		player.velocity = Vector2.ZERO
		
		cutscene_player.play("intro_cutscene")

func disparar_dialogo_intro() -> void:
	cutscene_player.pause()
	
	var falas_intro = [
		{"name": "PLAYER", "text": "Alguém deixou uma mensagem na secretária eletrônica...", "icon": retrato_player},
		{"name": "PLAYER", "text": "Não era mais pra me chamarem aqui Jones esqueceu?...", "icon": retrato_player},
		{"name": "JONES", "text": "Qaundo voce saiu sabia que iria voltar um dia para cumprir a jornada!.", "icon": retrato_boss},
		{"name": "JONES", "text": "Quando te ajudei a terminar seu caminho eu te avisei, está na hora de terminar o que não foi concluido.", "icon": retrato_boss},
		{"name": "PLAYER", "text": "OK, me de o endereco dele, irei terminar.", "icon": retrato_player},
		{"name": "JONES", "text": "O endereço é na boate. Não deixe testemunhas.", "icon": retrato_boss},
	]
	
	dialog_box.start_dialog(falas_intro)
	await dialog_box.dialog_finished
	
	cutscene_player.play()

func ir_para_level1() -> void:
	get_tree().change_scene_to_file(caminho_level1)
