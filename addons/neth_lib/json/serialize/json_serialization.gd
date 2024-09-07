## Autoloaded class (named JSONSerialization) responsible for managing [JSONSerializer]s and providing
## serialization & deserialization. See [JSONSerializationImpl] (the implementation) for more information.
@tool
extends JSONSerializationImpl

const _DEFAULT_REGISTRY_PATH: String = "res://json_object_config_registry.tres"

var _registry_setting_path: String = "nethlib/modules/json_object_config_registry"

var _registry_path: String:
	get():
		return ProjectSettings.get_setting(_registry_setting_path, _DEFAULT_REGISTRY_PATH)
	set(value):
		assert(false, "_registry_path is read only")

# Keep a record of the registry path to detect if it changes
var _registry_path_cache: String
var _ignore_setting_change: bool = false


## Constructs a new [JSONSerializationImpl] instance with support for reading errors.
## The returned node should NOT be added to the tree.
func new() -> JSONSerializationImpl:
	# TODO fix this
	var instance: JSONSerializationImpl = JSONSerializationImpl.new()
	instance._serializers = _serializers.duplicate(false)
	instance.indent = indent
	instance.sort_keys = sort_keys
	instance.full_precision = full_precision
	instance.keep_text = keep_text
	instance._color = _color
	instance._vector2 = _vector2
	instance._vector2i = _vector2i
	instance._vector3 = _vector3
	instance._basis = _basis
	instance._vector4 = _vector4
	instance._object = _object
	return instance


func _ready() -> void:
	# Add types confirmed to be working with PrimitiveJSONSerializer
	# see default/primitive_json_serializer_tests.gd for code used to test this
	# Some were omitted as they made no sense; such as Basis which worked but
	# Vector3 didnt, and a Basis is comprised of 3 Vector3s ??? Don't want to risk that
	# getting all fucky wucky in a release build.
	add_serializer(PrimitiveJSONSerializer.new(TYPE_NIL))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_BOOL))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_INT))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_FLOAT))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_STRING))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_STRING_NAME))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_NODE_PATH))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_INT32_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_INT64_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_FLOAT32_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_FLOAT64_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_STRING_ARRAY))
	
	# TYPE_ARRAY
	add_serializer(preload("./native/array_json_serializer.gd").new())
	
	# TYPE_DICTIONARY
	add_serializer(preload("./native/dictionary_json_serializer.gd").new())
	
	# TYPE_OBJECT
	add_serializer(preload("./object/object_json_serializer.gd").new())
	
	# TYPE_COLOR
	_color = preload("./native/color_json_serializer.gd").new()
	add_serializer(_color)
	
	# TYPE_PACKED_COLOR_ARRAY
	add_serializer(preload("./native/packed_color_array_json_serializer.gd").new())
	
	# TYPE_QUARTERNION
	add_serializer(preload("./native/quarternion_json_serializer.gd").new())
	
	# TYPE_VECTOR2
	_vector2 = preload("./native/vector2_json_serializer.gd").new()
	add_serializer(_vector2)
	
	# TYPE_PACKED_VECTOR2_ARRAY
	add_serializer(preload("./native/packed_vector2_array_json_serializer.gd").new())
	
	# TYPE_RECT2
	add_serializer(preload("./native/rect2_json_serializer.gd").new())
	
	# TYPE_TRANSFORM2D
	add_serializer(preload("./native/transform2d_json_serializer.gd").new())
	
	# TYPE_VECTOR2i
	_vector2i = preload("./native/vector2i_json_serializer.gd").new()
	add_serializer(_vector2i)
	
	# TYPE_RECT2i
	add_serializer(preload("./native/rect2i_json_serializer.gd").new())
	
	# TYPE_VECTOR3i
	add_serializer(preload("./native/vector3i_json_serializer.gd").new())
	
	# TYPE_VECTOR3
	_vector3 = preload("./native/vector3_json_serializer.gd").new()
	add_serializer(_vector3)
	
	# TYPE_PACKED_VECTOR3_ARRAY
	add_serializer(preload("./native/packed_vector3_array_json_serializer.gd").new())
	
	# TYPE_PLANE
	add_serializer(preload("./native/plane_json_serializer.gd").new())
	
	# TYPE_BASIS
	_basis = preload("./native/basis_json_serializer.gd").new()
	add_serializer(_basis)
	
	# TYPE_TRANSFORM3D
	add_serializer(preload("./native/transform3d_json_serializer.gd").new())
	
	# TYPE_AABB
	add_serializer(preload("./native/aabb_json_serializer.gd").new())
	
	# TYPE_VECTOR4i
	add_serializer(preload("./native/vector4i_json_serializer.gd").new())
	
	# TYPE_VECTOR4
	_vector4 = preload("./native/vector4_json_serializer.gd").new()
	add_serializer(_vector4)
	
	# TYPE_PACKED_VECTOR4_ARRAY
	add_serializer(preload("./native/packed_vector4_array_json_serializer.gd").new())
	
	# TYPE_PROJECTION
	add_serializer(preload("./native/projection_json_serializer.gd").new())
	
	# In editor; handle ProjectSettings for object config registry
	if Engine.is_editor_hint():
		# Create the setting if it does not exist
		if !ProjectSettings.has_setting(_registry_setting_path):
			ProjectSettings.set_setting(_registry_setting_path, _DEFAULT_REGISTRY_PATH)
		
		# Set the initial values & info for it every time
		ProjectSettings.set_initial_value(_registry_setting_path, _DEFAULT_REGISTRY_PATH)
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
		
		EditorInterface.get_file_system_dock().files_moved.connect(_on_file_moved)
		EditorInterface.get_file_system_dock().file_removed.connect(_on_file_removed)
	
	# Load the registry
	_reload_registry()


# Handle object config registry path changing
func _on_project_settings_changed() -> void:
	if _ignore_setting_change:
		return
	# Check if there was a change, if not return
	if _registry_path == _registry_path_cache:
		return
	_registry_path_cache = _registry_path
	_reload_registry()


# Handle registry being moved in editor
func _on_file_moved(old_file: String, new_file: String) -> void:
	if old_file == _registry_path || new_file == _registry_path:
		_ignore_setting_change = true
		ProjectSettings.set_setting(_registry_setting_path, new_file)
		_registry_path_cache = new_file
		_reload_registry()
		_ignore_setting_change = false


func _on_file_removed(file: String) -> void:
	if file == _registry_path:
		_reload_registry()


# Loads and sets the registry
func _reload_registry() -> void:
	var registry: JSONObjectConfigRegistry = null
	# File exists
	if FileAccess.file_exists(_registry_path):
		registry = ResourceLoader.load(_registry_path) as JSONObjectConfigRegistry
		# Push warning if it couldn't be loaded
		if registry == null:
			push_warning(("JSONObjectConfigRegistry @ path %s could not be loaded or " + \
			"is not of type JSONObjectConfigRegistry") % _registry_path)
	else:
		# File doesn't exist, push warning
		push_warning(("No JSONObjectConfigRegistry file found @ path %s. Ensure project " + \
		"setting nethlib/modules/json_object_config_registry points to a correct file.") \
		% _registry_path)
	
	JSONSerialization.object_config_registry = registry
