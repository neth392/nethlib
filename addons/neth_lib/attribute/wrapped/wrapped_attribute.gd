## An Attribute implementation that has optional maximum & minimum [Attribute]s which
## determines the range this attribute's current & base values can live within.
@tool
class_name WrappedAttribute extends Attribute

## The value to use of the [Attribute]s for [member minimum] and [member maximum].
enum TrackedValue {
	## [method Attribute.get_current_value] is used as the limit.
	CURRENT_VALUE,
	## [method Attribute.get_base_value] is used as the limit. Do note, this means that temporary
	## effects are essentially ignored.
	BASE_VALUE,
}

## Emitted when [method get_current_value] hits the [member minimum]'s tracked value.
## [param prev_current_value] is the current value before it hit the minimum.
signal current_value_hit_minimum(prev_current_value: float)

## Emitted when [method get_current_value] hits the [member maximum]'s tracked value.
## [param prev_current_value] is the current value before it hit the maximum.
signal current_value_hit_maximum(prev_current_value: float)

## Emitted when [method get_base_value] hits the [member minimum]'s tracked value.
## [param prev_base_value] is the base value before it hit the minimum.
signal base_value_hit_minimum(old_base_vlaue: float)

## Emitted when [method get_base_value] hits the [member maximum]'s tracked value.
## [param prev_base_value] is the base value before it hit the maximum.
signal base_value_hit_maximum(old_base_vlaue: float)

## Emitted when the [member minimum]'s tracked value changes, the [member minimum] instance
## changes to a new [Attribute] with a different value, or is completely removed.
## [br][param had_prev_minimum] is true if there was a minimum previously.
## [br][param prev_minimum] is the previous minimum's value, or 0.0 if there was no previous minimum.
signal minimum_value_changed(had_prev_minimum: bool, prev_minimum: float)

## Emitted when the [member maximum]'s tracked value changes, the [member maximum] instance
## changes to a new [Attribute] with a different value, or is completely removed.
## [br][param had_prev_maximum] is true if there was a maximum previously.
## [br][param prev_maximum] is the previous maximum's value, or 0.0 if there was no previous maximum.
signal maximum_value_changed(had_prev_maximum: bool, prev_maximum: float)

@export_group("Minimum")

## If true, [member minimum] can be null meaning there is no minimum. If false, an assertion
## will be called on [method Node._ready] to ensure it isn't null & an error will
## be thrown if it is set to null during runtime.
@export var allow_null_minimum: bool = true:
	set(value):
		allow_null_minimum = value
		update_configuration_warnings()

## The attribute used as the minimum allowed number, inclusive, for this 
## instance's [member _base_value] and [member _current_value]s.
@export var minimum: Attribute = null:
	set(value):
		# If in editor, set & forget.
		if Engine.is_editor_hint():
			minimum = value
			return
		
		# Assert not null if null not allowed
		assert(allow_null_minimum || value != null, "minimum set to null while " + \
		"allow_null_minimum is false")
		
		# Assert minimum < maximum if neither are null
		if OS.is_debug_build() && value != null && maximum != null:
			assert(value.get_base_value() < maximum.get_base_value(),
			"newly set minimum's base_value (%s) not < maximum's base_value (%s)"
			 % [value.get_base_value(), maximum.get_base_value()])
			assert(value.get_current_value() < maximum.get_current_value(),
			"newly set minimum's current_value (%s) not < maximum's current_value (%s)"
			 % [value.get_base_value(), maximum.get_base_value()])
		
		# Disconnect from old minimum's signals
		if minimum != null:
			SignalUtil.disconnect_safely(minimum.base_value_changed, _on_minimum_base_value_changed)
			SignalUtil.disconnect_safely(minimum.current_value_changed, _on_minimum_current_value_changed)
		
		var prev_minimum: Attribute = minimum
		minimum = value
		# Connect to new minimum's signals
		if is_inside_tree() && minimum != null:
			SignalUtil.connect_safely(minimum.base_value_changed, _on_minimum_base_value_changed)
			SignalUtil.connect_safely(minimum.current_value_changed, _on_minimum_current_value_changed)
		
		# Get the derived values (null or float)
		var new_min_val = null if !has_minimum() else get_minimum_value()
		var prev_min_val = null if prev_minimum == null else \
		_derive_value(prev_minimum, tracked_minimum_value)
		
		# Check if there was a change in the derived values
		if new_min_val != prev_min_val:
			var autowrap_after: BoolRef = BoolRef.new(autowrap_value)
			# Emit minimum signal
			minimum_value_changed.emit(old_minimum != null, old_min_val if old_min_val != null else 0.0,
			autowrap_after)
			# Wrap value.
			_wrap_min(autowrap_after)
		
		update_configuration_warnings()

