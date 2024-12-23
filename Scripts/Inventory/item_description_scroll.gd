extends ScrollContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("LookDown"):
		set_v_scroll(get_v_scroll() + 5)
	if Input.is_action_pressed("LookUp"):
		set_v_scroll(get_v_scroll() - 5)
