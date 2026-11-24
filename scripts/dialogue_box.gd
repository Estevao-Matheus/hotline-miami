extends CanvasLayer

signal dialog_finished

@onready var text_label: RichTextLabel = $Control/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/TextLabel
@onready var name_label: Label = $Control/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var portrait: TextureRect = $Control/PanelContainer/MarginContainer/HBoxContainer/Portrait
@onready var timer: Timer = $Control/Timer

var dialog_array : Array = []
var dialog_index : int = 0 
var is_active : bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _process(delta: float) -> void:
	pass
	
func start_dialog (dialog_lines: Array) -> void:
	dialog_array = dialog_lines
	dialog_index = 0
	is_active = true
	show()
	get_tree().paused = true
	show_line()
	
func show_line() -> void:
	if dialog_index >= dialog_array.size():
		end_dialog()
		return
	var entry = dialog_array[dialog_index]
	name_label.text = entry.get("name", "")
	text_label.text = entry.get("text", "")
	
	if entry.has("icon") and entry["icon"] != null:
		portrait.texture = entry["icon"]
		portrait.show()
	else:
		portrait.hide()
	
	text_label.visible_characters = 0
	timer.start()

func end_dialog() -> void:
	timer.stop()
	is_active = false
	hide()
	get_tree().paused = false
	dialog_finished.emit()
	
func _on_timer_timeout() -> void:
	if text_label.visible_characters < text_label.get_total_character_count():
		text_label.visible_characters += 1
	else:
		timer.stop()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
		
	if event.is_action_pressed("shoot") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		
		if text_label.visible_characters < text_label.get_total_character_count():
			timer.stop()
			text_label.visible_characters = text_label.get_total_character_count()
		else:
			dialog_index += 1
			show_line()
