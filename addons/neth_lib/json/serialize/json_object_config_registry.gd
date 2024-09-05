@tool
class_name JSONObjectConfigRegistry extends Resource

signal configs_changed()

## Configs to be registered to the global [JSONSerializationImpl]. ALL configs
## need to be registered except for those in [member _default_configs] which
## will be registered automatically.
@export var _configs: Array[JSONObjectConfig]:
	set(value):
		_configs = value
		configs_changed.emit()


## Returns true if the [param config] is registered, false if not.
func has_config(config: JSONObjectConfig) -> bool:
	return _configs.has(config)


## Adds the [param config] during runtime, it is not saved unless this
## resource is explicitly saved. Will throw an error if called in the editor.
func add_config(config: JSONObjectConfig) -> void:
	assert(!Engine.is_editor_hint(), "add_config only available at runtime")
	assert(!_configs.has(config), "config (%s) already exists" % config)
	_configs.append(config)
	configs_changed.emit()


func remove_config(config: JSONObjectConfig) -> void:
	_configs.erase(config)
	configs_changed.emit()


## Represents a default [JSONObjectConfig] for a specific class. Used when
## no config is explicitly declared for an [Object]'s instance.
class DefaultConfig extends Resource:
	
	## The class/type that the [member config] is the default of.
	@export_custom(PROPERTY_HINT_TYPE_STRING, &"Object") var for_class: String
	
	## The default config for the [member for_class]
	@export var config: JSONObjectConfig
