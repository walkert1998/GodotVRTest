class_name StandTask extends BTNode

var npc: NPCInstance

func _init(parent_npc: NPCInstance) -> void:
	npc = parent_npc

func evaluate() -> BTNodeState:
	if npc.crouching && !npc.attacking:
		npc.changing_position = true
		npc.animation_player.play(npc.npc_template.animation_library_name + "/StandUp")
		node_state = BTNodeState.RUNNING
		print("STAND UP!")
	elif !npc.crouching:
		npc.changing_position = false
		node_state = BTNodeState.SUCCEEDED
	print(npc.crouching)
	return node_state

func _to_string() -> String:
	return "StandUpTask"
