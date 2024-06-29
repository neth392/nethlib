@tool
class_name ConditionalSceneProvider extends ConditionalProvider

static var _auto_instantiate_properties: PackedStringArray = PackedStringArray([
	"add_to_tree",
	"add_to_parent",
	"free_provider_after",
	"keep_references",
	"await_parent_ready"
])

## Emitted for each [Node] instantiated from every [ConditionalSceneReference]
## that met the current conditions. Emitted BEFORE the [param node] is added 
## to the tree. Only emitted if [member instantiate_on_ready] is true.
signal auto_instantiated(node: Node)

## Emitted for each [Node] instantiated from every [ConditionalSceneReference]
## that met the current conditions, AFTER it was added to the tree.
## Only emitted if [member instantiate_on_ready] is true.
signal auto_added_to_tree(node: Node)

@export var conditional_scenes: Array[ConditionalScene] = []:
	set(value):
		conditional_scenes = value if value != null else []

@export_group("Auto-Instantiate")

## If true, the [PackedScene] is automatically instantiated and added to the
## scene tree when this node is ready.
@export var instantiate_on_ready: bool = false:
	set(value):
		instantiate_on_ready = value
		update_configuration_warnings()
		notify_property_list_changed()

## Whether or not to await for the parent [Node] to be ready before
## automatically instantiating the scene(s).
@export var await_parent_ready: bool = false:
	set(value):
		await_parent_ready = value
		update_configuration_warnings()

## If true, this instance is automatically removed from the scene tree and free'd
## from memory after the referenced scene is instantiated and added to the tree.
@export var free_provider_after: bool = false:
	set(value):
		free_provider_after = value
		update_configuration_warnings()

## Whether or not to keep the instantiated [Node]s accessible via
## [method get_instantiated_nodes] after they are instantiated.
@export var keep_instantiated_nodes: bool = false

## If true, the created [Node]s will be added to the tree automatically after
## instantiation.
@export var add_to_tree: bool = false:
	set(value):
		add_to_tree = value
		notify_property_list_changed()
		if !add_to_tree:
			add_to_parent = NodePath()
		else:
			update_configuration_warnings()

## The [NodePath] of the parent [Node] to add the instantiated scene under as a child.
@export var add_to_parent: NodePath = NodePath(): 
	set(value):
		add_to_parent = value
		update_configuration_warnings()

var _instantiated_nodes: Array[WeakRef] = []

func _ready() -> void:
	if Engine.is_editor_hint() || !instantiate_on_ready:
		return
	
	assert(add_to_parent != null && !add_to_parent.is_empty(),
	"add_to_parent is null or empty")
	assert(!add_to_parent || add_to_parent.get_concatenated_names() != ".", 
	"add_to_parent path is set to this PackedSceneProvider and will be removed instantly")
	
	if await_parent_ready:
		push_warning("AWAIT!")
		var parent: Node = get_parent()
		assert(parent != null, "parent is null but await_parent_ready is true")
		if !parent.is_node_ready():
			await parent.ready
	
	var nodes: Array[Node] = instantiate()
	if nodes.is_empty():
		if error_on_fail:
			assert(false, "node == null")
		return
	
	if !free_provider_after && keep_instantiated_nodes:
		for node: Node in nodes:
			_instantiated_nodes.append(weakref(node))
	
	for node: Node in nodes:
		auto_instantiated.emit(node)
	
	if add_to_tree:
		assert(!add_to_parent.is_empty(), "add_to_parent is empty")
		var parent: Node = get_node(add_to_parent)
		assert(parent != null, "node not found at path %s" % add_to_parent)
		
		for node: Node in nodes:
			parent.add_child(node)
			auto_added_to_tree.emit(node)
	
	if free_provider_after:
		queue_free()


func _validate_property(property: Dictionary) -> void:
	if property.name == "add_to_parent":
		if !add_to_tree:
			property.usage = PROPERTY_USAGE_NO_EDITOR
			return
	if !instantiate_on_ready && _auto_instantiate_properties.has(property.name):
		property.usage = PROPERTY_USAGE_NO_EDITOR


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	
	if instantiate_on_ready:
		if free_provider_after && keep_instantiated_nodes:
			warnings.append("free_provider_after & keep_instantiated_nodes are both " +\
			"true, references will not be kept.")
		
		if free_provider_after \
		and (!add_to_parent.is_empty() && add_to_parent.get_concatenated_names() == "."):
			warnings.append("add_to_parent is set to this node's path but it also " +\
			"has free_provider_after enabled meaning the created node will be removed instantly")
		
		if add_to_tree && (add_to_parent == null || add_to_parent.is_empty()):
			warnings.append("add_to_parent is empty")
		
		if await_parent_ready && get_parent() == null:
			warnings.append("await_parent_ready is true but get_parent() returns null")
	
	return warnings


## Should be overridden to return an [Array] of all [ConditionalReference]s
func _get_references() -> Array:
	return conditional_scenes


## Manually provides an [Array] of all [PackedScene]s that met the conditions.
## An empty array is returned if no [ConditionalSceneReference] meets the current 
## conditions.
func provide() -> Array[PackedScene]:
	var scenes: Array[PackedScene] = []
	scenes.assign(_provide())
	return scenes


## Returns an [Array] of the [Node](s) that this [ConditionalSceneProvider] created.
## An empty array is returned if none were created
## It is null if [member add_on_ready] or  [member keep_instantiated_nodes] are false, 
## or if there was no [ConditionalSceneReference] that met the conditions.
func get_instantiated_nodes() -> Array[Node]:
	var nodes: Array[Node] = []
	for ref: WeakRef in _instantiated_nodes:
		if ref.get_ref() is Node:
			nodes.append(ref.get_ref() as Node)
	return nodes


## Manually calls [method provide], and instantiates all of the returned [PackedScene](s), 
## then returns an [Array] of the created [Node](s). Returns an empty array
## if no scenes were provided.
func instantiate() -> Array[Node]:
	var scenes: Array[PackedScene] = provide()
	var nodes: Array[Node] = []
	for scene: PackedScene in scenes:
		var node: Node = scene.instantiate()
		nodes.append(node)
	return nodes
