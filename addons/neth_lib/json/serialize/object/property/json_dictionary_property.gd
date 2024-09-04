## A [JSONProperty] implementation that represents a property of [enum Variant.Type.TYPE_DICTIONARY]
## [br]Has optional [param key_config] and [param value_config] to speficy how to serialize & deserialize 
## keys & values if they are [Object]s.
class_name JSONDictionaryProperty extends JSONProperty

## The configuration for a [Dictionary]'s keys if they are [Object]s.
@export var key_config: JSONObjectConfig

## The configuration for a [Dictionary]'s values if they are [Object]s.
@export var value_config: JSONObjectConfig
