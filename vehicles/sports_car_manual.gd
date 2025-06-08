extends Vehicle

func _ready():
	var mesh: MeshInstance3D = $"low-poly-car/Sports car"
	var mat: StandardMaterial3D = mesh.get_active_material(0).duplicate()
	mat.albedo_color = Color.DARK_RED
	mesh.set_surface_override_material(0, mat)

func _physics_process(delta: float):
	acc_input = Input.get_axis(&"reverse", &"accelerate")
	steer_input = Input.get_axis(&"turn_right", &"turn_left")
	engine_force = acc_input * engine_force_value
	_steer_target = steer_input * STEER_LIMIT
	
	# Increase engine force at low speeds to make the initial acceleration faster.
	var speed := linear_velocity.length()
	if speed < 5.0 and not is_zero_approx(speed) and not is_zero_approx(engine_force):
		engine_force = sign(engine_force) * clampf(engine_force_value * 5.0 / speed, 0.0, 200.0)
	
	if (linear_velocity - previous_velocity).length() > 1.0:
		# Sudden velocity change, likely due to a collision.
		# Play an impact sound to give audible feedback.
		$ImpactSound.play()

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

	previous_velocity = linear_velocity
