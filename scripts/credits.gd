extends Control

@export var cena_menu: String = "res://scenes/main_menu.tscn"

func _ready() -> void:
	get_tree().paused = false

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file(cena_menu)
