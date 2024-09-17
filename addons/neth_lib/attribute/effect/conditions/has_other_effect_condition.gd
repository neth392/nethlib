## Condition that checks if other [AttributeEffect]s are present or not on an
## [Attribute].
class_name HasOtherEffectCondition extends AttributeEffectCondition

## How this condition is determined.
enum Mode {
	## Condition is met if the [Attribute] has ALL of the [member other_effect]s.
	HAS_EFFECTS,
	## Condition is met if the [Attribute] does NOT have ANY of the [member other_effect]s.
	DOES_NOT_HAVE_EFFECTS,
}

## The other [AttributeEffect]s to check for the presence of.
@export var other_effects: Array[AttributeEffect]

## See [enum Mode]
@export var mode: Mode


func _meets_condition(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	assert(attribute != null, "attribute is null")
	for effect: AttributeEffect in other_effects:
		var has_effect: bool = attribute.has_effect(effect)
		if has_effect && mode == Mode.DOES_NOT_HAVE_EFFECTS:
			return false
		elif !has_effect && mode == Mode.HAS_EFFECTS:
			return false
	return true
