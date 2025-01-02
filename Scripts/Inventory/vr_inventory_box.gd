extends Area3D

var items_being_added: Array[XRToolsPickable]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if items_being_added.size() > 0:
		for item in items_being_added:
			if !item.is_picked_up():
				print_debug("Picked up item")
				items_being_added.remove_at(items_being_added.find(item))
				continue


func _on_body_entered(body: Node3D) -> void:
	if body is XRToolsPickable:
		items_being_added.append(body)


func _on_body_exited(body: Node3D) -> void:
	if body is XRToolsPickable:
		if items_being_added.find(body) != -1:
			items_being_added.remove_at(items_being_added.find(body))
