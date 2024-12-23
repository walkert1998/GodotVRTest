class_name BTFallThroughSequence extends BTNode

var child_nodes: Array[BTNode]

func _init(nodes: Array[BTNode]) -> void:
	child_nodes = nodes

func evaluate() -> BTNodeState:
	var node_running = false
	if node_state == BTNodeState.SUCCEEDED:
		for node in child_nodes:
			node.reset()
	for node in child_nodes:
		var state = node.evaluate()
		print("Fallthrough node running: " + node.to_string())
		match state:
			BTNodeState.FAILED:
				node_state = BTNodeState.FAILED
				return node_state
			BTNodeState.SUCCEEDED:
				continue
			BTNodeState.RUNNING:
				node_running = true
				node_state = BTNodeState.RUNNING
				return node_state
	node_state = BTNodeState.RUNNING if node_running else BTNodeState.SUCCEEDED
	return node_state

func _to_string() -> String:
	return "BTSequence"