## Determines which [Attribute] value (current or base) to use when deriving the
## float value of [member minimum].
@export var tracked_minimum_value: TrackedValue = TrackedValue.CURRENT_VALUE

## If true, the [member minimum] is applied to the [member _current_value] as well. If false,
## it is only applied to the [member _base_value] so that temporary [AttributeEffect]s can 
## cause the current value to be less than the minimum.
@export var apply_minimum_to_current_value: bool = true

@export_group("Maximum")

## If true, [member maximum] can be null meaning there is no maximum. If false, an assertion
## will be called on [method Node._ready] to ensure it isn't null & an error will
## be thrown if it is set to null during runtime.
@export var allow_null_maximum: bool = true:
	set(_value):
		allow_null_maximum = _value
		update_configuration_warnings()

## The attribute used as the maximum allowed number, inclusive, for this 
## instance's [member value].
@export var maximum: Attribute = null:
	set(_value):
		# Assertions for out of editor
		if !Engine.is_editor_hint():
			# Assert not null if null not allowed
			assert(!allow_null_maximum || _value != null, "maximum set to null while " + \
			"allow_null_maximum is false")
			# Assert maximum > minimum if neither are null
			if OS.is_debug_build() && (_value != null && minimum != null):
				assert(_value.value > minimum.value, ("newly set maximum value (%s) " + \
				"not < minimum.value (%s)") % [_value.value, minimum.value])
		else:
			# Is in editor, set it and forget
			maximum = _value
			update_configuration_warnings()
			return
		
		# Disconnect from old maximum
		if maximum != null:
			SignalUtil.disconnect_safely(maximum.value_changed, _on_maximum_value_changed)
		
		var old_maximum: Attribute = maximum
		maximum = _value
		# Connect to new maximum
		if is_inside_tree() && maximum != null:
			SignalUtil.connect_safely(maximum.value_changed, _on_maximum_value_changed)
		
		# Check if there was a change
		var new_max_val = null if maximum == null else maximum.value
		var old_max_val = null if old_maximum == null else old_maximum.value
		if new_max_val != old_max_val:
			# Emit minimum signal
			maximum_value_changed.emit(old_maximum != null, old_max_val if old_max_val != null else 0.0,
			autowrap_after)
			# Wrap value.
			_wrap_max(autowrap_after)
		
		update_configuration_warnings()

## Determines which [Attribute] value (current or base) to use when deriving the
## float value of [member minimum].
@export var tracked_maximum_value: TrackedValue = TrackedValue.CURRENT_VALUE

## If true, the [member maximum] is applied to the [member _current_value] as well. If false,
## it is only applied to the [member _base_value] so that temporary [AttributeEffect]s can 
## cause the current value to be greaters than the maximum.
@export var apply_maximum_to_current_value: bool = true

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super._get_configuration_warnings()
	if !allow_null_maximum && maximum == null:
		warnings.append("maximum is null but allow_null_maximum is false")
	if !allow_null_minimum && minimum == null:
		warnings.append("minimum is null but allow_null_minimum is false")
	if minimum != null && maximum != null && maximum.value <= minimum.value:
		warnings.append("maximum.value (%s) not > minimum.value (%s)" \
		% [maximum.value, minimum.value])
	
	if minimum != null && _base_value < get_minimum_value():
		warnings.append("_base_value (%s) is less than minimum's tracked value (%s)"
		% [_base_value, get_minimum_value()])
	elif maximum != null && _base_value > get_maximum_value():
		warnings.append("_base_value (%s) is greater than maximum's tracked value (%s)"
		% [_base_value, get_maximum_value()])
	
	if apply_minimum_to_current_value && minimum != null && _current_value < get_minimum_value():
		warnings.append("_current_value (%s) is less than minimum's tracked value (%s)"
		% [_current_value, get_minimum_value()])
	if apply_maximum_to_current_value && maximum != null && _current_value > get_maximum_value():
		warnings.append("_current_value (%s) is > than maximum's tracked value (%s)"
		% [_current_value, get_maximum_value()])
	
	return warnings


## Returns true if [member maximum] is not null.
func has_minimum() -> bool:
	return minimum != null


