## Abstract class meant to be extended.
@tool
class_name ConditionalProvider extends Node

static var _default_caller: Callable = func(predicate: Callable): return predicate.call()

## If true, an error will be thrown if there is no [ConditionalReference]
## that meets the current conditions.
@export var error_on_fail: bool = true

## If true, multiple [ConditionalReference]s can be returned. If false, only
## one can, and an error will be thrown if multiple can't.
@export var allow_multiple: bool = false:
	set(value):
		allow_multiple = value
		if allow_multiple:
			error_on_multiple = false
		notify_property_list_changed()

## If true, an error will be thrown if multiple references have their conditions met.
## If false, the first reference that meets the conditions will be returned. 
## Only used if [member allow_multiple] is false.
@export var error_on_multiple: bool = true


func _validate_property(property: Dictionary) -> void:
	if allow_multiple && property.name == "error_on_multiple":
		property.usage = PROPERTY_USAGE_STORAGE


## Should be overridden to return an [Array] of all [ConditionalReference]s
func _get_references() -> Array:
	return []


## Internal function not to be overridden. [param predicate_caller] is
## a [Callable] that is provided the [member ConditionalReference.predicate] as
## the argument, and should call that callable (with whatever expected params)
## and return the returned value. The returned [Array] contains all [Object](s)
## that meet the conditions. The default value simply calls [member ConditionalReference.predicate]
## with no arguments.
func _provide(predicate_caller: Callable = _default_caller) -> Array[Object]:
	var references: Array = _get_references()
	
	if !allow_multiple && !error_on_multiple:
		references.sort_custom(ConditionalReference.compare)
	
	var valid: Array[Object] = []
	for reference: ConditionalReference in references:
		if predicate_caller.call(reference.predicate):
			if !allow_multiple && !error_on_multiple:
				return [reference._get_object()]
			valid.append(reference._get_object())
	
	# TODO may have to expand on below for better debugging information
	assert(allow_multiple || !error_on_multiple || valid.size() < 2, 
	"multiple references meet condition(s)")
	assert(!error_on_fail || !valid.is_empty(), "no references meet condition(s)")
	
	return valid
