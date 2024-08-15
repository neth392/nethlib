## A condition that will deny an [AttributeEffectSpec] from applying.
class_name WrappedAttributeMaximumCondition extends AttributeEffectCondition

## Returns true if the [param attribute] & [param spec] meets the conditions.
func _meets_condition(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	assert(attribute is WrappedAttribute, "attribute not of type WrappedAttribute")
	
	return true
