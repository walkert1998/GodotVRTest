class_name InventoryGrid extends Control

@export var grid_cell_size: float
@export var grid_size: IntPair
@export var inventory: Inventory
@export var grid_slot_template: PackedScene = preload("res://Scenes/UI/inventory_grid_slot.tscn")
@export var item_template: PackedScene = preload("res://Scenes/UI/inventory_item.tscn")
@export var grid: GridContainer
@export var container: Control
@export var add_item_button: Button
@export var item_to_spawn: Item
@export var item_menu: ItemMenu
@export var weapon_controller: WeaponController
@export var slot_select_sound: AudioStream
@export var item_place_sound: AudioStream
@export var cant_place_item_sound: AudioStream
@export var audio_player: AudioStreamPlayer
@export var item_3d_view_parent: Node3D
@export var item_viewer: SubViewport
@export var item_viewer_window: TextureRect
@export var item_description_label: RichTextLabel
@export var item_title_label: Label
var grid_slots: Array[InventoryGridSlot]
var item_held: InventoryItem = null
var current_slot: InventoryGridSlot = null
var icon_anchor: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	grid_size = inventory.inventory_size
	grid.columns = grid_size.x
	container.size.x = (grid_cell_size + 5) * grid_size.x
	container.size.y = (grid_cell_size + 5) * grid_size.y
	draw_grid()
	#add_item_button.connect("pressed", add_test_item)
	if item_menu != null:
		item_menu.connected_inventory = self
	item_viewer_window.texture = item_viewer.get_texture()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !inventory.visible:
		return
	if item_held:
		if Input.is_action_just_pressed("RotateItem") && item_held.item_grid_slots.size() > 1:
			rotate_item()
		if Input.is_action_just_pressed("MoveItem"):
			place_item()
	else:
		if Input.get_connected_joypads().size() > 0:
			if Input.is_action_just_pressed("OpenItemMenu"):
				print("Does current slot exist: " + str(current_slot))
				if current_slot:
					#move_item()
					if current_slot.item_stored != null && !item_menu.visible:
						
						var screen_size = DisplayServer.screen_get_size()
						item_menu.global_position = Vector2(current_slot.global_position.x + grid_cell_size, current_slot.global_position.y)
						item_menu.global_position.x = clamp(item_menu.global_position.x, current_slot.global_position.x + grid_cell_size, screen_size.x - item_menu.button_container.get_global_rect().size.x - 4)
						item_menu.global_position.y = clamp(item_menu.global_position.y, current_slot.global_position.y , screen_size.y - item_menu.button_container.get_global_rect().size.y - 4)
						item_menu.populate_options(current_slot.item_stored)
						item_menu.show()
						item_menu.button_container.get_child(0).grab_focus()
						item_menu.button_container.get_child(0).grab_click_focus()
					else:
						item_menu.hide()
						print("hide and select slot")
						current_slot.grab_focus()
						current_slot.grab_click_focus()
						current_slot.highlight_slot_selected()
				else:
					item_menu.hide()
			if Input.is_action_just_pressed("CloseItemMenu"):
				item_menu.hide()
				if current_slot:
					current_slot.grab_focus()
					current_slot.grab_click_focus()
					current_slot.highlight_slot_selected()
			if Input.is_action_just_pressed("MoveItem"):
				if current_slot && !item_menu.visible:
					item_menu.hide()
					move_item()
		else:
			if Input.is_action_just_pressed("MoveItem"):
				if container.get_global_rect().has_point(get_global_mouse_position()):
					if !item_menu.visible || (!item_menu.get_global_rect().has_point(get_global_mouse_position()) && item_menu.visible):
						item_menu.hide()
						move_item()
				elif !item_menu.get_global_rect().has_point(get_global_mouse_position()) && item_menu.visible:
					item_menu.hide()
			if Input.is_action_just_pressed("OpenItemMenu"):
				if container.get_global_rect().has_point(get_global_mouse_position()):
					#move_item()
					if current_slot.item_stored != null && (!item_menu.visible || !item_menu.get_global_rect().has_point(get_global_mouse_position()) && item_menu.visible):
						print_debug(current_slot.item_stored)
						print_debug("Opened item menu")
						var cursor_pos = get_global_mouse_position()
						var screen_size = DisplayServer.screen_get_size()
						#item_menu.global_position = get_global_mouse_position()
						item_menu.populate_options(current_slot.item_stored)
						item_menu.global_position.x = clamp(cursor_pos.x, 0, screen_size.x - item_menu.button_container.get_global_rect().size.x - 4)
						item_menu.global_position.y = clamp(cursor_pos.y, 0 , screen_size.y - item_menu.button_container.get_global_rect().size.y - 4)
						item_menu.show()
						
					else:
						print_debug("Nothing to click")
						print_debug(item_menu.get_global_rect().has_point(get_global_mouse_position()))
						print_debug(current_slot.item_stored)
						print_debug(item_menu.visible)
						item_menu.hide()
				else:
					print_debug("Not clicking inside container")
					item_menu.hide()
			if Input.is_action_just_pressed("SelectWeapon1"):
				if container.get_global_rect().has_point(get_global_mouse_position()) || current_slot != null:
					if current_slot.item_stored != null && current_slot.item_stored.stored_item.item_type == Item.ItemType.Weapon:
						var hotkey_1_item = inventory.find_inventory_item(weapon_controller.weapons[0])
						if hotkey_1_item:
							hotkey_1_item.set_hotkey_label(-1)
						weapon_controller.hotkey_item(current_slot.item_stored.stored_item, 0)
						current_slot.item_stored.set_hotkey_label(1)
			if Input.is_action_just_pressed("SelectWeapon2"):
				if container.get_global_rect().has_point(get_global_mouse_position()) || current_slot != null:
					if current_slot.item_stored != null && current_slot.item_stored.stored_item.item_type == Item.ItemType.Weapon:
						var hotkey_2_item = inventory.find_inventory_item(weapon_controller.weapons[1])
						if hotkey_2_item:
							hotkey_2_item.set_hotkey_label(-1)
						weapon_controller.hotkey_item(current_slot.item_stored.stored_item, 1)
						current_slot.item_stored.set_hotkey_label(2)
			if Input.is_action_just_pressed("SelectWeapon3"):
				if container.get_global_rect().has_point(get_global_mouse_position()) || current_slot != null:
					if current_slot.item_stored != null && current_slot.item_stored.stored_item.item_type == Item.ItemType.Weapon:
						var hotkey_3_item = inventory.find_inventory_item(weapon_controller.weapons[2])
						if hotkey_3_item:
							hotkey_3_item.set_hotkey_label(-1)
						weapon_controller.hotkey_item(current_slot.item_stored.stored_item, 2)
						current_slot.item_stored.set_hotkey_label(3)
			if Input.is_action_just_pressed("SelectWeapon4"):
				if container.get_global_rect().has_point(get_global_mouse_position()) || current_slot != null:
					if current_slot.item_stored != null && current_slot.item_stored.stored_item.item_type == Item.ItemType.Weapon:
						var hotkey_4_item = inventory.find_inventory_item(weapon_controller.weapons[3])
						if hotkey_4_item:
							hotkey_4_item.set_hotkey_label(-1)
						weapon_controller.hotkey_item(current_slot.item_stored.stored_item, 3)
						current_slot.item_stored.set_hotkey_label(4)

