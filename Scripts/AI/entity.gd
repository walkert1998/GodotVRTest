class_name Entity extends CharacterBody3D

@export var max_health: int
@export var current_health: int
@export var invincible: bool = false

func damage(amount: int, damage_source) -> int:
	return 0
