class_name MeleeAttackTask extends BTNode

var npc: NPCInstance
var started_attacking: bool

func _init(parent_npc: NPCInstance) -> void:
	npc = parent_npc
	started_attacking = false

func evaluate() -> BTNodeState:
	if !npc.attacking && !started_attacking && !npc.changing_position && npc.has_line_of_sight:
		#print("start melee attacking")
		npc.stopped = true
		npc.melee_attack()
		node_state = BTNodeState.RUNNING
		#npc.attack()
	if npc.attacking:
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
	return "MeleeAttackTask"
