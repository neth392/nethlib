## A registry of all [JSONObjectConfig]s. Create an instance of this file
## in your project's directory and set it's path in Project Settings
## under (nethlib/modules/json_object_config_registry). Add configs to
## [member _configs] so that the JSONSerialization can recognize them.
@tool
class_name JSONObjectConfigRegistry extends Resource

## Configs to be registered to the global [JSONSerializationImpl]. ALL configs
## need to be registered except for those in [member _default_configs] which
## will be registered automatically.
@export var _configs: Array[JSONObjectConfig]:
	set(value):
		_configs = value
		# In game, populate dictionaries
		if !Engine.is_editor_hint():
			# Add to dictionaries
			for config: JSONObjectConfig in _configs:
				if config == null:
					push_warning("_configs has a null element")
					continue
				if config.id.is_empty():
					push_warning("config.id is empty for config %s" % config)
				elif _configs_by_id.has(config.id):
					push_warning("Duplicate config ids found: %s" % config.id)
				else:
					_configs_by_id[config.id] = config
				
				if config.for_class.is_empty():
					push_warning("config.for_class is empty for config %s" % config)
				elif _configs_by_class.has(StringName(config.for_class)):
					push_warning("Duplicate configs for class: %s" % config.for_class)
				else:
					_configs_by_class[StringName(config.for_class)] = config

## [member JSONObjectConfig.id]:[JSONObjectConfig]
var _configs_by_id: Dictionary = {}

## [member JSONObjectConfig.for_class]:[JSONObjectConfig]
var _configs_by_class: Dictionary = {}


## Returns true if the [param config] is registered, false if not.
func has_config(config: JSONObjectConfig) -> bool:
	return _configs.has(config)


## Returns true if a [JSONObjectConfig] with [member JSONObjectConfig.for_class] as [param _class]
## exists, false if not. For use at runtime only, in the editor use [method editor_has_class].
func has_class(_class: StringName) -> bool:
	assert(!Engine.is_editor_hint(), "use editor_has_class() in Editor")
	return _configs_by_class.has(_class)


## Returns true if a [JSONObjectConfig] with [member JSONObjectConfig.for_class] as [param _class]
## exists, false if not. For use in the editor only, at runtime use [method has_class].
func editor_has_class(_class: StringName) -> bool:
	for config: JSONObjectConfig in _configs:
		if config.for_class == _class:
			return true
	return false


## Returns true if a [JSONObjectConfig] with [member JSONObjectConfig.id] as [param id] exists,
## false if not. For use at runtime only, in the editor use [method editor_has_id].
func has_id(id: StringName) -> bool:
	assert(!Engine.is_editor_hint(), "use editor_has_id() in Editor")
	return _configs_by_id.has(id)


## Returns true if a [JSONObjectConfig] with [member JSONObjectConfig.id] as [param id] exists,
## false if not. For use in the editor only, at runtime use [method has_id].
func editor_has_id(id: StringName) -> bool:
	for config: JSONObjectConfig in _configs:
		if config.id == id:
			return true
	return false


## Returns the [JSONObjectConfig] with [member JSONObjectConfig.for_class] of [param _class], 
## or null if one does not exist. For use at runtime only.
func get_config_by_class(_class: StringName) -> JSONObjectConfig:
	assert(!Engine.is_editor_hint(), "get_config_by_class not for use in the Editor")
	return _configs_by_class.get(_class, null)


## Returns the [JSONObjectConfig] with [member JSONObjectConfig.id] of [param id], 
## or null if one does not exist. For use at runtime only.
func get_config_by_id(id: StringName) -> JSONObjectConfig:
	assert(!Engine.is_editor_hint(), "get_config_by_id not avialable in editor")
	return _configs_by_id.get(id, null)


## Adds the [param config] during runtime, it is not saved unless this
## resource is explicitly saved. Will throw an error if called in the editor.
func add_config(config: JSONObjectConfig) -> void:
	assert(!Engine.is_editor_hint(), "add_config not avialable in editor")
	assert(config != null, "config is null")
	assert(!_configs.has(config), "config (%s) already exists" % config)
	assert(!config.id.is_empty(), "config.id empty for config (%s)" % config)
	assert(!_configs_by_id.has(config.id), "config with id (%s) already exists" % config.id)
	assert(!config.for_class.is_empty(), "config.for_class empty for config (%s)" % config)
	assert(!_configs_by_class.has(StringName(config.for_class)), 
	"config for class (%s) already exists" % config.for_class)
	
	_configs.append(config)
	_configs_by_id[config.id] = config
	_configs_by_class[StringName(config.for_class)] = config


## Removes [param config] during runtime, it is not saved unless this
## resource is explicitly saved. Will throw an error if called in the editor.
func remove_config(config: JSONObjectConfig) -> void:
	assert(!Engine.is_editor_hint(), "remove_config not avialable in editor")
	assert(config != null, "config is null")
	_configs.erase(config)
	_configs_by_id.erase(config.id)
	_configs_by_class.erase(StringName(config.for_class))
