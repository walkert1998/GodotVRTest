class_name ItemPickup extends Interactable

@export var item: Item
@export var pickup_name: String
@export var quantity: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interact(player: PlayerController):
	var picked_up = player.pickup_item(self)
	if picked_up == 0:
		queue_free()

func get_interact_text() -> String:
	if item.stackable:
		return "Pick Up " + pickup_name + " (x" + str(quantity) + ")"
	return "Pick Up " + pickup_name
