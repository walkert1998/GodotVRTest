class_name WeaponController extends Node3D

var current_ammo: int = 0
var reserve_ammo: int = 0
@export var weapons: Array[Item]
@export var current_ranged_weapon: RangedWeapon
@export var current_melee_weapon: MeleeWeapon
@export var current_ring: Ring
@export var aim_transition_speed: float = 10
@export var hud: Hud
@export var audio_player: AudioStreamPlayer
@export var camera: Camera3D
@export var camera_shake: CameraShake
@export var bullet_trail_prefab: PackedScene
@export var enable_camera_shake: bool = true
@export_flags_3d_physics var collision_layers
#@export var hit_marker: HitMarker
@export var connected_inventory: Inventory
@export var connected_player: PlayerController
@export var max_melee_charge_multiplier: float = 1.5
@export var shape_cast: ShapeCast3D
@export var spell_spawn_point: Node3D
var attacking: bool = false
var aiming: bool = false
var weapon_model
var muzzle_flash: MuzzleFlash
var weapon_animation_player: AnimationPlayer
var current_weapon_index: int = 0
var player_guns_audio_bus_index: int = 0
var player_guns_pitch_effect: AudioEffectPitchShift
var target_rot: Vector3
var target_pos: Vector3
var current_time: float = 2
var trail_spawn_point
var allow_input: bool = true
var polyphonic_player: AudioStreamPlaybackPolyphonic
@export var polyphonic_stream: AudioStreamPolyphonic
@export var one_in_chamber_enabled: bool = true
@export_file var generic_impact_effect: String
var audio_streams: Array[int]
var charged_time: float = 0.0
var melee_charged_multiplier: float = 0.0


func save():
	var save_dict = {
		"current_ranged_weapon" : current_ranged_weapon.base_item_id,
		"current_ammo" : current_ammo,
		"current_melee_weapon" : current_melee_weapon.base_item_id,
		"hotkey_item_1" : weapons[0].base_item_id,
		"hotkey_item_2" : weapons[1].base_item_id,
		"hotkey_item_3" : weapons[2].base_item_id,
		"hotkey_item_4" : weapons[3].base_item_id,
		"weapon_index" : current_weapon_index
	}
	return save_dict

# Called when the node enters the scene tree for the first time.
func _ready():
	if current_ranged_weapon:
		select_next_weapon()
		current_ammo = current_ranged_weapon.clip_size
		hud.set_weapon_values(current_ranged_weapon.icon, current_ranged_weapon.loaded_ammo_type.item_icon_horizontal, current_ammo, reserve_ammo)
	polyphonic_stream = AudioStreamPolyphonic.new()
	polyphonic_stream.polyphony = 32
	audio_player.stream = polyphonic_stream
	audio_player.play()
	polyphonic_player = audio_player.get_stream_playback()
	audio_streams = []
	if shape_cast != null:
		shape_cast.add_exception(owner)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED && allow_input:
		if current_ranged_weapon != null:
			if Input.is_action_just_pressed("AltFire"):
				aiming = true
				#TimeControl.start_slow_motion(0.25)
			#if Input.is_action_just_released("AltFire"):
				#TimeControl.stop_slow_motion()
			if Input.is_action_pressed("AltFire"):
				aim(delta)
			elif aiming:
				release_aim(delta)
			if !weapon_animation_player.is_playing():
				if Input.is_action_pressed("Fire"):
					fire()
				if Input.is_action_just_pressed("Reload") && current_ammo < current_ranged_weapon.clip_size && reserve_ammo > 0:
					reload()
		elif current_melee_weapon != null:
			if aiming:
				release_aim(delta)
			if charged_time > 0.0:
				if Input.is_action_just_released("Fire"):
					release_melee_attack()
				if Input.is_action_pressed("Fire"):
					charge_melee_attack(delta)
			if !weapon_animation_player.is_playing() && charged_time == 0.0:
				if Input.is_action_pressed("Fire"):
					charge_melee_attack(0.1)
		if current_ring != null:
			if Input.is_action_just_pressed("CastSpell"):
				cast_spell()
		if weapon_animation_player == null || !weapon_animation_player.is_playing():
			if Input.is_action_just_pressed("SelectWeapon1"):
				select_weapon(0)
			if Input.is_action_just_pressed("SelectWeapon2"):
				select_weapon(1)
			if Input.is_action_just_pressed("SelectWeapon3"):
				select_weapon(2)
			if Input.is_action_just_pressed("SelectWeapon4"):
				select_weapon(3)
			if Input.is_action_just_pressed("SelectNextWeapon"):
				select_next_weapon()
			if Input.is_action_just_pressed("SelectPreviousWeapon"):
				select_prev_weapon()