## Returns true if [member minimum] is not null.
func has_maximum() -> bool:
	return maximum != null


## Returns true if [method get_current_value] is <= [member minimum]'s value, false if not.
## Also returns false if there is no minimum (see [method has_minimum]).
func is_current_value_minimum() -> bool:
	return _is_minimum(get_current_value())


## Returns true if [method get_base_value] is <= [member minimum]'s value, false if not.
## Also returns false if there is no minimum (see [method has_minimum]).
func is_base_value_minimum() -> bool:
	return _is_minimum(get_base_value())


func _is_minimum(value: float) -> bool:
	if has_minimum():
		return value <= get_minimum_value()
	return false


## Returns true if [method get_current_value] is >= [member maximum]'s value, false if not.
## Also returns false if there is no maximum (see [method has_maximum]).
func is_current_value_maximum() -> bool:
	return _is_maximum(get_current_value())


## Returns true if [method get_base_value] is  >= [member maximum]'s value, false if not.
## Also returns false if there is no maximum (see [method has_maximum]).
func is_base_value_maximum() -> bool:
	return _is_maximum(get_base_value())


func _is_maximum(value: float) -> bool:
	if has_maximum():
		return value >= get_minimum_value()
	return false


## Returns the floating point value of the [member minimum] based on 
## [member tracked_minimum_value]. [method has_minimum] must return true or this
## method throws an error.
func get_minimum_value() -> float:
	assert(has_minimum(), "minimum is null (there is no minimum)")
	return _derive_value(minimum, tracked_minimum_value)


## Returns the floating point value of the [member maximum] based on 
## [member tracked_maximum_value]. [method has_maximum] must return true or this
## method throws an error.
func get_maximum_value() -> float:
	assert(has_maximum(), "maximum is null (there is no maximum)")
	return _derive_value(maximum, tracked_maximum_value)


func _derive_value(attribute: Attribute, tracked: TrackedValue) -> float:
	assert(attribute != null, "attribute is null")
	match tracked:
		TrackedValue.CURRENT_VALUE:
			return attribute.get_current_value()
		TrackedValue.BASE_VALUE:
			return attribute.get_base_value()
		_:
			assert(false, "no implementation for tracked (%s)" % tracked)
			return 0.0


func _validate_base_value(set_value: float) -> float:
	if Engine.is_editor_hint():
		return set_value
	if autowrap_value:
		if maximum != null && set_value > maximum.value:
			return maximum.value
		if minimum != null && set_value < minimum.value:
			return minimum.value
	return set_value


func _base_value_changed(prev_base_value: float) -> void:
	if Engine.is_editor_hint():
		return
	if maximum != null && prev_base_value < maximum.value && value >= maximum.value:
		value_hit_maximum.emit(prev_base_value)
	if minimum != null && prev_base_value > minimum.value && value <= minimum.value:
		value_hit_minimum.emit(prev_base_value)


func _wrap_min(value: float, bool_ref: BoolRef) -> float:
	var derived_minimum: float = get_minimum_value()
	if bool_ref.value && minimum != null && value < derived_minimum:
		return derived_minimum
	else:
		return value


func _wrap_max(value: float, bool_ref: BoolRef) -> float:
	var derived_maximum: float = get_maximum_value()
	if bool_ref.value && maximum != null && value > derived_maximum:
		return derived_maximum
	else:
		return value


func _on_minimum_base_value_changed(prev_minimum_value: float) -> void:
	if tracked_minimum_value != TrackedValue.BASE_VALUE:
		return
	var autowrap_after: BoolRef = BoolRef.new(autowrap_minimum)
	minimum_value_changed.emit(true, old_minimum_value, autowrap_after)
	_wrap_min(autowrap_after)


func _on_minimum_current_value_changed(prev_minimum_value: float) -> void:
	if tracked_minimum_value != TrackedValue.CURRENT_VALUE:
		return
	var autowrap_after: BoolRef = BoolRef.new(autowrap_value)
	minimum_value_changed.emit(true, old_minimum_value, autowrap_after)
	_wrap_min(autowrap_after)


# Handles maximum.value being set, NOT maximum itself.
func _on_maximum_value_changed(old_maximum_value: float) -> void:
	var autowrap_after: BoolRef = BoolRef.new(autowrap_value)
	maximum_value_changed.emit(true, old_maximum_value, autowrap_after)
	_wrap_max(autowrap_after)
