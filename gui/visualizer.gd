extends Control

# Example network dimensions
var input_length = 4
var output_length = 3
var num_cars = 1  # Visualize one car at a time

# The network weights and biases
var matrix: NDArray = null
var bias: NDArray = null
var inputs: NDArray = null
var outputs: NDArray = null
var output_names: Array = []

# Drawing parameters
var node_radius = 20
var input_x = 440
var output_x = 640
var top_margin = 100
var vertical_spacing = 100

func _draw():
	if matrix == null or bias == null:
		return
	input_length = matrix.shape()[0]
	output_length = matrix.shape()[1]
	
	var top_margin_output = top_margin + ((input_length-output_length)*vertical_spacing) / 2.0
	
	# Draw connections with weights
	for i in range(input_length):
		var input_pos = Vector2(input_x, top_margin + i * vertical_spacing)
		for j in range(output_length):
			var output_pos = Vector2(output_x, top_margin_output + j * vertical_spacing)
			var weight = matrix.get_float(i, j)
			
			# Map weight magnitude to color and thickness
			var color = Color(0, 1, 0) if weight >= 0 else Color(1, 0, 0)
			var thickness = clamp(abs(weight) * 64.0, 1.25, 5.0)
			
			draw_line(input_pos, output_pos, color, thickness)
	
	# Draw input nodes
	for i in range(input_length):
		var pos = Vector2(input_x, top_margin + i * vertical_spacing)
		var f = inputs.get_float(i)
		var color = Color(0, 1, 0) if f > 0.5 else Color(1, 0, 0)
		draw_circle(pos, node_radius, color)
	
	# Draw output nodes
	for j in range(output_length):
		var pos = Vector2(output_x, top_margin_output + j * vertical_spacing)
		var f = outputs.get_float(j)
		var color = Color.WHITE.lerp(Color.GREEN, f) if f >= 0.0 else Color.WHITE.lerp(Color.RED, -f)
		draw_circle(pos, node_radius, color)
	
	# Optionally draw bias next to output nodes
	var default_font = ThemeDB.fallback_font
	var default_font_size = ThemeDB.fallback_font_size
	for j in range(output_length):
		var output_pos = Vector2(output_x, top_margin_output + j * vertical_spacing)
		
		var text = output_names[j] #"%.2f" % bias.get_float(j)
		draw_string(default_font, output_pos + Vector2(30, 5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)
