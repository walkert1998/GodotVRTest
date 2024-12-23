class_name FindTargetPositionTask extends BTNode

var npc: NPCInstance

func _init(parent_npc: NPCInstance) -> void:
	npc = parent_npc

func evaluate() -> BTNodeState:
	if npc.current_target == null:
		node_state = BTNodeState.FAILED
		return node_state
	npc.nav_agent.target_position = npc.current_target.global_position
	if npc.nav_agent.is_target_reachable():
		#print("Target location reachable")
		node_state = BTNodeState.SUCCEEDED
	else:
		node_state = BTNodeState.FAILED
	return node_state


func _to_string() -> String:
	return "FindTargetPositionTask"
