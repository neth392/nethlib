## Abstract class to check if an [Attribute] and [AttributeEffectSpec] meets a condition 
## for the spec to be applied.
@tool
class_name AttributeEffectCondition extends Resource

enum BlockType {
	## Blocks the addition of an [AttributeEffect] if conditions are not met.
	ADD,
	## Blocks the processing (duration, period, application, etc) of an [AttributeEffect]
	## if conditions are not met.
	PROCESS,
	## Blocks the application of an [AttributeEffect] if conditions are not met.
	APPLY,
}

## A message explaining why this condition has blocked an [AttributeEffect]
## from being applied.
@export_multiline var message: String

## What features of an [AttributeEffect] should be blocked if conditions are not met.
@export var block_types: Array[BlockType] = []

## If treu
@export var emit_add_blocked_signal: bool = false

@export var emit_apply_blocked_signal: bool = false

## Returns true if the [param attribute] & [param spec] meets the conditions.
func _meets_condition(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	return true


func _validate_property(property: Dictionary) -> void:
	if property.name == "emit_add_blocked_signal":
		if !block_types.has(BlockType.ADD):
			property.usage = PROPERTY_USAGE_STORAGE
	if property.name == "emit_apply_blocked_signal":
		if !block_types.has(BlockType.APPLY):
			property.usage = PROPERTY_USAGE_STORAGE
