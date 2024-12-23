class_name WaitForTimeTask extends BTNode

var time_to_wait: float
var timer: SceneTreeTimer

func _init(time: float) -> void:
	time_to_wait = time

func evaluate() -> BTNodeState:
	if timer == null:
		timer = Engine.get_main_loop().create_timer(time_to_wait, false, false, false)
	if timer.time_left <= 0:
		node_state = BTNodeState.SUCCEEDED
		timer = null
		print_debug("TIMER DONE!")
	elif timer.time_left > 0:
		node_state = BTNodeState.RUNNING
		print_debug("Still have  " + str(timer.time_left) + " left.")
	return node_state