func _physics_process(delta):
	if current_time < 1 && current_ranged_weapon != null:
		current_time += delta
		position.z = lerp(position.z, target_pos.z, 10 * delta)
		rotation.z = lerp(rotation.z, target_rot.z, 10 * delta)
		rotation.x = lerp(rotation.x, target_rot.x, 10 * delta)
		
		target_rot.z = current_ranged_weapon.recoil_rotation_z.sample(current_time)
		target_rot.x = current_ranged_weapon.recoil_rotation_x.sample(current_time)
		target_pos.z = current_ranged_weapon.recoil_position_z.sample(current_time)

func select_next_weapon():
	#if !pistol_found && !rifle_found && !shotgun_found && !assault_rifle_found && !rocket_launcher_found:
		#return
	if weapons.size() == 0:
		return
	if current_weapon_index < weapons.size() - 1:
		current_weapon_index += 1
	else:
		current_weapon_index = 0
	#if weapons[current_weapon_index] == null:
		#select_next_weapon()
	select_weapon(current_weapon_index)

func select_prev_weapon():
	if weapons.size() == 0:
		return
	if current_weapon_index > 0:
		current_weapon_index -= 1
	else:
		current_weapon_index = weapons.size() - 1
	#if weapons[current_weapon_index] == null:
		#select_prev_weapon()
	select_weapon(current_weapon_index)

func select_weapon(index: int):
	if weapons.size() == 0:
		return
	#if weapons[index] == null:
		#return
	current_weapon_index = index
	equip_item(weapons[current_weapon_index])

func equip_item(item_to_equip: Item = null):
	if item_to_equip == null:
		trail_spawn_point = null
		muzzle_flash = null
		weapon_animation_player = null
		current_ammo = 0
		reserve_ammo = 0
		current_ranged_weapon = null
		current_melee_weapon = null
		if weapon_model != null:
			#print("hide weapon")
			weapon_model.queue_free()
		return
	if item_to_equip is RangedWeapon:
		if weapon_model != null:
			weapon_model.queue_free()
		current_melee_weapon = null
		current_ranged_weapon = item_to_equip as RangedWeapon
		weapon_model = current_ranged_weapon.weapon_view_model.instantiate()
		trail_spawn_point = weapon_model.get_node("TrailSpawn")
		muzzle_flash = weapon_model.get_node("MuzzleFlash")
		check_ammo()
		hud.set_weapon_values(current_ranged_weapon.icon, current_ranged_weapon.loaded_ammo_type.item_icon_horizontal, current_ammo, reserve_ammo, current_ammo > current_ranged_weapon.clip_size)
		add_child(weapon_model)
		weapon_animation_player = weapon_model.get_node("AnimationPlayer")
	elif item_to_equip is MeleeWeapon:
		if weapon_model != null:
			weapon_model.queue_free()
		current_ranged_weapon = null
		current_melee_weapon = item_to_equip as MeleeWeapon
		hud.set_weapon_values(current_melee_weapon.item_icon_horizontal, null, 0, 0)
		weapon_animation_player = $AnimationPlayer
		weapon_animation_player.speed_scale = current_melee_weapon.animation_speed_multiplier
		weapon_model = current_melee_weapon.weapon_view_model.instantiate()
		shape_cast.shape.size.z = current_melee_weapon.attack_range
		shape_cast.target_position.z = -(current_melee_weapon.attack_range / 2)
		add_child(weapon_model)
	elif item_to_equip is Ring:
		current_ring = item_to_equip as Ring

