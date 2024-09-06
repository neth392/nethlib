@tool
extends NethlibModule

const DEFAULT_REGISTRY_PATH: String = "res://json_object_config_registry.tres"

var _registry_setting_path: String:
	get():
		return setting_path + "_object_config_registry"
	set(value):
		assert(false, "_registry_setting_path is read only")

var _registry_path: String:
	get():
		return ProjectSettings.get_setting(_registry_setting_path)
	set(value):
		assert(false, "_registry_path is read only")

# Keep a record of the registry path to detect if it changes
var _registry_path_cache: String

func _get_name() -> String:
	return "json"


func _enabled(plugin: NethLibPlugin) -> void:
	# Add the autoload
	plugin.add_autoload_singleton("JSONSerialization", "json/serialize/json_serialization.tscn")
	
	# In editor; handle ProjectSettings for object config registry
	if Engine.is_editor_hint():
		# Create the setting if it does not exist
		if !ProjectSettings.has_setting(_registry_setting_path):
			ProjectSettings.set_setting(_registry_setting_path, DEFAULT_REGISTRY_PATH)
		
		# Set the initial values & info for it every time
		ProjectSettings.set_initial_value(_registry_setting_path, DEFAULT_REGISTRY_PATH)
		ProjectSettings.set_as_basic(_registry_setting_path, true)
		ProjectSettings.add_property_info({
			"name": _registry_setting_path,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tres"
		})
		# Cache the registry path to detect changes
		_registry_path_cache = _registry_path
		# Connect to changes
		ProjectSettings.settings_changed.connect(_on_project_settings_changed)
	
	# Load the registry
	JSONSerialization.object_config_registry = _load_registry()


func _disabled(plugin: NethLibPlugin) -> void:
	# Disconnect from ProjectSettings
	if Engine.is_editor_hint():
		ProjectSettings.settings_changed.disconnect(_on_project_settings_changed)
	
	# Remove autoload
	plugin.remove_autoload_singleton("JSONSerialization")


# Handle object config registry path changing
func _on_project_settings_changed() -> void:
	# Check if there was a change, if not return
	if _registry_path == _registry_path_cache:
		return


func _load_registry() -> JSONObjectConfigRegistry:
	# File exists
	if FileAccess.file_exists(_registry_path):
		var registry: JSONObjectConfigRegistry = ResourceLoader.load(_registry_path) \
		as JSONObjectConfigRegistry
		
		# Push warning if it couldn't be loaded
		if registry == null:
			push_warning(("JSONObjectConfigRegistry @ path %s could not be loaded or " + \
			"is not of type JSONObjectConfigRegistry") % _registry_path)
		
		return registry
	
	# File doesn't exist at this point
	
	# In game, push a warning and do nothing
	if !Engine.is_editor_hint():
		push_warning(("No JSONObjectConfigRegistry file found @ path %s. Ensure project " + \
		"setting nethlib/modules/json_object_config_registry points to a correct file.") \
		% _registry_path)
		return null
	
	# In editor, try to create the file
	push_warning(("JSONObjectConfigRegistry @ path %s not found, creating it. To change " + \
	"the path of the file, update the project setting nethlib/modules/json_object_config_registry") \
	% _registry_path)
	
	var registry: JSONObjectConfigRegistry = JSONObjectConfigRegistry.new()
	var result: Error = ResourceSaver.save(registry, _registry_path)
	
	# Couldn't create the file, push error & return null
	if result != OK:
		printerr("Error creating JSONObjectConfigRegistry @ path %s, error code: %s" \
		% [_registry_path, result])
		return null
	
	# File created, return it
	push_warning("JSONObjectConfigRegistry created @ path %s" % _registry_path)
	return registry
