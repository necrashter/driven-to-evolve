extends Vehicle

func reset():
	super.reset()
	linear_velocity = transform.basis.z * -10

func get_output_length() -> int:
	return 1

func set_inputs(inputs: NDArray) -> void:
	steer_input = inputs.get_float(0)

func _physics_process(delta: float):
	_steer_target = steer_input * STEER_LIMIT
	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	previous_velocity = transform.basis.z * -10
	if (linear_velocity - previous_velocity).length_squared() > 1.0:
		# Sudden velocity change, likely due to a collision.
		# Play an impact sound to give audible feedback.
		$ImpactSound.play()
		set_process_mode.call_deferred(Node.PROCESS_MODE_DISABLED)
	else:
		linear_velocity = transform.basis.z * -10
