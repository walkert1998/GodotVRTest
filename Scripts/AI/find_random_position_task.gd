class_name FindRandomPositionTask extends BTNode

var npc: NPCInstance
var region_id: RID
var region_layers: int
var distance_radius: float

func _init(parent_npc: NPCInstance, reg_id: RID, layers: int, radius: float) -> void:
	npc = parent_npc
	region_id = reg_id
	distance_radius = radius
	region_layers = layers

func evaluate() -> BTNodeState:
	if node_state == BTNodeState.SUCCEEDED:
		return node_state
	if npc.nav_agent.get_current_navigation_path().is_empty() || npc.nav_agent.is_navigation_finished():
		var rand_pos = NavigationServer3D.region_get_random_point(region_id, region_layers, false)
		npc.nav_agent.target_position = rand_pos
		#print_debug("get new pos " + str(rand_pos))
	if npc.nav_agent.is_target_reachable():
		node_state = BTNodeState.SUCCEEDED
		#print_debug("found reachable target")
	else:
		node_state = BTNodeState.FAILED
		#print_debug("could not find reachable target")
	return node_state

func _to_string() -> String:
	return "FindRandomPositionTask"
