## Utility node that can be added as a child of an [Attribute] to maintain a history
## of all permanent [AttributeEffectSpec]s that have applied. One useful example is 
## retrieving the specific effect that killed a player.[br]
## NOTE: 
@tool
class_name AttributeHistory extends Node

## The maximum amount of [AttributeEffectSpec]s that can be stored.
@export_range(1, 100, 1, "or_greater", "hide_slider") var history_length: int = 10:
	set(value):
		assert(value > 0, "history_length must be > 0")
		history_length = value
		if _history.size() > history_length:
			_history.resize(history_length)

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


func _add_to_history(spec: AttributeEffectSpec) -> void:
	_history.push_front(spec)
	while _history.size() > history_length:
		_history.pop_back()
