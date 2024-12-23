class_name ItemMenu extends Control

signal consumed_health_item(Consumable)
signal selected_option

@export var button_container: VBoxContainer
@export_file var item_menu_button_template: String
@export var audio_player: AudioStreamPlayer
var item_menu_button
var item_focused: InventoryItem
var connected_inventory: InventoryGrid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_menu_button = load(item_menu_button_template)

func populate_options(item_to_focus: InventoryItem):
	#if item_to_focus == item_focused && visible:
		#return
	clear_options()
	item_focused = item_to_focus
	if item_focused.stored_item.item_type == Item.ItemType.Weapon && !item_focused.equipped:
		var equip_btn: BaseButton = item_menu_button.instantiate()
		equip_btn.text = "Equip"
		equip_btn.connect("pressed", equip_item)
		button_container.add_child(equip_btn)
		var hotkey_1_btn: BaseButton = item_menu_button.instantiate()
		hotkey_1_btn.text = "Hotkey Slot 1"
		hotkey_1_btn.audio_player = audio_player
		hotkey_1_btn.connect("pressed", hotkey_item_1)
		button_container.add_child(hotkey_1_btn)
		var hotkey_2_btn: BaseButton = item_menu_button.instantiate()
		hotkey_2_btn.text = "Hotkey Slot 2"
		hotkey_2_btn.audio_player = audio_player
		hotkey_2_btn.connect("pressed", hotkey_item_2)
		button_container.add_child(hotkey_2_btn)
		var hotkey_3_btn: BaseButton = item_menu_button.instantiate()
		hotkey_3_btn.text = "Hotkey Slot 3"
		hotkey_3_btn.audio_player = audio_player
		hotkey_3_btn.connect("pressed", hotkey_item_3)
		button_container.add_child(hotkey_3_btn)
		var hotkey_4_btn: BaseButton = item_menu_button.instantiate()
		hotkey_4_btn.text = "Hotkey Slot 4"
		hotkey_4_btn.audio_player = audio_player
		hotkey_4_btn.connect("pressed", hotkey_item_4)
		button_container.add_child(hotkey_4_btn)
	elif item_focused.stored_item.item_type == Item.ItemType.Ring:
		var equip_btn: BaseButton = item_menu_button.instantiate()
		equip_btn.text = "Equip"
		equip_btn.audio_player = audio_player
		equip_btn.connect("pressed", equip_item)
		button_container.add_child(equip_btn)
	elif item_focused.stored_item.item_type == Item.ItemType.Consumable:
		var consume_btn: BaseButton = item_menu_button.instantiate()
		consume_btn.text = "Consume"
		consume_btn.audio_player = audio_player
		consume_btn.connect("pressed", consume_item)
		button_container.add_child(consume_btn)
	var move_item_btn: BaseButton = item_menu_button.instantiate()
	move_item_btn.text = "Move Item"
	move_item_btn.audio_player = audio_player
	move_item_btn.connect("pressed", move_item)
	button_container.add_child(move_item_btn)
	if item_focused.stored_item is RangedWeapon:
		if item_focused.stored_item.loaded_ammo_count > 0:
			var unload_weapon_btn: BaseButton = item_menu_button.instantiate()
			unload_weapon_btn.text = "Unload Ammo"
			unload_weapon_btn.audio_player = audio_player
			unload_weapon_btn.connect("pressed", unload_ammo)
			button_container.add_child(unload_weapon_btn)
	var drop_item_btn: BaseButton = item_menu_button.instantiate()
	drop_item_btn.text = "Drop Item"
	drop_item_btn.audio_player = audio_player
	drop_item_btn.connect("pressed", drop_item)
	button_container.add_child(drop_item_btn)
	if Input.get_connected_joypads().size() > 0:
		move_item_btn.grab_focus()
		move_item_btn.grab_click_focus()

func clear_options():
	#print_debug("Clear options from item menu")
	for child in button_container.get_children():
		button_container.remove_child(child)
		child.queue_free()
	#size = Vector2.ZERO

func drop_item():
	connected_inventory.inventory.remove_item(item_focused, item_focused.quantity, true)
	emit_signal("selected_option")
	hide()

func move_item():
	#connected_inventory.item_held = item_focused
	connected_inventory.move_item(item_focused)
	hide()

func equip_item():
	connected_inventory.equip_item(item_focused)
	emit_signal("selected_option")
	hide()

func unload_ammo():
	var ranged_weapon: RangedWeapon = item_focused.stored_item as RangedWeapon
	var count = ranged_weapon.loaded_ammo_count
	ranged_weapon.loaded_ammo_count = 0
	connected_inventory.inventory.add_item(ranged_weapon.loaded_ammo_type, count)
	emit_signal("selected_option")
	hide()

func consume_item():
	emit_signal("consumed_health_item", item_focused.stored_item)
	#connected_inventory.inventory.remove_item(item_focused, 1)
	hide()

func hotkey_item_1():
	connected_inventory.weapon_controller.hotkey_item(item_focused.stored_item, 0)
	item_focused.set_hotkey_label(1)
	emit_signal("selected_option")
	hide()

func hotkey_item_2():
	connected_inventory.weapon_controller.hotkey_item(item_focused.stored_item, 1)
	item_focused.set_hotkey_label(2)
	emit_signal("selected_option")
	hide()

func hotkey_item_3():
	connected_inventory.weapon_controller.hotkey_item(item_focused.stored_item, 2)
	item_focused.set_hotkey_label(3)
	emit_signal("selected_option")
	hide()

func hotkey_item_4():
	connected_inventory.weapon_controller.hotkey_item(item_focused.stored_item, 3)
	item_focused.set_hotkey_label(4)
	emit_signal("selected_option")
	hide()

func redraw() -> void:
	#button_container.notify_property_list_changed()
	print("redraw")
