extends Node

@export var helmet_equipped: bool = false
@export var snap_zone: XRToolsSnapZone

func _ready() -> void:
	pass

func _on_HelmetSnapZone_has_picked_up(pickable: XRToolsPickable):
	pickable.hide()
	pickable.enabled = false
	pickable.freeze = true
	pickable.get_node("CollisionShape3D").disabled = true
	helmet_equipped = true
