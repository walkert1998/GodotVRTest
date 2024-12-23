class_name InventoryGridSlot extends Control

signal slot_entered(InventoryGridSlot)
signal slot_exited(InventoryGridSlot)

@export var empty_colour: Color
@export var occupied_colour: Color
@export var highlighted_colour: Color
var slot_id: int
enum States {DEFAULT, TAKEN, FREE, HIGHLIGHTED}
var state:= States.DEFAULT
var item_stored = null

func highlight_slot_empty():
	modulate = empty_colour

func highlight_slot_taken():
	modulate = occupied_colour

func highlight_slot_selected():
	modulate = highlighted_colour

func un_highlight_slot():
	modulate = Color.DIM_GRAY

func _on_mouse_entered():
	emit_signal("slot_entered", self)

func _on_mouse_exited():
	emit_signal("slot_exited", self)
