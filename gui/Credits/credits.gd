extends Control

func _ready() -> void:
	$CloseButton.grab_focus.call_deferred()

func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/MainMenu/MainMenu.tscn")
