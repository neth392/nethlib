## An Attribute implementation that has optional maximum & minimum Attributes.
@tool
class_name WrappedAttribute extends Attribute

## Emitted when value hits the [member minimum]'s value. [param old_value] is 
## the [member value] value before it hit the minimum.
signal value_hit_minimum(old_value: float)

## Emitted when value hits the [member maximum]'s value. [param old_value] is 
## the [member value] value before it hit the minimum.
signal value_hit_maximum(old_value: float)

## Emitted when the [member minimum]'s [member Attribute.value] changes, or the
## [member minimum] instance changes to a new [Attribute] with a different value.[br]
## [param had_old_minimum] is true if there was a minimum previously, and if true
## [param old_minimum] is the old minimum, otherwise it is 0.0.
signal minimum_value_changed(had_old_minimum: bool ,old_minimum: float)

## Emitted when the [member maximum]'s [member Attribute.value] changes, or the
## [member maximum] instance changes to a new [Attribute] with a different value.[br]
## [param had_old_maximum] is true if there was a maximum previously, and if true
## [param old_maximum] is the old maximum, otherwise it is 0.0.
signal maximum_value_changed(had_old_maximum: bool, old_maximum: float)

## If true, [member minimum] can be null meaning there is no minimum. If false, an assertion
## will be called on [method Node._ready] to ensure it isn't null & an error will
## be thrown if it is set to null during runtime.
@export var allow_null_minimum: bool = true:
	set(_value):
		allow_null_minimum = _value
		update_configuration_warnings()

## The attribute used as the minimum allowed number, inclusive, for this 
## instance's [member value].
@export var minimum: Attribute = null:
	set(_value):
		# Assertions for out of editor
		if !Engine.is_editor_hint():
			# Assert not null if null not allowed
			assert(!allow_null_minimum || _value != null, "minimum set to null while " + \
			"allow_null_minimum is false")
			# Assert minimum < maximum if neither are null
			assert(_value == null || maximum == null || _value.value < maximum.value,
			"newly set minimum value (%s) not < maximum.value (%s)" % [_value.value, maximum.value])
		else:
			# Is in editor, set it and forget
			minimum = _value
			return
		
		# Disconnect from old minimum
		if minimum != null:
			SignalUtil.disconnect_safely(minimum.value_changed, _on_minimum_value_changed)
		
		var old_minimum: Attribute = minimum
		minimum = _value
		# Connect to new minimum
		if is_inside_tree() && minimum != null:
			SignalUtil.connect_safely(minimum.value_changed, _on_minimum_value_changed)
		
		# Emit the change
		var new_value = null if minimum == null else minimum.value
		var old_value = null if old_minimum == null else old_minimum.value
		if new_value != old_value:
			minimum_value_changed.emit(old_minimum != null, old_value if old_value != null else 0.0)
		
		update_configuration_warnings()


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
			assert(_value == null || minimum == null || _value.value > minimum.value,
			"newly set maximum value (%s) not < minimum.value (%s)" % [_value.value, minimum.value])
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
		
		# Emit the change
		var new_value = null if maximum == null else maximum.value
		var old_value = null if old_maximum == null else old_maximum.value
		if new_value != old_value:
			maximum_value_changed.emit(old_maximum != null, old_value if old_value != null else 0.0)
		
		update_configuration_warnings()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	SignalUtil.connect_safely(minimum.value_changed, _on_minimum_value_changed)
	SignalUtil.connect_safely(maximum.value_changed, _on_maximum_value_changed)


## Returns true if value is at the minimum.
func is_minimum() -> bool:
	return value <= minimum.value


## Returns true if value is at the maximum.
func is_maximim() -> bool:
	return value >= maximum.value


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super._get_configuration_warnings()
	if !allow_null_maximum && maximum == null:
		warnings.append("maximum is null but allow_null_maximum is false")
	if !allow_null_minimum && minimum == null:
		warnings.append("minimum is null but allow_null_minimum is false")
	if minimum != null && maximum != null && maximum.value <= minimum.value:
		warnings.append("maximum.value (%s) not > minimum.value (%s)" \
		% [maximum.value, minimum.value])
	if minimum != null && value < minimum.value:
		warnings.append("value (%s) is less than minimum.value (%s)" % [value, minimum.value])
	elif maximum != null && value > maximum.value:
		warnings.append("value (%s) is greater than maximum.value (%s)" % [value, maximum.value])
	return warnings


func _validate_value(set_value: float) -> float:
	if Engine.is_editor_hint():
		return set_value
	if maximum != null && set_value > maximum.value:
		return maximum.value
	if minimum != null && set_value < minimum.value:
		return minimum.value
	return set_value


func _value_changed(old_value: float) -> void:
	if Engine.is_editor_hint():
		return
	if maximum != null && old_value < maximum.value && value >= maximum.value:
		value_hit_maximum.emit(old_value)
	if minimum != null && old_value > minimum.value && value <= minimum.value:
		value_hit_minimum.emit(old_value)


func _on_maximum_value_changed(old_maximum_value: float) -> void:
	# TODO: Test if this is works on initialization
	if maximum != null && value > maximum.value:
		value = maximum.value
	maximum_value_changed.emit(true, old_maximum_value)


func _on_minimum_value_changed(old_minimum_value: float) -> void:
	# TODO: Test if this is works on initialization
	if minimum != null && value < minimum.value:
		value = minimum.value
	minimum_value_changed.emit(true, old_minimum_value)
