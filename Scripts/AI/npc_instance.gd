class_name NPCInstance extends Entity

@export var npc_template: NPCTemplate
@export var nav_agent: NavigationAgent3D
@export var audio_player: AudioStreamPlayer3D
@export var weapon_audio_player: AudioStreamPlayer3D
@export var weapon_sounds: Array[AudioStream]
@export var animation_player: AnimationPlayer
@export var current_target: Entity
@export var nav_region: NavigationRegion3D
@export var fov_collider: CollisionShape3D
@export var fov_area: Area3D
@export var vision_point: Node3D
@export var skeleton: Skeleton3D
var root_node: BTSelector

var movement_speed: float = 5.0
var vision_range: float = 20.0
var field_of_view: float = 80.0
var last_known_target_position: Vector3
var attacking: bool = false
var has_line_of_sight: bool = false
var melee_damage: int = 0.0
var projectile_scene: PackedScene
var changing_position: bool = false
var crouching: bool = false
@export var vanish_timer: Timer
@export var projectile_spawn: Node3D
@export var weapon_model_animation_player: AnimationPlayer

signal on_death

var stopped: bool = true
@export var ai_enabled: bool = false
@export var ik_enabled: bool = false

func _ready() -> void:
	spawn()
	build_behavior_tree()

func spawn():
	movement_speed = npc_template.speed
	max_health = npc_template.max_health
	current_health = max_health
	vision_range = npc_template.vision_range
	field_of_view = npc_template.field_of_view
	nav_agent = $NavigationAgent3D
	fov_collider.shape.radius = vision_range
	if npc_template.melee_weapon == null:
		melee_damage = npc_template.unarmed_melee_damage
	else:
		melee_damage = npc_template.melee_weapon.base_damage
	print(npc_template.animation_library_name)
	if skeleton:
		skeleton.animate_physical_bones = true
	#animation_player.play(idle_animation.resource_name)
	for child in get_children():
		if child is BodyPart:
			child.set_parent(self)
	if npc_template.projectile_scene != "":
		projectile_scene = load(npc_template.projectile_scene)

func _physics_process(delta: float) -> void:
	if !ai_enabled:
		return
	# Add the gravity.
	if ai_enabled:
		root_node.evaluate()
	if not is_on_floor():
		velocity += get_gravity() * delta
	var current_location = global_position
	if current_target != null && stopped:
		face_current_target(current_target)
	if nav_agent && !nav_agent.is_navigation_finished():
		#face_current_target(null)
		var next_location = nav_agent.get_next_path_position()
		#print("next location: " + str(next_location))
		var new_velocity = (next_location - current_location).normalized() * movement_speed
		#print(new_velocity)
		#velocity = velocity.move_toward(new_velocity, 0.25)
		#var player_position_flat = player.global_position
		#player_position_flat.y = global_position.y
		var next_loc_flat = next_location
		next_loc_flat.y = global_position.y
		
		#update_target_location(player.global_position)
		if !stopped:
			#animation_player.play(move_animation.resource_name)
			#look_at(next_loc_flat, Vector3.UP)
			if !changing_position:
				var target_pos = global_transform.looking_at(next_loc_flat, Vector3.UP)
				global_transform = global_transform.interpolate_with(target_pos, movement_speed * delta)
			nav_agent.set_velocity(new_velocity)
			#print(velocity)

func update_target_location(target_loc):
	#print(target_loc)
	nav_agent.target_position = target_loc
	#print_debug(nav_agent.distance_to_target())

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if nav_agent == null:
		return
	#if fireball_count >= 3:
		#nav_agent.target_desired_distance = npc_template.melee_attack_range
	#if attack_count >= 3:
	if npc_template.ranged_attack_range > 0 && current_target:
		if has_line_of_sight and !changing_position:
			nav_agent.target_desired_distance = npc_template.ranged_attack_range
		else:
			nav_agent.target_desired_distance = 1.0
	elif current_target && has_line_of_sight:
		nav_agent.target_desired_distance = npc_template.melee_attack_range
	else:
		nav_agent.target_desired_distance = 1.0
	#print(nav_agent.target_desired_distance)
	if !stopped:
		velocity = velocity.move_toward(safe_velocity, 0.25)
		move_and_slide()

