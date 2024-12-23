class_name BTNode

# States
enum BTNodeState {
	FRESH,
	RUNNING,
	FAILED,
	SUCCEEDED,
	CANCELLED
}

var node_state: BTNodeState

func evaluate() -> BTNodeState:
	return node_state

func reset():
	node_state = BTNodeState.RUNNING
