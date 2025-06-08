extends Control

signal change_mutation(mutation: float)
signal change_topk(topk: float)

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
	{"mutation": 0.02, "purchased": false, "price": 8},
	{"mutation": 0.03, "purchased": false, "price": 16},
	{"mutation": 0.04, "purchased": false, "price": 24},
	{"mutation": 0.05, "purchased": false, "price": 36},
	{"mutation": 0.10, "purchased": false, "price": 50},
]

var previous_topk_idx: int = 0
var topk_options = [
	{"topk": 0.25, "purchased": true},
	{"topk": 0.10, "purchased": false, "price": 6},
	{"topk": 0.08, "purchased": false, "price": 15},
	{"topk": 0.05, "purchased": false, "price": 20},
	{"topk": 0.04, "purchased": false, "price": 25},
	{"topk": 0.02, "purchased": false, "price": 30},
	{"topk": 0.01, "purchased": false, "price": 60},
	{"topk": 3, "purchased": false, "price": 35},
	{"topk": 2, "purchased": false, "price": 50},
	{"topk": 1, "purchased": false, "price": 75},
]

func _ready() -> void:
	%GenerationLabel.text = "Generation: 0"
	%MoneyLabel.text = "Money: "+str(money)
	for i in range(len(mutation_options)):
		var meta = mutation_options[i]
		%MutationButton.add_item(get_mutation_text(meta), i)
	%MutationButton.select(0)
	for i in range(len(topk_options)):
		var meta = topk_options[i]
		%TopkButton.add_item(get_topk_text(meta), i)
	%TopkButton.select(0)

func get_mutation():
	return mutation_options[%MutationButton.selected]['mutation']

func get_topk():
	return topk_options[%TopkButton.selected]['topk']

func on_new_generation(generation):
	money += 1
	%GenerationLabel.text = "Generation: " + str(generation)
	
func on_population_update(population:int, target: int):
	%PopLabel.text = "Population: "+str(population)
	if target > population:
		%PopLabel.text += "+" + str(target - population)
	add_pop_price = int(pow(add_pop_price_base, target))
	%AddPopButton.text = "Add ($%d)" % add_pop_price
	if population >= 120:
		# Maintain a playable framerate by turning some settings off
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", "Disabled (Fastest)")
		ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", "Disabled (Fastest)")
	elif population >= 70:
		# Optimization - lower MSAA from 4x to 2x when too many cars are on level
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", "2x (Average)")
		# Also lower Texture Filtering from 16x to 4x
		ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", "4x (Fast)")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"next_gen"):
		if not %NextButton.disabled:
			_on_next_button_pressed()

func _on_next_button_pressed() -> void:
	next_gen_requested = true
	%NextButton.disabled = true
	var tween = get_parent().create_tween()
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

var add_pop_price_base: float = 1.125
var add_pop_price: int = 1
signal pop_added
func _on_add_pop_button_pressed() -> void:
	if money >= add_pop_price:
		money -= add_pop_price
		pop_added.emit()

func _on_topk_button_item_selected(index: int) -> void:
	var meta = topk_options[index]
	if meta['purchased']:
		change_topk.emit(meta['topk'])
		previous_topk_idx = index
	else:
		# Buy
		var price = meta['price']
		if money >= price:
			money -= price
			meta['purchased'] = true
			%TopkButton.set_item_text(index, get_topk_text(meta))
			change_topk.emit(meta['topk'])
			previous_topk_idx = index
		else:
			%TopkButton.select(previous_topk_idx)

func get_topk_text(meta) -> String:
	var topk = meta['topk']
	var out: String
	if typeof(topk) == TYPE_INT:
		out = "Top-" + str(int(topk))
	else:
		out = "Top-%d%%" % roundi(topk*100.0)
	if not meta['purchased']:
		out += " ($%d)" % meta['price']
	return out
