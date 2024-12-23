class_name CrouchTask extends BTNode

var npc: NPCInstance

func _init(parent_npc: NPCInstance) -> void:
	npc = parent_npc

func evaluate() -> BTNodeState:
	if !npc.crouching && !npc.attacking && !npc.changing_position:
		npc.changing_position = true
		#if !npc.animation_player.is_playing():
		npc.animation_player.play(npc.npc_template.animation_library_name + "/Crouch")
		node_state = BTNodeState.RUNNING
		print("CROUCH!")
	elif npc.crouching:
		npc.changing_position = false
		node_state = BTNodeState.SUCCEEDED
	return node_state

func _to_string() -> String:
	return "CrouchTask"
