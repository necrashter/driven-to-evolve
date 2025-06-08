extends Node

signal objective_complete(objective: ObjectiveLabel)

var auto_reset: bool = false
var green_debug_material := ORMMaterial3D.new()
var red_debug_material := ORMMaterial3D.new()

var best_matrix: NDArray
var best_bias: NDArray
var last_matrix: NDArray
var last_bias: NDArray
var last_top_history

func _ready():
	green_debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	green_debug_material.albedo_color = Color.GREEN
	red_debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	red_debug_material.albedo_color = Color.RED
