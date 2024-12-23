class_name BTSelector extends BTNode

var child_nodes: Array[BTNode]

func _init(nodes: Array[BTNode]) -> void:
	child_nodes = nodes

func evaluate():
	for node in child_nodes:
		var state: BTNodeState = node.evaluate()
		#print("Node running: " + node.to_string())
		match state:
			BTNodeState.FAILED:
				continue
			BTNodeState.RUNNING:
				node_state = BTNodeState.RUNNING
				return node_state
			BTNodeState.SUCCEEDED:
				node_state = BTNodeState.SUCCEEDED
				return node_state
			_:
				continue
	node_state = BTNodeState.FAILED
	return node_state

func _to_string() -> String:
	return "BTSelector"
