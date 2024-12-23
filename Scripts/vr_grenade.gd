extends XRToolsPickable
class_name VRGrenade

@export var emission_mesh: MeshInstance3D
@export var light: Light3D
@export var grenade_item: Grenade

@export var audio_player: AudioStreamPlayer3D
@export var polyphonic_stream: AudioStreamPolyphonic
var audio_streams: Array[int]
var polyphonic_player: AudioStreamPlaybackPolyphonic


var armed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	polyphonic_stream = AudioStreamPolyphonic.new()
	polyphonic_stream.polyphony = 32
	audio_player.stream = polyphonic_stream
	audio_player.play()
	polyphonic_player = audio_player.get_stream_playback()
	audio_streams = []
	$TickTimer.timeout.connect(play_sound.bind(grenade_item.tick_sound))

func _process(delta: float) -> void:
	if !armed and is_picked_up() and get_picked_up_by_controller().is_button_pressed("ax_button"):
		arm_grenade()

func arm_grenade():
	light.visible = true
	emission_mesh.get_surface_override_material(0).emission_energy_multiplier = 1
	play_sound(grenade_item.arm_sound)
	$TickTimer.start(1)

func play_sound(stream: AudioStream):
	if !stream:
		return
	for i in audio_streams:
		if !polyphonic_player.is_stream_playing(i):
			polyphonic_player.stop_stream(i)
	#var stream = ranged_weapon.attack_sounds[randi_range(0, ranged_weapon.attack_sounds.size() - 1)]
	var res = polyphonic_player.play_stream(stream)
	#var rand_pitch = randf_range(0.9, 1.1)
	#polyphonic_player.set_stream_pitch_scale(res, rand_pitch)
	audio_streams.append(res)
