extends Control

signal change_mutation(mutation: float)

var _money: int = 30
var money: int:
	get:
		return _money
	set(value):
		_money = value
		%MoneyLabel.text = "Money: " + str(money)

var next_gen_requested: bool = false

var previous_mutation_idx: int = 0
var mutation_options = [
	{"mutation": 0.0, "purchased": true},
	{"mutation": 0.01, "purchased": false, "price": 5},
]

func _ready() -> void:
	%GenerationLabel.text = "Generation: 0"
	%MoneyLabel.text = "Money: "+str(money)
	for i in range(len(mutation_options)):
		var meta = mutation_options[i]
		%MutationButton.add_item(get_mutation_text(meta), i)
	%MutationButton.select(0)

func get_mutation():
	return mutation_options[%MutationButton.selected]['mutation']

func on_new_generation(generation):
	money += 1
	%GenerationLabel.text = "Generation: " + str(generation)
	
func on_population_update(population:int, target: int):
	%PopLabel.text = "Population: "+str(population)
	if target > population:
		%PopLabel.text += "+" + str(target - population)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"next_gen"):
		if not %NextButton.disabled:
			_on_next_button_pressed()

func _on_next_button_pressed() -> void:
	next_gen_requested = true
	%NextButton.disabled = true
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		%NextButton.disabled = false
	)


func _on_mutation_button_item_selected(index: int) -> void:
	var meta = mutation_options[index]
	if meta['purchased']:
		change_mutation.emit(meta['mutation'])
		previous_mutation_idx = index
	else:
		# Buy
		var price = meta['price']
		if money >= price:
			money -= price
			meta['purchased'] = true
			%MutationButton.set_item_text(index, get_mutation_text(meta))
			change_mutation.emit(meta['mutation'])
			previous_mutation_idx = index
		else:
			%MutationButton.select(previous_mutation_idx)

func get_mutation_text(meta) -> String:
	var mutation = meta['mutation']
	var out: String
	if mutation > 0:
		out = str(int(meta['mutation']*100.0)) + "% Mutation"
	else:
		out = "No Mutation"
	if not meta['purchased']:
		out += " ($%d)" % meta['price']
	return out

var add_pop_price: int = 1
signal pop_added
func _on_add_pop_button_pressed() -> void:
	if money >= add_pop_price:
		money -= add_pop_price
		pop_added.emit()