func play_pain_sound():
	if npc_template.pain_sounds.size() > 0:
		audio_player.stream = npc_template.pain_sounds[randi_range(0, npc_template.pain_sounds.size() - 1)]
		audio_player.play()

func damage(amount: int, damage_source) -> int:
	if current_health <= 0 || invincible:
		return -1
	#set_player()
	#if !aggroed:
		#aggro()
	current_health = max(0, current_health - amount)
	if current_health == 0:
		#hit_marker.show_hitmarker(true)
		#die()
		$CollisionShape3D.disabled = true
		nav_agent.queue_free()
		ai_enabled = false
		if npc_template.death_sounds.size() > 0:
			audio_player.stream = npc_template.death_sounds[randi_range(0, npc_template.death_sounds.size() - 1)]
			audio_player.play()
		if crouching:
			animation_player.play(npc_template.animation_library_name + "/CrouchDeath")
		else:
			animation_player.play(npc_template.animation_library_name + "/Death")
		#face_current_target(null)
		if vanish_timer:
			vanish_timer.connect("timeout", vanish_body)
			vanish_timer.start(6.0)
		emit_signal("on_death")
		return 2
	#var rand = randi_range(0, 10)
	#if rand <= 5:
		#stagger()
	play_pain_sound()
	if npc_template.pain_animations.size() > 0:
		stagger()
	if damage_source is Entity:
		set_target(damage_source)
	#hit_marker.show_hitmarker()
	return 1

func stagger():
	stop_attacking()
	var rand_anim = npc_template.animation_library_name + "/" + npc_template.pain_animations[randi_range(0, npc_template.pain_animations.size() - 1)]
	if crouching:
		rand_anim = npc_template.animation_library_name + "/" + npc_template.crouching_pain_animations[randi_range(0, npc_template.crouching_pain_animations.size() - 1)]
	#animation_player.stop(false)
	animation_player.play(rand_anim, -1)
	#face_current_target(null)
	nav_agent.target_position = global_position
	stopped = true
	ai_enabled = false
	changing_position = false

func un_stagger():
	ai_enabled = true
	#stopped = false

func ranged_attack() -> int:
	attacking = true
	if animation_player:
		if crouching:
			animation_player.play(npc_template.animation_library_name + "/CrouchShoot")
		else:
			animation_player.play(npc_template.animation_library_name + "/Shoot")
	if weapon_model_animation_player != null:
		weapon_model_animation_player.play("Fire")
	#weapon_audio_player.stream = weapon_sounds[randi_range(0, weapon_sounds.size() - 1)]
	#weapon_audio_player.play()
	return -1

func melee_attack() -> int:
	attacking = true
	if animation_player:
		animation_player.play(npc_template.animation_library_name + "/Melee")
	return -1

func stop_attacking():
	attacking = false
	#print("Stopped attacking!")

func set_target(target_entity: Entity):
	current_target = target_entity
	#print("setting target to " + str(target_entity))
	if current_target == null:
		fov_collider.disabled = false
	else:
		fov_collider.disabled = true

func attack():
	if current_target:
		current_target.damage(1, self)

func range_attack_target():
	var projectile_to_launch: Projectile = projectile_scene.instantiate()
	#projectile_to_launch.projectile_direction = projectile_spawn.global_position.direction_to(player.global_position)
	projectile_to_launch.damage = npc_template.ranged_weapon.loaded_ammo_type.damage
	projectile_to_launch.source = self
	projectile_spawn.look_at(current_target.global_position)
	var spread = deg_to_rad(randf_range(-npc_template.ranged_attack_spread, npc_template.ranged_attack_spread))
	#print(spread)
	projectile_spawn.rotate(Vector3.UP, spread)
	projectile_spawn.rotate(Vector3.RIGHT, spread)
	#print(projectile_spawn.rotation)
	projectile_spawn.add_child(projectile_to_launch)
	projectile_to_launch.reparent(get_tree().root, true)
	weapon_audio_player.stream = npc_template.ranged_weapon.attack_sounds[randi_range(0, npc_template.ranged_weapon.attack_sounds.size() - 1)]
	weapon_audio_player.play()

