class_name DodgeRollTask extends BTNode

var npc: NPCInstance
var started_dodging: bool = false

func _init(parent_npc: NPCInstance) -> void:
	npc = parent_npc

func evaluate() -> BTNodeState:
	if npc.crouching:
		node_state = BTNodeState.FAILED
	elif !npc.changing_position && !started_dodging && !npc.crouching && !npc.animation_player.is_playing():
		npc.animation_player.play(npc.npc_template.animation_library_name + "/DodgeRoll")
		var target_pos_flat = Vector3(npc.last_known_target_position.x, 0, npc.last_known_target_position.z)
		npc.look_at(target_pos_flat, Vector3.UP, false)
		npc.face_current_target(null)
		#var flip = randi_range(0, 1)
		var flip = 1
		#if flip == 0:
			#flip = -1
		npc.movement_speed = 16
		var direction = npc.global_basis.x * 5 * flip
		#print(npc.global_basis.x)
		npc.nav_agent.target_position = npc.global_position + direction
		#print(npc.global_position)
		#print(npc.nav_agent.target_position)
		npc.stopped = false
		npc.changing_position = true
		started_dodging = true
		node_state = BTNodeState.RUNNING
		npc.nav_agent.target_desired_distance = 1.0
		npc.animation_player.speed_scale = 1.25
	elif npc.changing_position && started_dodging:
		node_state = BTNodeState.RUNNING
		#print(npc.nav_agent.distance_to_target())
		if npc.nav_agent.is_navigation_finished() && !npc.animation_player.is_playing():
			#print("Target reached")
			npc.changing_position = false
			npc.movement_speed = npc.npc_template.speed
			npc.animation_player.speed_scale = 1.0
			npc.animation_player.play(npc.npc_template.animation_library_name + "/Idle")
			node_state = BTNodeState.SUCCEEDED
	elif !npc.changing_position && started_dodging:
		npc.changing_position = false
		#npc.animation_player.play(npc.npc_template.animation_library_name + "/Idle")
		node_state = BTNodeState.SUCCEEDED
	started_dodging = npc.changing_position
	#print(str(npc.changing_position) + " " + str(started_dodging))
	#print(npc.nav_agent.distance_to_target())
	return node_state

func _to_string() -> String:
	return "DodgeRollTask"
