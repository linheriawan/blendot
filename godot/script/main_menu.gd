extends Node2D

@onready var options_page: CanvasLayer = get_node("OptionsPage")
@onready var helper = preload("res://script/helper.gd").new()

func _ready():
	options_page.hide()
	
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/world-test.tscn") # Replace with your play scene path

func _on_quit_pressed():
	get_tree().quit()

func _on_options_pressed():
	options_page.show_options()
