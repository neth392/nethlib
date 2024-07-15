## Container node for [Attribute]s allowing siblings to communicate with each other
## by searching this container for [member Attribute.id].
@tool
class_name AttributeContainer extends Node

signal attribute_added(attribute: Attribute)

signal attribute_removed(attribute: Attribute)

var _attributes: Dictionary = {}

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	child_entered_tree.connect(_on_child_entered_tree)


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	child_entered_tree.disconnect(_on_child_entered_tree)
	_attributes.clear()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	var ids: PackedStringArray = PackedStringArray()
	
	for child: Node in get_children():
		if child is Attribute:
			if child.id.is_empty():
				warnings.append("Child (%s) has no ID set" % child.name)
				continue
			if ids.has(child.id):
				warnings.append("Attributes with duplicate ids found (%s)" % child.id)
			else:
				ids.append(child.id)
		else:
			warnings.append("child (%s) not of type Attribute" % child.name)
	
	if ids.is_empty():
		warnings.append("No valid Attribute children found")
	
	return warnings


func has_attribute_id(id: StringName) -> void:
	return _attributes.has(id)


## Returns the [Attribute] with the specified [member id].
func get_attribute(id: StringName) -> Attribute:
	var weak_ref: WeakRef = _attributes.get(id) as WeakRef
	return weak_ref.get_ref()


func _on_child_entered_tree(child: Node) -> void:
	if child is Attribute:
		assert(!child.id.is_empty(), "child (%s)'s id is empty" % child.name)
		assert(!_attributes.has(child.id), "duplicate Attribute ids found (%s)" % child.id)
		_attributes[child.id] = weakref(child)


func _on_child_exited_tree(child: Node) -> void:
	if child is Attribute:
		_attributes.erase(child.id)
