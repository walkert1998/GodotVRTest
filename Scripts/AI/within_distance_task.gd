class_name WithinDistanceTask extends BTNode

var npc: NPCInstance
var distance: float

func _init(parent_npc: NPCInstance, dist: float) -> void:
	npc = parent_npc
	distance = dist

func evaluate() -> BTNodeState:
	if npc.attacking || npc.changing_position:
		node_state = BTNodeState.SUCCEEDED
		return node_state
	if npc.global_position.distance_to(npc.last_known_target_position) <= distance:
		node_state = BTNodeState.SUCCEEDED
		#print("within distance")
	else:
		print("out of range " + str(npc.global_position.distance_to(npc.last_known_target_position)))
		node_state = BTNodeState.FAILED
	return node_state

func _to_string() -> String:
	return "WithinDistanceTask"