func fire():
	if current_ammo > 0:
		#var pitch: float = float(current_ammo) / current_ranged_weapon.clip_size
		#pitch = clampf(pitch, 0.3, 1.0)
		current_ammo -= 1
		hud.update_ammo(current_ammo, reserve_ammo, current_ranged_weapon.loaded_ammo_type)
		if Input.get_connected_joypads().size() > 0:
			Input.start_joy_vibration(0, 0.8, 0.2, 0.25)
		if current_ranged_weapon.attack_sounds.size() > 0:
			for i in audio_streams:
				if !polyphonic_player.is_stream_playing(i):
					polyphonic_player.stop_stream(i)
			var stream = current_ranged_weapon.attack_sounds[randi_range(0, current_ranged_weapon.attack_sounds.size() - 1)]
			var res = polyphonic_player.play_stream(stream)
			var rand_pitch = randf_range(0.7, 1.3)
			polyphonic_player.set_stream_pitch_scale(res, rand_pitch)
			audio_streams.append(res)
			#audio_player.play()
		#attacking = true
		if weapon_animation_player:
			weapon_animation_player.play("Fire")
		muzzle_flash.muzzle_flash()
		apply_recoil()
		if current_ranged_weapon.projectile_scene:
			launch_projectile()
		else:
			for projectile in current_ranged_weapon.projectiles_per_shot:
				hitscan_raycast()
	else:
		#check_ammo()
		if reserve_ammo > 0:
			reload()
		#else:
			#for i in audio_streams:
				#if !polyphonic_player.is_stream_playing(i):
					#polyphonic_player.stop_stream(i)
			#var stream = current_ranged_weapon.dry_fire_sound
			#var res = polyphonic_player.play_stream(stream)
			#audio_streams.append(res)
	current_ranged_weapon.loaded_ammo_count = current_ammo

func charge_melee_attack(delta):
	if charged_time == 0:
		melee_charged_multiplier = 0
		weapon_animation_player.play("ChargeAttack")
	if melee_charged_multiplier < max_melee_charge_multiplier:
		charged_time += delta
		melee_charged_multiplier = clampf(charged_time / current_melee_weapon.time_to_fully_charge_attack, 0.1, max_melee_charge_multiplier)
		hud.update_melee_charge(melee_charged_multiplier * 100)

func release_melee_attack():
	weapon_animation_player.play("ReleaseAttack")
	charged_time = 0
	hud.update_melee_charge(0)
	if current_melee_weapon.swing_sounds.size() > 0:
		for i in audio_streams:
			if !polyphonic_player.is_stream_playing(i):
				polyphonic_player.stop_stream(i)
		var stream = current_melee_weapon.swing_sounds[randi_range(0, current_melee_weapon.swing_sounds.size() - 1)]
		var res = polyphonic_player.play_stream(stream)
		var rand_pitch = randf_range(0.8, 1.3)
		polyphonic_player.set_stream_pitch_scale(res, rand_pitch)
		audio_streams.append(res)

func melee_attack_double_check():
	var ray = melee_raycast()
	if ray == 1:
		hitscan_shapecast()

