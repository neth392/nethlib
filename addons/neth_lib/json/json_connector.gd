## Provides a direct connection to a [JSONFile].
@tool
class_name JSONConnector extends Node

## Emitted when any [JSONFile] this provider was registered at was loaded & 
## is providing loaded data to [JSONConnector]s.[br]
## The [param value].
signal provided(value: Variant)

## Emitted when any [JSONFile] this provider was registered is fetching data to
## be saved. [param json_fetcher] is a simple data wrapper created uniquely for 
## this [JSONConnector] instance. The value to be saved should be set 
## to [member JSONFetcher.value].
signal fetched(json_fetcher: JSONFetcher)

## The key of the stored value in the root JSON of a [JSONFile]. Used to obtain
## the value sent to [signal provided], and when storing the value
## sent back by [signal fetched].
@export var key: String
