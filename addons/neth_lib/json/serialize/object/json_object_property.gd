## A [JSONProperty] implementation that represents a property of [enum Variant.Type.TYPE_OBJECT],
## or any statically typed [Array]s. Eventual support for typed [Dictionary]s will be added
## when that pull request is merged. TODO on that one.
## [br]Requires its own [member config] to know how to serialize the property.
class_name JSONObjectProperty extends JSONProperty

@export var config: ObjectJSONConfiguration
