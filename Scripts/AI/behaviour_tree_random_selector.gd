class_name BTRandomSelector extends BTNode

var child_nodes: Array[BTNode]
var child_running: bool = false
var random_node: BTNode

func _init(nodes: Array[BTNode]) -> void:
	child_nodes = nodes

func evaluate():
	if !child_running:
		random_node = child_nodes[randi_range(0, child_nodes.size() - 1)]
		child_running = true
	else:
		var state: BTNodeState = random_node.evaluate()
		match state:
			BTNodeState.FAILED:
				node_state = BTNodeState.FAILED
				child_running = false
			BTNodeState.RUNNING:
				node_state = BTNodeState.RUNNING
			BTNodeState.SUCCEEDED:
				node_state = BTNodeState.SUCCEEDED
				child_running = false
	#print("Random node running: " + random_node.to_string())
	return node_state

func _to_string() -> String:
	return "BTRandomSelector"
