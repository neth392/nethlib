@tool
class_name Attribute extends Node

enum Property {
	VALUE,
}

###################
## Value Signals ##
###################

## Emitted when the attribute value changes. [param old_value] is the value prior to the change.
signal value_changed(old_value: float)


####################
## Effect Signals ##
####################

## Emitted when the [param applied_effect] was applied to this [Attribute]. It may
## or may not be active, see [method AppliedAttributeEffect.is_active]
signal effect_applied(applied_effect: AppliedAttributeEffect)

## Emitted when an [AttributeEffect] that was previously applied was inactive but
## is now active due to meeting previously failed conditions.
signal dormant_effect_activated(applied_effect: AppliedAttributeEffect)

## Emitted when an [AttributeEffect] that was previously applied was active but
## is now inactive due to failing to meet previously met conditions.
signal active_effect_deactivated(applied_effect: AppliedAttributeEffect)

## Emitted when the [param modifier] was removed, either manually or due to expiration.
signal effect_removed(applied_effect: AppliedAttributeEffect)

## The ID of the attribute.
@export var id: String

## The attribute value.
@export var value: float:
	set(_value):
		var old_value: float = _value
		value = _validate_value(_value)
		
		if old_value != value && !Engine.is_editor_hint():
			value_changed.emit(old_value)
		
		_value_changed(old_value)
		
		update_configuration_warnings()
		return true

@export_group("Effects")

## Array of all [AttributeEffect]s.
@export var _default_effects: Array[AttributeEffect] = []

## Whether or not [StaminaEffect]s with a duration should have their duration tick.
@export var tick_effect_durations: bool = true


## Dictionary of applied effects in {[AttributeEffect]:[AppliedAttributeEffect]}
## foramt.
var _effects: Dictionary = {}

func _ready() -> void:
	if Engine.is_editor_hint():
		return


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if _default_effects.has(null):
		warnings.append("_default_effects has a null element")
	return warnings


## Called by the setter of [member value] with [param set_value] (what was manually
## set to [member value]). If the value fails any constraints it can be modified and
## returned, otherwise just return [param set_value].[br]
## Can also be used to emit events as this is [b]only[/b] called in the setter of 
## [member value].
func _validate_value(set_value: float) -> float:
	return set_value


## Called in the setter of [member value] after the new value has been set &
## after [signal value_changed] has been admitted.
func _value_changed(old_value: float) -> void:
	pass


## Returns true if the [AttributeEffect] exists, false if not.
func has_effect(attribute_effect: AttributeEffect) -> bool:
	return _effects.has(attribute_effect)


func is_effect_active(attribute_effect: AttributeEffect) -> bool:
	# TODO
	return false


func add_effect(attribute_effect: AttributeEffect) -> bool:
	# TODO
	return false


func remove_effect(attribute_effect: AttributeEffect) -> bool:
	# TODO
	return false

func get_applied_effect(attribute_effect: AttributeEffect) -> AppliedAttributeEffect:
	# TODO
	return null
