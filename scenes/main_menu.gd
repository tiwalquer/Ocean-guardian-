extends Control

@onready var pop_up = $popUp


func _ready() -> void:
	
	$VBoxContainer/StartButton.grab_focus()
	
	
func _on_start_button_pressed() -> void: 
	
	$VBoxContainer.hide() 
	pop_up.show()

func _on_exit_button_pressed() -> void:
	# Fecha a aplicação
	get_tree().quit()


func _process(delta: float) -> void:
	pass

func _on_history_button_pressed() -> void:
	
	get_tree().change_scene_to_file("res://scenes/history_mode.tscn")

func _on_infinite_button_pressed() -> void:
	
	get_tree().change_scene_to_file("res://Scene/Mapa.tscn")


func _on_voltar_pressed() -> void:
	pop_up.hide()
	$VBoxContainer.show() 
