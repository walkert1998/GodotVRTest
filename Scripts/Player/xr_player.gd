extends CharacterBody3D

# Helper variables to keep our code readable
@onready var origin_node = $XROrigin3D
@onready var camera_node = $XROrigin3D/XRCamera3D
@onready var neck_position_node = $XROrigin3D/XRCamera3D/Neck

func _process_on_physical_movement(delta) -> bool:
  # Remember our current velocity, we'll apply that later
	var current_velocity = velocity

  # Start by rotating the player to face the same way our real player is
	var camera_basis: Basis = origin_node.transform.basis * camera_node.transform.basis
	var forward: Vector2 = Vector2(camera_basis.z.x, camera_basis.z.z)
	var angle: float = forward.angle_to(Vector2(0.0, 1.0))

  # Rotate our character body
	transform.basis = transform.basis.rotated(Vector3.UP, angle)

  # Reverse this rotation our origin node
	origin_node.transform = Transform3D().rotated(Vector3.UP, -angle) * origin_node.transform

  # Now apply movement, first move our player body to the right location
	var org_player_body: Vector3 = global_transform.origin
	var player_body_location: Vector3 = origin_node.transform * camera_node.transform * neck_position_node.transform.origin
	player_body_location.y = 0.0
	player_body_location = global_transform * player_body_location

	velocity = (player_body_location - org_player_body) / delta
	move_and_slide()

  # Now move our XROrigin back
	var delta_movement = global_transform.origin - org_player_body
	origin_node.global_transform.origin -= delta_movement

  # Return our value
	velocity = current_velocity

	if (player_body_location - global_transform.origin).length() > 0.01:
		# We'll talk more about what we'll do here later on
		return true
	else:
		return false

func _get_movement_input() -> Vector2:
  # Implement this to return requested directional movement in meters per second.
	return Vector2()

func _process_movement_on_input(delta):
	var movement_input = _get_movement_input()
	var direction = global_transform.basis * Vector3(movement_input.x, 0, movement_input.y)
	if direction:
		velocity.x = direction.x
		velocity.z = direction.z
	else:
		velocity.x = move_toward(velocity.x, 0, delta)
		velocity.z = move_toward(velocity.z, 0, delta)

	move_and_slide()

func _get_rotational_input() -> float:
  # Implement this function to return rotation in radians per second.
	return 0.0

func _process_rotation_on_input(delta):
	rotation.y += _get_rotational_input() * delta

func _physics_process(delta):
	var is_colliding = _process_on_physical_movement(delta)
	if !is_colliding:
		_process_rotation_on_input(delta)
		_process_movement_on_input(delta)
