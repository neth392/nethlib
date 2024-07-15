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

## Emitted when the [param spec] was applied to this [Attribute]. It may
## or may not be active, see [method AttributeEffectSpec.is_active]. If the
## relative [AttributeEffect] is of [enum AttributEffect.DurationType.INSTANT] then
## [method has_effect] will return false for it.
signal effect_applied(spec: AttributeEffectSpec)

## Emitted when an [AttributeEffect] that was previously applied was inactive but
## is now active due to meeting previously failed conditions.
signal dormant_effect_activated(spec: AttributeEffectSpec)

## Emitted when an [AttributeEffect] that was previously applied was active but
## is now inactive due to failing to meet previously met conditions.
signal active_effect_deactivated(spec: AttributeEffectSpec)

## Emitted when the [param spec] was removed, either manually or due to expiration.
signal effect_removed(spec: AttributeEffectSpec)

## The ID of the attribute.
@export var id: StringName

## The attribute value.
@export var value: float:
	set(_value):
		var old_value: float = value
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

## The [AttributeContainer] this attribute belongs to stored as a [WeakRef] for
## circular reference safety.
var _container: WeakRef

## Dictionary of applied effects in {[AttributeEffect]:[AppliedAttributeEffect]}
## foramt.
var _effects: Array[AttributeEffectSpec]


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	assert(get_parent() is AttributeContainer, "parent not of type AttributeContainer")
	_container = weakref(get_parent() as AttributeContainer)


func _ready() -> void:
	if Engine.is_editor_hint():
		return


func _process(delta: float) -> void:
	for spec: AttributeEffectSpec in _effects:
		pass


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_container = null


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if id.is_empty():
		warnings.append("no ID set")
	if !(get_parent() is AttributeContainer):
		warnings.append("parent not of type AttributeContainer")
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


func apply_effect(spec: AttributeEffectSpec) -> bool:
	if spec.get_effect().duration_type == AttributeEffect.DurationType.INSTANT:
		if spec.get_effect().can_apply(self) != null: # TODO should this return bool?
			return false
		value = spec.calculate_value(self)
		effect_applied.emit(spec)
		return true
	
	_effects.append(spec)
	effect_applied.emit(spec)
	return true


## Returns true if the [AttributeEffect] exists, false if not.
func has_effect_spec(spec: AttributeEffectSpec) -> bool:
	return _effects.has(spec)


func remove_effect_spec(spec: AttributeEffectSpec) -> bool:
	var has: bool = _effects.has(spec)
	if has:
		_effects.erase(spec)
	return has


func get_container() -> AttributeContainer:
	return _container.get_ref() as AttributeContainer


func _to_string() -> String:
	return ObjectUtil.to_string_helper("Attribute", self)
