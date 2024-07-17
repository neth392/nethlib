## Condition that checks if an [Attribute], its owner, or its parent 
## is in or not in a specific set of groups.
class_name NodeGroupCondition extends AttributeEffectCondition

## Which node relative to the provided [Attribute] should be checked for the
## group(s)
enum NodeToCheck {
	## The [Attribute] itself is checked.
	ATTRIBUTE,
	## [member Attribute.owner] is checked.
	ATTRIBUTE_OWNER,
	## [method Attribute.get_parent]'s returned [Node] is checked.
	ATTRIBUTE_PARENT,
}

## How this condition is determined.
enum Mode {
	## Condition is met if the [Node] is in ALL of the [member group]s.
	IN_GROUPS,
	## Condition is met if the [Node] is NOT in ANY of the [member group]s.
	NOT_IN_GROUPS,
}

## Which [Node] relative to the [Attribute] should be checked for the groups.
@export var node_to_check: NodeToCheck

## Which groups should be checked.
@export var groups: PackedStringArray

## The mode of this condition, see [enum Mode].
@export var mode: Mode


func _meets_condition(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	assert(attribute != null, "attribute is null")
	if groups.is_empty():
		return true
	var node: Node = _get_node_to_use(attribute)
	if node == null:
		return false
	for group: String in groups:
		var in_group: bool = node.is_in_group(group)
		if in_group && mode == Mode.NOT_IN_GROUPS:
			return false # Node in group but mode is NOT_IN_GROUP
		elif !in_group && mode == Mode.IN_GROUPS:
			return false # Node not in group but mode is IN_GROUP
	return true


func _get_node_to_use(attribute: Attribute) -> Node:
	match node_to_check:
		NodeToCheck.ATTRIBUTE:
			return attribute
		NodeToCheck.ATTRIBUTE_OWNER:
			return attribute.owner
		NodeToCheck.ATTRIBUTE_PARENT:
			return attribute.get_parent()
		_:
			return null