func add_test_item():
	inventory.add_item(item_to_spawn)
	#var new_item: InventoryItem = item_template.instantiate()
	#add_child(new_item)
	#new_item.populate_values(item_to_spawn, item_to_spawn.item_icon_horizontal, 1)
	#if item_held != null:
		#item_held.de_select()
	#new_item.select()
	#item_held = new_item

func add_item(new_item_to_add: InventoryItem):
	#inventory.add_item(item_to_spawn)
	#var new_item: InventoryItem = item_template.instantiate()
	#new_item = new_item_to_add
	#new_item_to_add.request_ready()
	grid.add_child(new_item_to_add)
	new_item_to_add.populate_values(new_item_to_add.stored_item, new_item_to_add.stored_item.item_icon_horizontal, new_item_to_add.quantity)
	new_item_to_add.icon.custom_minimum_size = Vector2(grid_cell_size, grid_cell_size)
	new_item_to_add.select()
	item_held = new_item_to_add
	print("adding item")
	for slot in grid_slots:
		if slot.item_stored == null:
			print("heres a slot")
			current_slot = slot
			place_item()
			new_item_to_add.global_position = slot.global_position
			break
	print("no slot found")
	#if item_held != null:
		#item_held.de_select()

func draw_grid():
	grid_slots = []
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var new_grid_slot: InventoryGridSlot = grid_slot_template.instantiate()
			new_grid_slot.custom_minimum_size.x = grid_cell_size
			new_grid_slot.custom_minimum_size.y = grid_cell_size
			grid.add_child(new_grid_slot)
			new_grid_slot.slot_id = grid_slots.size()
			new_grid_slot.slot_entered.connect(on_slot_mouse_entered)
			new_grid_slot.slot_exited.connect(on_slot_mouse_exited)
			#new_grid_slot.get_node("Label").text = str(new_grid_slot.slot_id)
			grid_slots.append(new_grid_slot)
	container.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	#for slot in grid_slots:
		#if slot.slot_id + 1 >= grid_slots.size():
			#slot.focus_neighbor_right = grid_slots[slot.slot_id - (grid_size.x - 1)].get_path()
		#else:
			#slot.focus_neighbor_right = grid_slots[slot.slot_id + 1].get_path()

