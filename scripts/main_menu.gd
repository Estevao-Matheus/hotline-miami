extends Control

@onready var background: ColorRect = $Background
@onready var logo: TextureRect = $Background/VBoxContainer/Logo

@export var cena_fase: String = "res://scenes/intro.tscn" 
@export var cena_creditos: String = "res://scenes/credits.tscn"

var time: float = 0.0

func _ready() -> void:
	get_tree().paused = false
	#$VBoxContainer/Jogar.grab_focus()

func _process(delta: float) -> void:
	time += delta
	var hue = fmod(time * 0.05, 1.0)
	background.color = Color.from_hsv(hue, 0.75, 0.25)
	
	logo.rotation = sin(time * 2.0) * 0.05
	var pulso = 1.0 + sin(time * 4.0) * 0.03
	logo.scale = Vector2(pulso, pulso)

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file(cena_fase)

func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_creditos_pressed() -> void:
	get_tree().change_scene_to_file(cena_creditos)
