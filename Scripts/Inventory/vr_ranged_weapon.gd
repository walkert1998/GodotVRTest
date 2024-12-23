extends XRToolsPickable
class_name VRRangedWeapon

enum WeaponState {
	LOADED,
	UNLOADED,
	FIRED
}

@export var magazine_snap_zone: XRToolsSnapZone
@export var animation_player: AnimationPlayer
@export var casing_spawn_point: Node3D
@export var slide_pickup: XRToolsPickable
@export var slide_origin: Node3D
@export var max_pullback_slide: float
@export var bone_name: String
@export var audio_player: AudioStreamPlayer3D
@export var polyphonic_stream: AudioStreamPolyphonic
@export var ranged_weapon: RangedWeapon
var audio_streams: Array[int]
var polyphonic_player: AudioStreamPlaybackPolyphonic
var slide_orig_pos: Vector3
var magazine: VRMagazine
@export var skeleton: Skeleton3D
var bone_id
var slide_layer
var slide_start_pos: Vector3
var weapon_state = WeaponState.LOADED
var prev_slide_pullback: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	bone_id = skeleton.find_bone(bone_name)
	slide_pickup.enabled = false
	slide_orig_pos = slide_origin.transform.origin
	slide_layer = slide_pickup.collision_layer
	slide_pickup.collision_layer = 0
	polyphonic_stream = AudioStreamPolyphonic.new()
	polyphonic_stream.polyphony = 32
	audio_player.stream = polyphonic_stream
	audio_player.play()
	polyphonic_player = audio_player.get_stream_playback()
	audio_streams = []
	#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#super()
	if is_picked_up() and get_picked_up_by_controller() and get_picked_up_by_controller().is_button_pressed("by_button"):
		if magazine and !animation_player.is_playing():
			animation_player.play("EjectMagazine")
			play_sound(ranged_weapon.drop_magazine_sound)
	
	if slide_pickup.is_picked_up():
		var slide_pos = slide_pickup.global_transform.origin
		var slide_pickup_local = slide_pos * slide_origin.global_transform
		#print(slide_pickup_local)
		
		var pullback = max(slide_start_pos.z, clampf(slide_pickup_local.z, slide_start_pos.z, max_pullback_slide + slide_start_pos.z))
		#print(pullback)
		if pullback < max_pullback_slide + slide_start_pos.z:
			var bone_pose = skeleton.get_bone_rest(bone_id).origin
			bone_pose.y = bone_pose.y - pullback + slide_start_pos.z
			#print(bone_pose)
			skeleton.set_bone_pose_position(bone_id, bone_pose)
			if pullback == slide_start_pos.z and pullback != prev_slide_pullback:
				play_sound(ranged_weapon.slide_release_sound)
		else:
			if prev_slide_pullback != pullback:
				if magazine:
					magazine.use_ammo()
				play_sound(ranged_weapon.slide_pull_sound)
			#slide_pickup.drop()
		prev_slide_pullback = pullback
	elif magazine and magazine.has_bullets():
		if skeleton.get_bone_pose_position(bone_id) != skeleton.get_bone_rest(bone_id).origin:
			var bone_pose = skeleton.get_bone_pose_position(bone_id)
			bone_pose.y = lerp(bone_pose.y, skeleton.get_bone_rest(bone_id).origin.y, 0.5)
			#print(bone_pose)
			skeleton.set_bone_pose_position(bone_id, bone_pose)
			if skeleton.get_bone_pose_position(bone_id) == skeleton.get_bone_rest(bone_id).origin:
				play_sound(ranged_weapon.slide_release_sound)

func _on_magazine_loaded():
	pass

func _on_magazine_ejected():
	magazine_snap_zone.drop_object()
	magazine.enable_collision()
	magazine = null
	$Label3D.text = "0"

func _on_MagazineSnapZone_has_picked_up(object):
	magazine = object
	magazine.disable_collision()
	$Label3D.text = str(magazine.ammo_count)
	animation_player.play("LoadMagazine")
	play_sound(ranged_weapon.load_magazine_sound)

func _on_picked_up(pickable):
	slide_pickup.enabled = true
	slide_pickup.collision_layer = slide_layer
	if magazine:
		$Label3D.text = str(magazine.ammo_count)
	else:
		$Label3D.text = "0"

func _on_dropped(pickable):
	if slide_pickup.is_picked_up():
		slide_pickup.drop()
	slide_pickup.enabled = false
	slide_pickup.collision_layer = 0

func _on_Slide_picked_up(pickable):
	slide_start_pos = slide_pickup.transform.origin
	prev_slide_pullback = slide_start_pos.z

func _on_Slide_dropped(pickable):
	slide_pickup.transform = slide_origin.transform
	slide_pickup.position = Vector3.ZERO
	#skeleton.set_bone_pose(bone_id, skeleton.get_bone_rest(bone_id))

func eject_casing():
	casing_spawn_point
	pass

func fire(pickable):
	if magazine and magazine.has_bullets():
		if !animation_player.is_playing():
			play_sound(ranged_weapon.attack_sounds[randi_range(0, ranged_weapon.attack_sounds.size() - 1)])
			animation_player.play("Fire")
			magazine.use_ammo()
			$Label3D.text = str(magazine.ammo_count)
			if !magazine.has_bullets():
				animation_player.play("EmptyFire")
	else:
		if !animation_player.is_playing():
			animation_player.play("EmptyFire")

func play_sound(stream: AudioStream):
	if !stream:
		return
	for i in audio_streams:
		if !polyphonic_player.is_stream_playing(i):
			polyphonic_player.stop_stream(i)
	#var stream = ranged_weapon.attack_sounds[randi_range(0, ranged_weapon.attack_sounds.size() - 1)]
	var res = polyphonic_player.play_stream(stream)
	var rand_pitch = randf_range(0.9, 1.1)
	polyphonic_player.set_stream_pitch_scale(res, rand_pitch)
	audio_streams.append(res)
