extends MainNode

func _enter_tree() -> void:
	for o in $RightPanel.mutation_options:
		o['purchased'] = true
	for o in $RightPanel.topk_options:
		o['purchased'] = true
	$RightPanel.add_pop_price_base = 0.0
	$RightPanel._money = 9999999
