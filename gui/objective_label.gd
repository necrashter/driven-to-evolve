extends CheckBox
class_name ObjectiveLabel

func complete_objective() -> void:
	self.button_pressed = true
	Global.objective_complete.emit(self)
