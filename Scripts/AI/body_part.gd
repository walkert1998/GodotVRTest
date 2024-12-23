class_name BodyPart extends PhysicalBone3D

@export var damage_modifier: float = 1.0
@export var attached_enemy: NPCInstance
@export var severable: bool = false
@export var sever_sound_effects: Array[AudioStream]
@export var special_death_animation_names: Array[String]
@export var sever_effect: ImpactEffect
var severed: bool = false

#func _process(delta: float) -> void:
	#if severed:
		#var bone = attached_enemy.skeleton.get_bone_global_pose(get_bone_id())
		#bone = bone.basis.scaled(Vector3(2,2,2))
		#attached_enemy.skeleton.set_bone_global_pose_override(get_bone_id(), bone, 1.0, true)

func set_parent(par: NPCInstance):
	attached_enemy = par

func damage(amount: int, source) -> int:
	var ret = attached_enemy.damage(int(amount * damage_modifier), source)
	if ret == 2:
		if severable && !severed:
			#var bone = attached_enemy.skeleton.get_bone_global_pose(get_parent().bone_idx)
			#bone = bone.basis.scaled(Vector3(2,2,2))
			#attached_enemy.skeleton.set_bone_global_pose_override(get_parent().bone_idx, bone, 1.0, true)
			attached_enemy.skeleton.set_bone_pose_scale(get_parent().bone_idx, Vector3(0.01, 0.01, 0.01))
			if sever_sound_effects.size() > 0:
				attached_enemy.audio_player.stream = sever_sound_effects[randi_range(0, sever_sound_effects.size() - 1)]
				attached_enemy.audio_player.play()
			if sever_effect:
				sever_effect.spawn(sever_effect.global_position, Vector3.UP)
				sever_effect.scale = Vector3(40,40,40)
			severed = true
		if special_death_animation_names.size() > 0:
			attached_enemy.animation_player.play(attached_enemy.npc_template.animation_library_name + "/" + special_death_animation_names[0])
	return ret
