## Abstract class that contains a reference to an [Object] and a predicate
## [Callable] which determines if the object is valid in the current environment.
class_name ConditionalReference extends Resource

static func compare(a: ConditionalReference, b: ConditionalReference) -> bool:
	return a.priority > b.priority

## The priority of the reference when compared to others.s
@export var priority: int

## A [Callable] which should return true if this [ConditionalReference] is valid,
## or false if not. Depending on the implementation, there can be parameters.
var predicate: Callable = func(): return false


## Returns the referenced [Object], must be overridden.
func _get_object() -> Object:
	return null


func _to_string() -> String:
	return "ConditionalReference(%s)" % resource_path