func hitscan_shapecast():
	var hit_objects: Array[Entity] = []
	for hit_object in shape_cast.collision_result:
		print(hit_object)
		if (hit_object["collider"] is Entity && hit_objects.find(hit_object["collider"]) == -1) || (hit_object["collider"] is BodyPart && hit_objects.find(hit_object["collider"].attached_enemy) == -1):
			var ret = hit_object["collider"].damage(current_melee_weapon.base_damage * melee_charged_multiplier, connected_player)
			if current_melee_weapon.flesh_impact_sounds.size():
				for i in audio_streams:
					if !polyphonic_player.is_stream_playing(i):
						polyphonic_player.stop_stream(i)
				var stream = current_melee_weapon.flesh_impact_sounds[randi_range(0, current_melee_weapon.flesh_impact_sounds.size() - 1)]
				var res = polyphonic_player.play_stream(stream)
				var rand_pitch = randf_range(0.8, 1.3)
				polyphonic_player.set_stream_pitch_scale(res, rand_pitch)
				audio_streams.append(res)
			if (ret == 1 || ret == 2) && hit_object["collider"].attached_enemy.npc_template.blood_impact_effect_path != "":
				var impact_effect: ImpactEffect = load(hit_object["collider"].attached_enemy.npc_template.blood_impact_effect_path).instantiate()
				get_tree().root.add_child(impact_effect)
				impact_effect.spawn(hit_object["point"], hit_object["normal"])
			if hit_object is Entity:
				hit_objects.append(hit_object["collider"])
			else:
				hit_objects.append(hit_object["collider"].attached_enemy)
		else:
			if generic_impact_effect != "":
				var impact_effect: ImpactEffect = load(generic_impact_effect).instantiate()
				get_tree().root.add_child(impact_effect)
				impact_effect.spawn(hit_object.point, hit_object.normal)
			break

func melee_raycast() -> int:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(camera.global_position,
			camera.global_position - camera.global_transform.basis.z * current_melee_weapon.attack_range)
	query.collision_mask = collision_layers
	var collision = space.intersect_ray(query)
	if collision:
		#print(collision["collider"])
		#var bullet_trail_spawn: BulletTrail = bullet_trail_prefab.instantiate()
		#get_tree().root.add_child(bullet_trail_spawn)
		#bullet_trail_spawn.draw(trail_spawn_point.global_position, collision.position)
		if collision["collider"].has_method("damage"):
			#intersection["collider"].player = self
			var ret = collision["collider"].damage(current_melee_weapon.base_damage * melee_charged_multiplier, connected_player)
			if (ret == 1 || ret == 2) && collision["collider"].attached_enemy.npc_template.blood_impact_effect_path != "":
				var impact_effect: ImpactEffect = load(collision["collider"].attached_enemy.npc_template.blood_impact_effect_path).instantiate()
				get_tree().root.add_child(impact_effect)
				impact_effect.spawn(collision.position, collision.normal)
			#bullet_trail_spawn.draw_impact(true, collision.position, collision.normal)
			return 0
		else:
			if generic_impact_effect != "":
				var impact_effect: ImpactEffect = load(generic_impact_effect).instantiate()
				get_tree().root.add_child(impact_effect)
				impact_effect.spawn(collision.position, collision.normal)
			#bullet_trail_spawn.draw_impact(false, collision.position, collision.normal)
			#return 0
			return 1
	else:
		#var bullet_trail_spawn: BulletTrail = bullet_trail_prefab.instantiate()
		#get_tree().root.add_child(bullet_trail_spawn)
		#bullet_trail_spawn.draw(trail_spawn_point.global_position, query.to)
		return 1

func start_shapecast_damage():
	shape_cast.enabled = true

func end_shapecast_damage():
	shape_cast.enabled = false

