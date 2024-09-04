## A [JSONProperty] implementation that represents a property of [enum Variant.Type.TYPE_OBJECT],
## or any statically typed [Array]s.
## [br]Requires its own [member config] to speficy how to serialize & deserialize the property.
class_name JSONObjectProperty extends JSONProperty

@export var config: JSONObjectConfig
