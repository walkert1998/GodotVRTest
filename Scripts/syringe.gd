extends XRToolsPickable
class_name Syringe

@export var animation_player: AnimationPlayer
@export var pressed: bool = false
@export var audio_player: AudioStreamPlayer3D
@export var inject_sound: AudioStream
@export var used: bool = false
@export var area3D: Area3D
@export var needle_collider: CollisionShape3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_picked_up():
		if !pressed and get_picked_up_by_controller().is_button_pressed("ax_button"):
			press()
		elif pressed and !get_picked_up_by_controller().is_button_pressed("ax_button"):
			release()

func press():
	animation_player.play("Press")
	pressed = true
	needle_collider.disabled = false

func release():
	animation_player.play("Release")
	pressed = false
	needle_collider.disabled = true

func inject():
	animation_player.play("Inject")
	audio_player.stream = inject_sound
	audio_player.play()

func _on_dropped(pickable):
	release()

func _on_area_3d_body_entered(body: Node3D) -> void:
	print_debug(body)
	if body is XRCamera3D or body is XRToolsCollisionHand:
		if body is XRToolsCollisionHand:
			var hand = body.get_parent().get_node("FunctionPickup")
			hand._pick_up_object(self)
		inject()
