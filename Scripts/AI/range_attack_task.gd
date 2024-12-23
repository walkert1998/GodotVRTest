class_name RangeAttackTask extends BTNode

var npc: NPCInstance
var started_attacking: bool

func _init(parent_npc: NPCInstance) -> void:
	npc = parent_npc
	started_attacking = false

func evaluate() -> BTNodeState:
	#print("Changing position: " + str(npc.changing_position))
	#print(str(npc.attacking) + " " + str(npc.has_line_of_sight) + " " + str(npc.changing_position))
	if !npc.attacking && !started_attacking && !npc.changing_position && npc.has_line_of_sight:
		#print("Attacking status: " + str(npc.attacking))
		npc.stopped = true
		npc.ranged_attack()
		node_state = BTNodeState.RUNNING
		#npc.attack()
	elif npc.attacking:
		node_state = BTNodeState.RUNNING
	elif !npc.current_target || !npc.has_line_of_sight:
		#print("No line of sight, not attacking")
		node_state = BTNodeState.FAILED
	elif !npc.attacking && started_attacking:
		node_state = BTNodeState.SUCCEEDED
	else:
		node_state = BTNodeState.FAILED
	started_attacking = npc.attacking
	return node_state

func _to_string() -> String:
	return "RangeAttackTask"
