## Provides a connection to a [JSON] file.
class_name JSONConnector extends Node

## Emitted when any [JSONFile] this provider was registered at was loaded.[br]
## The [param variant].
signal provided(variant: Variant)

## TODO a data object that can be set
signal fetched()
