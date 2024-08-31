## A configuration for an object.
class_name ObjectJSONConfiguration extends Resource

## The [JSONProperty]s that are to be serialized. Properties with [member JSONProperty.enabled]
## as false are ignored. The order of this array is important as it determines in which order
## properties are serialized in.
@export var properties: Array[JSONProperty] = []


## The [JSONObjectInstantiator] used anytime a property of this type is being deserialized
## but the property's assigned value is null. See that class's docs for more info.
@export var instantiator: JSONObjectInstantiator = SmartJSONObjectInstantiator.new()
