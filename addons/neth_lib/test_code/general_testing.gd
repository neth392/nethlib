extends Node

var nodes: Array[WeakRef] = []

func _ready() -> void:
	var node: Node = Label.new()
	add_child(node)
	nodes.append(weakref(node))
	remove_child(node)
	add_child(node)
	remove_child(node)
	node.queue_free()
	node.tree_exited
	await get_tree().create_timer(5).timeout
	print(nodes[0].get_ref())
