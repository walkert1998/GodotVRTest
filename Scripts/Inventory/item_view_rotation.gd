extends Node3D

@export var rotation_speed: float

func _process(delta: float) -> void:
	rotation.y += delta
	if rotation.y >= 360:
		rotation.y = 0
