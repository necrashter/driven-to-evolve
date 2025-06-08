extends Panel

var current: int = 0
var data: Array
var objective: ObjectiveLabel = null

func _ready() -> void:
	Global.objective_complete.connect(on_objective_complete)

func prepare(new_data: Array) -> void:
	data = new_data
	enable_datum(data[current])

func enable_datum(datum: Dictionary) -> void:
	if datum.has("callback"):
		datum['callback'].call()
	if datum.has("text"):
		%RichTextLabel.text = datum["text"]
		show()
	elif datum.has("objective"):
		objective = datum["objective"]
		if objective.button_pressed:
			next()

func _on_ok_button_pressed() -> void:
	hide()
	next()

func next():
	current += 1
	if current < len(data):
		enable_datum(data[current])

func on_objective_complete(completed_objective) -> void:
	if completed_objective == objective:
		objective = null
		next()
