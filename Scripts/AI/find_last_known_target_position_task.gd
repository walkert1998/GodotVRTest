class_name FindLastKnownTargetPositionTask extends BTNode

var npc: NPCInstance
var map_rid: RID

func _init(parent_npc: NPCInstance, rid: RID) -> void:
	npc = parent_npc
	map_rid = rid

func evaluate() -> BTNodeState:
	if npc.current_target == null:
		node_state = BTNodeState.FAILED
		return node_state
	npc.nav_agent.target_position = NavigationServer3D.map_get_closest_point(map_rid, npc.last_known_target_position)
	#print(npc.nav_agent.target_position)
	if npc.nav_agent.is_target_reachable():
		#print("found last known position")
		node_state = BTNodeState.SUCCEEDED
	else:
		#print("could not find last known position")
		node_state = BTNodeState.FAILED
	return node_state

func _to_string() -> String:
	return "FindLastKnownTargetPositionTask"