func hitscan_raycast() -> int:
	var space = get_world_3d().direct_space_state
	var random_spread_x = randf_range(-current_ranged_weapon.bullet_spread_angle, current_ranged_weapon.bullet_spread_angle)
	var random_spread_y = randf_range(-current_ranged_weapon.bullet_spread_angle, current_ranged_weapon.bullet_spread_angle)
	var query = PhysicsRayQueryParameters3D.create(camera.global_position,
			camera.global_position - camera.global_transform.basis.z * 1000)
	query.collision_mask = collision_layers
	query.to = Vector3(query.to.x + random_spread_x, query.to.y + random_spread_y, query.to.z)
	var collision = space.intersect_ray(query)
	if collision:
		print(collision["collider"])
		var bullet_trail_spawn: BulletTrail = bullet_trail_prefab.instantiate()
		get_tree().root.add_child(bullet_trail_spawn)
		bullet_trail_spawn.draw(trail_spawn_point.global_position, collision.position)
		if collision["collider"].has_method("damage"):
			#intersection["collider"].player = self
			var ret = collision["collider"].damage(current_ranged_weapon.loaded_ammo_type.damage, connected_player)
			if (ret == 1 || ret == 2) && collision["collider"].attached_enemy.npc_template.blood_impact_effect_path != "":
				var impact_effect: ImpactEffect = load(collision["collider"].attached_enemy.npc_template.blood_impact_effect_path).instantiate()
				get_tree().root.add_child(impact_effect)
				impact_effect.spawn(collision.position, collision.normal)
			bullet_trail_spawn.draw_impact(true, collision.position, collision.normal)
		else:
			bullet_trail_spawn.draw_impact(false, collision.position, collision.normal)
			if generic_impact_effect != "":
				var impact_effect: ImpactEffect = load(generic_impact_effect).instantiate()
				get_tree().root.add_child(impact_effect)
				impact_effect.spawn(collision.position, collision.normal)
			if current_ranged_weapon.loaded_ammo_type.impact_effect != null:
				var impact_effect: ImpactEffect = current_ranged_weapon.loaded_ammo_type.impact_effect.instantiate()
				get_tree().root.add_child(impact_effect)
				impact_effect.spawn(collision.position, collision.normal)
		return 0
	else:
		var bullet_trail_spawn: BulletTrail = bullet_trail_prefab.instantiate()
		get_tree().root.add_child(bullet_trail_spawn)
		bullet_trail_spawn.draw(trail_spawn_point.global_position, query.to)
		return 1

func launch_projectile():
	var projectile_to_launch: Projectile = current_ranged_weapon.projectile_scene.instantiate()
	projectile_to_launch.projectile_direction = global_basis.z
	projectile_to_launch.damage = current_ranged_weapon.damage
	trail_spawn_point.add_child(projectile_to_launch)
	projectile_to_launch.reparent(get_tree().root, true)

func reload():
	var ammo_difference: int = current_ranged_weapon.clip_size - current_ammo
	if weapon_animation_player:
		weapon_animation_player.play("Reload")
	var ammo_found = connected_inventory.find_inventory_item(current_ranged_weapon.loaded_ammo_type)
	if reserve_ammo > (current_ranged_weapon.clip_size - current_ammo):
		ammo_difference = current_ranged_weapon.clip_size - current_ammo
		reserve_ammo -= ammo_difference
		current_ammo = current_ranged_weapon.clip_size
		if current_ranged_weapon.loaded_ammo_count > 0:
			current_ammo += 1
	else:
		ammo_difference = reserve_ammo
		current_ammo += reserve_ammo
		reserve_ammo = 0
	current_ranged_weapon.loaded_ammo_count = current_ammo
	connected_inventory.remove_item(ammo_found, ammo_difference)
	if current_ranged_weapon.reload_sounds.size() > 0:
		for i in audio_streams:
			if !polyphonic_player.is_stream_playing(i):
				polyphonic_player.stop_stream(i)
		var stream = current_ranged_weapon.reload_sounds[randi_range(0, current_ranged_weapon.reload_sounds.size() - 1)]
		var res = polyphonic_player.play_stream(stream)
		audio_streams.append(res)
	hud.update_ammo(current_ammo, reserve_ammo, current_ranged_weapon.loaded_ammo_type, current_ammo > current_ranged_weapon.clip_size)