func draw_items():
	for item in inventory.items:
		var new_item: InventoryItem = item_template.instantiate()
		add_child(new_item)
		new_item.populate_values(item.stored_item, item.stored_item.item_icon_horizontal, item.quantity)
		if item_held != null:
			item_held.de_select()
		new_item.select()
		item_held = new_item

func on_slot_mouse_entered(slot):
	icon_anchor = Vector2(9999,9999)
	current_slot = slot
	highlight_item(current_slot.item_stored)
	highlight_item_grids(current_slot, current_slot.item_stored)
	audio_player.stream = slot_select_sound
	audio_player.play()
	if item_held:
		set_grids(current_slot)
		if Input.get_connected_joypads().size() > 0:
			item_held.global_position = current_slot.global_position

func on_slot_mouse_exited(slot):
	clear_grid()

func check_slot_availability(slot: InventoryGridSlot) -> bool:
	for grid_slot in item_held.item_grid_slots:
		var slot_to_check = slot.slot_id + grid_slot.x + grid_slot.y * grid_size.x
		var line_switch_check = slot.slot_id % grid_size.x + grid_slot.x
		#print_debug("line_switch_check: " + str(line_switch_check) + " slot_to_check: " + str(slot_to_check))
		if line_switch_check < 0 || line_switch_check >= grid_size.x:
			return false
		if slot_to_check < 0 || slot_to_check >= grid_slots.size():
			return false
		if grid_slots[slot_to_check].state == grid_slots[slot_to_check].States.TAKEN:
			return false
	return true

func set_grids(slot: InventoryGridSlot):
	for grid_slot in item_held.item_grid_slots:
		var slot_to_check = slot.slot_id + grid_slot.x + grid_slot.y * grid_size.x
		var line_switch_check = slot.slot_id % grid_size.x + grid_slot.x
		if slot_to_check < 0 || slot_to_check >= grid_slots.size():
			continue
		if line_switch_check < 0 || line_switch_check >= grid_size.x:
			continue
		if check_slot_availability(slot):
			grid_slots[slot_to_check].highlight_slot_empty()
			if grid_slot.x < icon_anchor.x:
				icon_anchor.x = grid_slot.y
			if grid_slot.y < icon_anchor.y:
				icon_anchor.y = grid_slot.x
		else:
			grid_slots[slot_to_check].highlight_slot_taken()

func highlight_item_grids(slot: InventoryGridSlot, item_to_check: InventoryItem):
	if item_to_check == null:
		slot.highlight_slot_selected()
		return
	var start = item_to_check.grid_position.x
	for grid_slot in item_to_check.item_grid_slots:
		var slot_to_check = start + grid_slot.x + grid_slot.y * grid_size.x
		grid_slots[slot_to_check].highlight_slot_selected()

func clear_grid():
	for slot in grid_slots:
		slot.un_highlight_slot()

func rotate_item():
	item_held.rotate_item()
	clear_grid()
	if current_slot:
		on_slot_mouse_entered(current_slot)

