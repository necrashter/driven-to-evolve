extends Control

var finish_counter: int = 2

func _ready() -> void:
	$AnimationPlayer.play(&"main")
	$ObjectiveComplete.play()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"main":
		_on_objective_complete_finished()

func _on_objective_complete_finished() -> void:
	finish_counter -= 1
	if finish_counter <= 0:
		queue_free()
