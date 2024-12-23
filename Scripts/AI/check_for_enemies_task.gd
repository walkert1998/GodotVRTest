class_name CheckForEnemiesTask extends BTNode

var npc: NPCInstance

func _init(parent_npc: NPCInstance) -> void:
	npc = parent_npc

func evaluate() -> BTNodeState:
	if npc.current_target && npc.current_target.current_health > 0:
		node_state = BTNodeState.SUCCEEDED
		return node_state
	#var found_enemy: Entity = null
	for body in npc.fov_area.get_overlapping_bodies():
			if body is Entity:
				if body is PlayerController:
					var dir = npc.global_position.direction_to(body.global_position)
					var facing = -npc.global_transform.basis.z.dot(dir)
					var fov = cos(deg_to_rad(npc.field_of_view))
					print(str(facing) + " " + str(fov))
					if facing > fov:
						var space = npc.get_world_3d().direct_space_state
						var query = PhysicsRayQueryParameters3D.create(npc.vision_point.global_position,
								body.global_position)
						query.collision_mask = npc.collision_mask
						var collision = space.intersect_ray(query)
						if collision:
							if collision["collider"] == body:
								npc.set_target(body)
								npc.last_known_target_position = body.global_position
								npc.has_line_of_sight = true
								node_state = BTNodeState.SUCCEEDED
								return node_state
	npc.has_line_of_sight = false
	node_state = BTNodeState.FAILED
	return node_state

func _to_string() -> String:
	return "CheckForEnemiesTask"
