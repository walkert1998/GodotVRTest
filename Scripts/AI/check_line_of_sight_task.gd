class_name CheckLineOfSightTask extends BTNode

var npc: NPCInstance

func _init(parent_npc: NPCInstance) -> void:
	npc = parent_npc

func evaluate() -> BTNodeState:
	if npc.current_target == null:
		node_state = BTNodeState.FAILED
		print("no target to see")
		return node_state
	if npc.current_target.current_health <= 0:
		npc.set_target(null)
		node_state = BTNodeState.FAILED
		return node_state
	if npc.attacking || npc.changing_position:
		npc.last_known_target_position = npc.current_target.global_position
		node_state = BTNodeState.SUCCEEDED
		return node_state
	var dir = npc.global_position.direction_to(npc.current_target.global_position)
	var facing = -npc.global_transform.basis.z.dot(dir)
	var fov = cos(deg_to_rad(npc.field_of_view))
	print(str(facing) + " " + str(fov))
	if facing > fov:
		var space = npc.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(npc.vision_point.global_position,
				npc.current_target.global_position)
		query.collision_mask = npc.collision_mask
		var collision = space.intersect_ray(query)
		if collision:
			print(collision)
			#if collision["collider"] is Entity:
			if collision["collider"] == npc.current_target:
				npc.last_known_target_position = npc.current_target.global_position
				npc.has_line_of_sight = true
				node_state = BTNodeState.SUCCEEDED
				print("have line of sight to target")
				return node_state
	print("no line of sight to target")
	npc.has_line_of_sight = false
	node_state = BTNodeState.FAILED
	return node_state

func _to_string() -> String:
	return "CheckLineOfSightTask"