func melee_attack_target():
	var dir = global_position.direction_to(current_target.global_position)
	var facing = -global_transform.basis.z.dot(dir)
	var fov = cos(deg_to_rad(field_of_view))
	weapon_audio_player.stream = weapon_sounds[randi_range(0, weapon_sounds.size() - 1)]
	weapon_audio_player.play()
	if facing > fov && global_position.distance_to(current_target.global_position) <= npc_template.melee_attack_range:
		if current_target.current_health > 0:
			current_target.damage(melee_damage, self)

func face_current_target(target: Node3D):
	if !ik_enabled:
		return
	var bone_id = skeleton.find_bone("mixamorig_Spine1")
	if target == null:
		skeleton.set_bone_global_pose_override(bone_id, skeleton.global_transform.affine_inverse(), 1.0, false)
	else:
		var bone_pose = skeleton.global_transform * skeleton.get_bone_global_pose_no_override(bone_id)
		bone_pose = bone_pose.looking_at(target.global_position, Vector3.UP, true)
		bone_pose = bone_pose.rotated_local(Vector3.UP, -0.75)
		bone_pose = bone_pose.rotated_local(Vector3.RIGHT, 0.15)
		skeleton.set_bone_global_pose_override(bone_id, skeleton.global_transform.affine_inverse() *  bone_pose, 1.0, true)

func crouch():
	crouching = true
	stopped = true

func stand_up():
	crouching = false
	stopped = false

func build_behavior_tree():
	var wait_for_time_task: WaitForTimeTask = WaitForTimeTask.new(3.0)
	var find_rand_pos_task: FindRandomPositionTask = FindRandomPositionTask.new(self, nav_region.get_region_rid(), nav_agent.navigation_layers, 50.0)
	var move_to_dest_task: MoveToDestinationTask = MoveToDestinationTask.new(self)
	var wander_nodes: Array[BTNode] = [find_rand_pos_task, move_to_dest_task, wait_for_time_task]
	var wander_sequence = BTSequence.new(wander_nodes)
	
	var check_for_enemies_task: CheckForEnemiesTask = CheckForEnemiesTask.new(self)
	var check_line_of_sight_task: CheckLineOfSightTask = CheckLineOfSightTask.new(self)
	var find_target_pos_task: FindTargetPositionTask = FindTargetPositionTask.new(self)
	var find_last_known_pos_task: FindLastKnownTargetPositionTask = FindLastKnownTargetPositionTask.new(self, nav_region.get_navigation_map())
	var within_range_attack_distance_task: WithinDistanceTask = WithinDistanceTask.new(self, npc_template.ranged_attack_range)
	var within_melee_attack_distance_task: WithinDistanceTask = WithinDistanceTask.new(self, npc_template.melee_attack_range)
	var range_attack_task: RangeAttackTask = RangeAttackTask.new(self)
	var melee_attack_task: MeleeAttackTask = MeleeAttackTask.new(self)
	var crouch_task: CrouchTask = CrouchTask.new(self)
	var stand_up_task: StandTask = StandTask.new(self)
	var random_move_options: BTRandomSelector = BTRandomSelector.new([CrouchTask.new(self), SideStepTask.new(self), DodgeRollTask.new(self), StandTask.new(self)])
	var search_sequence: BTSequence = BTSequence.new([find_last_known_pos_task, move_to_dest_task])
	var range_attack_sequence: BTSequence = BTSequence.new([check_line_of_sight_task, within_range_attack_distance_task, RangeAttackTask.new(self), random_move_options])
	var melee_attack_sequence: BTSequence = BTSequence.new([check_line_of_sight_task, within_melee_attack_distance_task, melee_attack_task])
	var chase_sequence: BTFallThroughSequence = BTFallThroughSequence.new([stand_up_task, check_for_enemies_task, find_target_pos_task, move_to_dest_task])
	
	if npc_template.ranged_attack_range > 0:
		root_node = BTSelector.new([range_attack_sequence, chase_sequence, search_sequence, wander_sequence])
	else:
		root_node = BTSelector.new([melee_attack_sequence, chase_sequence, search_sequence, wander_sequence])

func vanish_body():
	queue_free()
