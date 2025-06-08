extends Control

var town: Node3D = null

func _ready() -> void:
	$VBoxContainer/StartButton.grab_focus.call_deferred()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/tutorial.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/Credits/credits.tscn")


func _on_start_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://road/main.tscn")
