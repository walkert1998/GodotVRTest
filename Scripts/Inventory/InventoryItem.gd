class_name InventoryItem extends Node2D

var stored_item: Item
var quantity: int = 1
var grid_position: IntPair
var equipped: bool = false
var selected: bool = false
var item_grid_slots: Array[IntPair] = []
var grid_anchor = null
@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $Icon/QuantityLabel
@onready var hotkey_label: RichTextLabel = $Icon/HotkeyLabel
#@onready var equipped_label: Label = $EquippedLabel

func _ready() -> void:
	icon = get_node("Icon")
	print(icon)

func _process(delta: float) -> void:
	if selected && Input.get_connected_joypads().size() == 0:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

func populate_values(new_item: Item, icon_texture: CompressedTexture2D, quantity: int):
	stored_item = new_item
	icon.texture = icon_texture
	icon.size = Vector2(new_item.item_size.y * icon.custom_minimum_size.x + 5, new_item.item_size.x * icon.custom_minimum_size.y + 5)
	if new_item.stackable:
		quantity_label.text = "x" + str(quantity)
	var pairs = stored_item.item_grid.split("/", false)
	for grid_pos in pairs:
		print(grid_pos)
		var position = grid_pos.split(",")
		print(position)
		var new_grid_slot: IntPair = IntPair.new()
		new_grid_slot.x = int(position[0])
		new_grid_slot.y = int(position[1])
		item_grid_slots.append(new_grid_slot)
	hotkey_label.text = ""

func select():
	selected = true
	icon.modulate.a = 0.5
	quantity_label.hide()
	#hotkey_label.hide()
	#equipped_label.hide()

func de_select():
	icon.modulate.a = 1
	quantity_label.show()
	#hotkey_label.show()
	#equipped_label.show()
	selected = false

func rotate_item():
	for slot in item_grid_slots:
		var temp_y = slot.x
		slot.x = -slot.y
		slot.y = temp_y
	rotation_degrees += 90
	if rotation_degrees >= 360:
		rotation_degrees = 0

func _snap_to(destination: Vector2):
	var tween = get_tree().create_tween()
	print(destination)
	if int(rotation_degrees) % 100 == 0:
		destination = destination
	elif int(rotation_degrees) % 100 == 70:
		destination += Vector2(0, icon.size.x / 2)
	elif int(rotation_degrees) % 100 == 90:
		destination += Vector2(icon.size.y / 2, 0)
	else:
		var temp_xy = Vector2(icon.size.y, icon.size.x)
		destination += temp_xy / 2
	print(destination)
	tween.tween_property(self, "global_position", destination, 0.15).set_trans(Tween.TRANS_SINE)
	de_select()

func update_quantity_label():
	quantity_label.text = "x" + str(quantity)

func set_hotkey_label(slot: int):
	if Input.get_connected_joypads().size() > 0:
		match slot:
			1:
				hotkey_label.text = "[center][img={64}x{64}]res://Textures/ControllerIcons/PS4_Dpad_Up.png[/img][/center]"
			2:
				hotkey_label.text = "[center][img={64}x{64}]res://Textures/ControllerIcons/PS4_Dpad_Left.png[/img][/center]"
			3:
				hotkey_label.text = "[center][img={64}x{64}]res://Textures/ControllerIcons/PS4_Dpad_Right.png[/img][/center]"
			4:
				hotkey_label.text = "[center][img={64}x{64}]res://Textures/ControllerIcons/PS4_Dpad_Down.png[/img][/center]"
			_:
				hotkey_label.text = ""
	else:
		match slot:
			1:
				hotkey_label.text = "[center][1][/center]"
			2:
				hotkey_label.text = "[center][2][/center]"
			3:
				hotkey_label.text = "[center][3][/center]"
			4:
				hotkey_label.text = "[center][4][/center]"
			_:
				hotkey_label.text = ""
