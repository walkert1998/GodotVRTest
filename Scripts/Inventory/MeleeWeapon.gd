class_name MeleeWeapon extends Item

@export var base_damage:int = 1
@export var time_to_fully_charge_attack: float = 1.0
@export var animation_speed_multiplier: float = 1.0
@export var weapon_view_model: PackedScene
@export var swing_sounds: Array[AudioStream]
@export var flesh_impact_sounds: Array[AudioStream]
@export var block_sounds: Array[AudioStream]
@export var draw_sound: AudioStream
@export var holster_sound: AudioStream
@export var attack_range: float = 3.0