func check_ammo():
	#print_debug("looking for ammo " + current_ranged_weapon.loaded_ammo_type.item_name)
	#var weapon_found = connected_inventory.find_item(current_ranged_weapon) as RangedWeapon
	#if weapon_found:
	current_ammo = current_ranged_weapon.loaded_ammo_count
	var ammo_found = connected_inventory.find_inventory_item(current_ranged_weapon.loaded_ammo_type)
	if ammo_found != null:
		reserve_ammo = ammo_found.quantity
	else:
		reserve_ammo = 0
	#print_debug(current_ranged_weapon.loaded_ammo_count)
	hud.update_ammo(current_ammo, reserve_ammo, current_ranged_weapon.loaded_ammo_type)

func apply_recoil():
	if enable_camera_shake:
		camera_shake.add_trauma(current_ranged_weapon.recoil)
	target_rot.z = current_ranged_weapon.recoil_rotation_z.sample(0)
	target_rot.x = current_ranged_weapon.recoil_rotation_x.sample(0)
	target_pos.z = current_ranged_weapon.recoil_position_z.sample(0)
	current_time = 0

func aim(delta: float):
	camera.fov = lerpf(camera.fov, current_ranged_weapon.zoomed_in_fov, aim_transition_speed * delta)

func release_aim(delta: float):
	camera.fov = lerpf(camera.fov, 90.0, aim_transition_speed * delta)
	if camera.fov >= 89.8:
		camera.fov = 90.0
		aiming = false

func hotkey_item(item_to_hotkey: Item, index: int):
	if item_to_hotkey == null:
		weapons[index] = null
		return
	if item_to_hotkey.item_type != Item.ItemType.Weapon:
		return
	for i in range(0, weapons.size()):
		if weapons[i] == item_to_hotkey:
			weapons[i] = null
	weapons[index] = item_to_hotkey

func refresh(removed_item: InventoryItem, dropped: bool = false):
	#print_debug(removed_item)
	if current_ranged_weapon != null:
		if current_ranged_weapon == removed_item.stored_item:
			equip_item(null)
		#var found_weapon = connected_inventory.find_item(current_ranged_weapon)
		#if found_weapon == null:
		else:
			check_ammo()
	elif current_melee_weapon != null:
		if current_melee_weapon == removed_item.stored_item:
			equip_item(null)
	var result = weapons.find(removed_item.stored_item)
	if result != -1:
		hotkey_item(null, result)
	#for weapon in range(0, weapons.size()):
		#if weapon != null:
			#var found_weapon = connected_inventory.find_item(weapons[weapon])
			#if found_weapon == null:

func cast_spell():
	if connected_player.current_mana < connected_player.max_mana:
		hud.flash_mana_bar_negative()
		return
	var projectile_to_launch = load(current_ring.spell.projectile_path).instantiate()
	projectile_to_launch.damage = current_ring.spell.damage
	projectile_to_launch.source = self
	spell_spawn_point.rotation = Vector3.ZERO
	var spread = deg_to_rad(randf_range(-current_ring.spell.projectile_spread, current_ring.spell.projectile_spread))
	#print(spread)
	spell_spawn_point.rotate(Vector3.UP, spread)
	spell_spawn_point.rotate(Vector3.RIGHT, spread)
	#print(projectile_spawn.rotation)
	spell_spawn_point.add_child(projectile_to_launch)
	if current_ring.spell.cast_sound != null:
		for i in audio_streams:
			if !polyphonic_player.is_stream_playing(i):
				polyphonic_player.stop_stream(i)
		var stream = current_ring.spell.cast_sound
		var res = polyphonic_player.play_stream(stream)
		audio_streams.append(res)
	projectile_to_launch.reparent(get_tree().root, true)
	connected_player.use_mana(100)
	connected_player.spell_colldown_timer.start(current_ring.spell.cooldown_time)