func place_item():
	if check_slot_availability(current_slot) == false || current_slot == null:
		print("cant place here")
		audio_player.stream = cant_place_item_sound
		audio_player.play()
		return
	
	var calculated_grid_id = current_slot.slot_id + icon_anchor.x * grid_size.x + icon_anchor.y
	#print(calculated_grid_id)
	#print(grid_slots[calculated_grid_id].global_position)
	#item_held._snap_to(grid_slots[calculated_grid_id].global_position)
	item_held.get_parent().remove_child(item_held)
	grid.add_child(item_held)
	item_held._snap_to(current_slot.global_position)
	item_held.grid_anchor = current_slot
	item_held.grid_position = IntPair.new()
	item_held.grid_position.x = current_slot.slot_id
	for slot in item_held.item_grid_slots:
		var slot_to_check = current_slot.slot_id + slot.x + slot.y * grid_size.x
		grid_slots[slot_to_check].state = grid_slots[slot_to_check].States.TAKEN
		grid_slots[slot_to_check].item_stored = item_held
	item_held.de_select()
	item_held.global_position = current_slot.global_position
	item_held = null
	clear_grid()
	print("CAN place here")
	print(item_held)
	print("current slot is: " + str(current_slot))
	audio_player.stream = item_place_sound
	audio_player.play()
	current_slot.grab_focus()
	current_slot.grab_click_focus()
	current_slot.highlight_slot_selected()

func move_item(item_override: InventoryItem = null):
	if (current_slot == null || current_slot.item_stored == null) && item_override == null:
		return
	
	if item_override:
		item_held = item_override
	else:
		item_held = current_slot.item_stored
	item_held.select()
	
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	if Input.get_connected_joypads().size() > 0:
		item_held.global_position = current_slot.global_position
		print(item_held.global_position)
	else:
		item_held.global_position = get_global_mouse_position()
	
	for slot in item_held.item_grid_slots:
		var slot_to_check = item_held.grid_anchor.slot_id + slot.x + slot.y * grid_size.x
		grid_slots[slot_to_check].state = grid_slots[slot_to_check].States.FREE
		grid_slots[slot_to_check].item_stored = null
	
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot)
	current_slot.grab_focus()
	current_slot.grab_click_focus()

func remove_item(item_to_remove: InventoryItem, spawn_pickup: bool = false):
	print(item_to_remove)
	for grid_slot in item_to_remove.item_grid_slots:
		var slot_to_check = item_to_remove.grid_anchor.slot_id + grid_slot.x + grid_slot.y * grid_size.x
		grid_slots[slot_to_check].item_stored = null
		grid_slots[slot_to_check].state = grid_slots[slot_to_check].States.FREE
	if spawn_pickup && item_to_remove.stored_item.pickup_object != "":
		drop_item(item_to_remove.stored_item, item_to_remove.quantity)
	item_to_remove.queue_free()
	print(item_to_remove)

func equip_item(item_to_equip: InventoryItem):
	weapon_controller.equip_item(item_to_equip.stored_item)

func drop_item(item_dropped: Item, quantity: int):
	var pickup_obj: ItemPickup = load(item_dropped.pickup_object).instantiate()
	pickup_obj.quantity = quantity
	get_tree().root.add_child(pickup_obj)
	pickup_obj.global_position = Vector3(weapon_controller.global_position.x, weapon_controller.global_position.y - 0.75, weapon_controller.global_position.z)

func open_grid_view():
	#print("open grid view")
	if Input.get_connected_joypads().size() > 0:
		grid_slots[0].grab_click_focus()
		grid_slots[0].grab_focus()
	#print(grid_slots[0].has_focus())
	for slot in grid_slots:
		if slot.item_stored != null:
			slot.item_stored.global_position = slot.global_position

func close_grid_view():
	if get_viewport().gui_get_focus_owner():
		get_viewport().gui_get_focus_owner().release_focus()
	item_menu.hide()

func show_3d_view_of_item(item_to_view: InventoryItem):
	for child in item_3d_view_parent.get_children():
		item_3d_view_parent.remove_child(child)
	if item_to_view != null:
		var spawned_3d_view = load(item_to_view.stored_item.inventory_3d_view_path).instantiate()
		item_3d_view_parent.add_child(spawned_3d_view)

func highlight_item(item_highlighted: InventoryItem):
	item_title_label.text = item_highlighted.stored_item.item_name if item_highlighted else ""
	item_description_label.text = item_highlighted.stored_item.item_description if item_highlighted else ""
	show_3d_view_of_item(item_highlighted)

func select_current_item():
	if current_slot:
		highlight_item(current_slot.item_stored)
		highlight_item_grids(current_slot, current_slot.item_stored)
		current_slot.grab_focus()
		current_slot.grab_click_focus()
