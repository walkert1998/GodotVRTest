class_name MoveToDestinationTask extends BTNode

var npc: NPCInstance

func _init(parent_npc: NPCInstance) -> void:
	npc = parent_npc

func evaluate() -> BTNodeState:
	if npc.nav_agent.is_target_reached():
		#print_debug("reached target " + str(npc.nav_agent.target_position))
		#print("current_index " + str(npc.nav_agent.get_current_navigation_path_index()))
		node_state = BTNodeState.SUCCEEDED
		npc.stopped = true
		npc.animation_player.play(npc.npc_template.animation_library_name + "/Idle")
	else:
		if npc.stopped:
			npc.stopped = false
		if !npc.animation_player.is_playing():
			npc.animation_player.play(npc.npc_template.animation_library_name + "/Move")
		print("desired distance " + str(npc.nav_agent.target_desired_distance))
		print_debug(npc.nav_agent.distance_to_target())
		node_state = BTNodeState.RUNNING
		#print("still moving " + str(npc.nav_agent.target_position))
	return node_state

func _to_string() -> String:
	return "MoveToDestinationTask"
