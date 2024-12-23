class_name FactionRelations extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func read_in_file():
	pass


func calculate_faction_relations(faction_a: String, faction_b: String) -> int:
	if faction_a == "":
		push_error("ERROR: Faction A is blank!")
		return -1
	if faction_b == "":
		push_error("ERROR: Faction B is blank!")
		return -1
	if !get_tree().has_group(faction_a):
		push_error("ERROR: Faction '" + faction_a + "' does not exist!")
		return -1
	if !get_tree().has_group(faction_b):
		push_error("ERROR: Faction '" + faction_b + "' does not exist!")
		return -1
	# Check if factions are the same
	if faction_a == faction_b:
		return 100
	push_error("ERROR: Faction Relation not found!")
	return 0
