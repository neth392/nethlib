## Utility node that can be added as a child of an [Attribute] to maintain a history
## of all permanent [AttributeEffectSpec]s that have applied. One useful example is 
## retrieving the specific effect that killed a player.[br]
## NOTE: History is updated BEFORE both the [Attribute]'s values are updated and
## [signal Attribute.effect_applied] is emitted. This is useful in cases such as finding
## what effect caused the damage.
@tool
class_name AttributeHistory extends Node

## Emitted when the history is changed, with [param added] being the
## [member AttributeEffectSpec] that was added, and [param removed] being
## the instance that was removed due to [member history_length], or null if
## this history has not yet hit the length.
signal changed(added: AttributeEffectSpec, removed: AttributeEffectSpec)

## Emitted when [member history_length] is changed. [param previous_length] is the
## previous value, and [param removed] are any specs that were removed if the new length
## is less than than the previous size & specs had to be removed.
signal length_changed(previous_length: int, removed: Array[AttributeEffectSpec])

## The maximum amount of [AttributeEffectSpec]s that can be stored. It is important
## to not make this too large of a value as it keeps every [AttributeEffectSpec] stored
## in memory even if that spec was removed from the [Attribute].
@export_range(1, 100, 1, "or_greater", "hide_slider") var history_length: int = 10:
	set(value):
		assert(value > 0, "history_length must be > 0")
		var previous_length: int = history_length
		history_length = value
		var removed: Array[AttributeEffectSpec]
		# Resize if new size is less than current
		if _history.size() > history_length:
			removed = _history.slice(history_length)
			_history.resize(history_length)
		else:
			removed = []
		length_changed.emit(previous_length, removed)

var _history: Array[AttributeEffectSpec] = []

func _ready() -> void:
	assert(get_parent() is Attribute, "parent not of type Attribute")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if !(get_parent() is Attribute):
		warnings.append("parent not of type Attribute")
	return warnings


## Returns a new [Array] (safe to modify) of the latest [AttributeEffectSpec]s 
## applied to the parent [Attribute]. Chronologically ordered by time of applying,
## where the last applied effect is first and previously applied effects are after.
func get_history() -> Array[AttributeEffectSpec]:
	return _history.duplicate(false)


## Returns the last applied [AttributeEffectSpec], or null if none has ever been applied.
func get_last_applied() -> AttributeEffectSpec:
	if _history.is_empty():
		return null
	return _history[0]


## Clears the history.
func clear() -> void:
	_history.clear()


func _add_to_history(spec: AttributeEffectSpec) -> void:
	_history.push_front(spec)
	var removed: AttributeEffectSpec
	if _history.size() > history_length:
		removed = _history.pop_back()
	assert(_history.size() <= history_length, "_history.size() (%s) > history_length (%s)" \
	% [_history.size(), history_length])
	changed.emit(spec, removed)
