class_name Inventory extends Node

signal item_added(InventoryItem)
signal item_added_quantity(InventoryItem, int)
signal item_removed(InventoryItem, bool)
signal item_removed_quantity(InventoryItem, int, bool)

@export var items: Array[InventoryItem]
@export var inventory_size: IntPair
@export_file var inventory_item_template: String

var inventory_full: bool = false

func add_item(new_item: Item, quantity: int = 1) -> int:
	var space_available = check_space_available()
	if space_available < (new_item.item_size.x * new_item.item_size.y):
		return -2
	if new_item == null:
		print_debug("Cannot add null item " + new_item.item_name)
		return -1
	if quantity < 1:
		print_debug("Cannot add negative number of items")
		return -1
	print("trying to add item " + new_item.item_name)
	if new_item.stackable:
		var found_item = find_inventory_item(new_item)
		print(found_item)
		if found_item != null:
		#if found_item != null && found_item.quantity + quantity <= new_item.max_stack_size && new_item.max_stack_size > 0
			found_item.quantity += quantity
			found_item.update_quantity_label()
			emit_signal("item_added_quantity", found_item, quantity)
		else:
			var new_inventory_item: InventoryItem = load(inventory_item_template).instantiate()
			new_inventory_item.stored_item = new_item
			#new_inventory_item.quantity = quantity - (new_item.max_stack_size - found_item.quantity)
			new_inventory_item.quantity = quantity - (new_item.max_stack_size)
			items.append(new_inventory_item)
			emit_signal("item_added", new_inventory_item)
			#found_item.quantity = new_item.max_stack_size
	else:
		var new_inventory_item: InventoryItem = load(inventory_item_template).instantiate()
		new_inventory_item.stored_item = new_item
		new_inventory_item.quantity = quantity
		items.append(new_inventory_item)
		emit_signal("item_added", new_inventory_item)
	return 0

func remove_item(item_to_remove: InventoryItem, quantity: int = 1, spawn_pickup: bool = false) -> int:
	var found_item = find_inventory_item(item_to_remove.stored_item)
	print("removing " + item_to_remove.stored_item.item_name)
	if found_item == null:
		print_debug("Cannot remove item " + item_to_remove.stored_item.item_name + ", item not found")
		return -1
	if quantity < 0:
		print_debug("Cannot remove negative number of items")
		return -1
	if quantity > found_item.quantity:
		print_debug("Cannot remove greater item quantity than amount found")
		return -1
	if quantity == found_item.quantity:
		var index = items.find(found_item)
		items.remove_at(index)
		check_space_available()
		emit_signal("item_removed", item_to_remove, spawn_pickup)
		print(index)
	elif found_item.stored_item.stackable && quantity < found_item.quantity:
		print("removing quantity")
		found_item.quantity -= quantity
		found_item.update_quantity_label()
		#emit_signal("item_removed_quantity", item_to_remove, quantity)
	else:
		var index = items.find(found_item)
		items.remove_at(index)
		check_space_available()
		emit_signal("item_removed", item_to_remove, spawn_pickup)
	return 0

func find_item(item_to_find: Item) -> Item:
	if item_to_find == null:
		print_debug("Cannot find null item")
		return null
	for inventory_item in items:
		if inventory_item.stored_item == item_to_find:
			return inventory_item.stored_item
	return null

func find_inventory_item(item_to_find: Item) -> InventoryItem:
	for inventory_item in items:
		if inventory_item.stored_item == item_to_find:
			return inventory_item
	return null

func check_space_available() -> int:
	var total_used_size = 0
	for item in items:
		total_used_size += (item.stored_item.item_size.x * item.stored_item.item_size.y)
	var total_size = inventory_size.x * inventory_size.y
	if total_size == total_used_size:
		inventory_full = true
	else:
		inventory_full = false
	return total_size - total_used_size
