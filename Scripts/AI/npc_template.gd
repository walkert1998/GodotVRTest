class_name NPCTemplate extends Resource

@export_category("Base Stats")
@export var npc_name: String
@export var max_health: int = 100
@export var speed: float = 3.0
@export var vision_range: float = 100.0
@export var field_of_view: float = 80.0
#@export_enum() var faction: String
@export_category("Audio/Visual Effects")
@export var animation_library_name: String
@export var pain_animations: Array[String]
@export var crouching_pain_animations: Array[String]
@export_file var model_path: String
@export var pain_sounds: Array[AudioStream]
@export var death_sounds: Array[AudioStream]
@export_file var blood_impact_effect_path: String
@export_file var projectile_scene: String
@export_category("Combat Stats")
@export var ranged_attack_range: float = 0.0
@export var ranged_attack_spread: float = 0.0
@export var melee_attack_range: float = 0.0
@export var ranged_weapon: RangedWeapon
@export var unarmed_melee_damage: int = 1.0
@export var melee_weapon: MeleeWeapon
