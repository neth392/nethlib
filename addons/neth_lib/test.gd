@tool
extends Node

@onready var provider: ConditionalSceneProvider = $ConditionalSceneProvider

func _ready():
	provider.auto_instantiated.connect(func (node: Node):
		print("Instantiated: " + str(node.is_node_ready()))
	)
	provider.auto_added_to_tree.connect(func (node: Node):
		print("Added: " + str(node.is_node_ready()))
	)
