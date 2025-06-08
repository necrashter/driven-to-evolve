extends Vehicle

func get_output_length() -> int:
	return 1

func set_inputs(inputs: NDArray) -> void:
	steer_input = inputs.get_float(0)

func _physics_process(delta: float):
	_steer_target = steer_input * STEER_LIMIT
	
	if (linear_velocity - previous_velocity).length_squared() > 25.0:
		# Sudden velocity change, likely due to a collision.
		# Play an impact sound to give audible feedback.
		$ImpactSound.play()
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		linear_velocity = transform.basis.z * -10

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)
	previous_velocity = linear_velocity
