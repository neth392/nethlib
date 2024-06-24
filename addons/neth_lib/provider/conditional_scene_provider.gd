@tool
class_name ConditionalSceneProvider extends ConditionalProvider

static var _on_ready_properties: PackedStringArray = PackedStringArray([
	"on_ready_parent",
	"auto_queue_free",
	"keep_references",
])

@export var conditional_scenes: Array[ConditionalScene] = []

@export_group("On-Ready")

## If true, the [PackedScene] is automatically instantiated and added to the
## scene tree when this node is ready.
@export var add_on_ready: bool = false:
	set(value):
		add_on_ready = value
		if !add_on_ready:
			on_ready_parent = NodePath()
		else:
			update_configuration_warnings()
		notify_property_list_changed()

## The [NodePath] of the parent [Node] to add the instantiated scene under as a child.
@export var on_ready_parent: NodePath:
	set(value):
		on_ready_parent = value
		update_configuration_warnings()

## If true, this instance is automatically removed from the scene tree and free'd
## from memory after the referenced scene is instantiated and added to the tree.
@export var auto_queue_free: bool = true:
	set(value):
		auto_queue_free = value
		update_configuration_warnings()

## Whether or not to keep a [WeakRef] of the instantiated [Node] accessible
## via [method get_instantiated_node]
@export var keep_references: bool = false

var _instantiated_nodes: Array[Node] = []

func _ready() -> void:
	if Engine.is_editor_hint() || !add_on_ready:
		return
	
	assert(on_ready_parent != null && !on_ready_parent.is_empty(),
	"on_ready_parent is null or empty")
	assert(!auto_queue_free || on_ready_parent.get_concatenated_names() != ".", 
	"on_ready_parent path is set to this PackedSceneProvider and will be removed instantly")
	
	var nodes: Array[Node] = instantiate()
	if nodes.is_empty():
		if error_on_fail:
			assert(false, "node == null")
		return
	
	var parent: Node = get_node(on_ready_parent)
	assert(parent != null, "node not found at path %s" % on_ready_parent)
	
	for node: Node in nodes:
		parent.add_child(node)
		if !auto_queue_free && keep_references:
			_instantiated_nodes.append(node)
			node.tree_exiting.connect(_on_node_exiting.bind(node))
	
	if auto_queue_free:
		queue_free()
		return


func _validate_property(property: Dictionary) -> void:
	if !add_on_ready && _on_ready_properties.has(property.name):
		property.usage = PROPERTY_USAGE_NONE


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	
	if add_on_ready:
		if on_ready_parent == null || on_ready_parent.is_empty():
			warnings.append("on_ready_parent null or empty")
		if auto_queue_free && on_ready_parent.get_concatenated_names() == ".":
			warnings.append("on_ready_parent is set to this node's path but it also " +\
			"has auto_queue_free enabled meaning the created node will be removed instantly")
	
	return warnings


## Should be overridden to return an [Array] of all [ConditionalReference]s
func _get_references() -> Array:
	return conditional_scenes


## Provides an [Array] of all [PackedScene]s that met the conditions.
## An empty array is returned if no [ConditionalSceneReference] meets the current 
## conditions.
func provide() -> Array[PackedScene]:
	var scenes: Array[PackedScene] = []
	scenes.assign(_provide())
	return scenes


## Returns an [Array] of the [Node](s) that this [ConditionalSceneProvider] created.
## An empty array is returned if none were created
## It is null if [member add_on_ready] or  [member keep_references] are false, 
## or if there was no [ConditionalSceneReference] that met the conditions.
func get_instantiated_nodes() -> Array[Node]:
	return _instantiated_nodes


## Calls [method provide], and instanatiates all of the returned [PackedScene](s), 
## then returns an [Array] of the created [Node](s). Returns an empty array
## if no scenes were provided.
func instantiate() -> Array[Node]:
	var scenes: Array[PackedScene] = provide()
	var nodes: Array[Node] = []
	for scene: PackedScene in scenes:
		var node: Node = scene.instantiate()
		nodes.append(node)
	return nodes


func _on_node_exiting(node: Node) -> void:
	_instantiated_nodes.erase(node)
