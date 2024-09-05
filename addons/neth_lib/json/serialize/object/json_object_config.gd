## A configuration containing specifications on how to serialize & deserialize an
## arbitrary [Object]. Can be reused across objects of multiple types.
## Must be registered to the [JSONSerializationImpl] instance (accessible via
## global/autload class [JSONSerialization]).
@tool
class_name JSONObjectConfig extends Resource

## Emitted when [member id] is changed.
signal id_changed(prev_id: StringName)

## The ID of this [JSONObjectConfig], stored in the serialized data to detect
## how to deserialize an instance of an object.
## [br]WARNING: Changing this property can break existing save data. Set it once
## and keep it the same.
@export var id: StringName:
	set(value):
		var prev_value: StringName = id
		id = value
		if id != prev_value:
			id_changed.emit(prev_value)

## The class this config is meant to parse.
@export_custom(PROPERTY_HINT_TYPE_STRING, &"Object") var for_class: String:
	set(value):
		if set_for_class_by_script != null && !set_for_class_by_script.get_global_name().is_empty():
			for_class = set_for_class_by_script.get_global_name()
		else:
			for_class = value
		_editor_update()
	get():
		if set_for_class_by_script != null && !set_for_class_by_script.get_global_name().is_empty():
			return set_for_class_by_script.get_global_name()
		return for_class


## Sets [member for_class] based on the class_name of this script. Recommended as it
## preserves any name change in the script.
@export var set_for_class_by_script: Script:
	set(value):
		if value == null: # Null script
			set_for_class_by_script = null
			for_class = &""
		elif value != null && value.get_global_name().is_empty(): # Script w/ no name
			push_warning("Can't use this script; no class_name defined for script: %s" % value.resource_path)
			set_for_class_by_script = null
			for_class = &""
		else: # Not null, script w/ name
			set_for_class_by_script = value
		_editor_update()
		notify_property_list_changed()

## The [JSONInstantiator] used anytime an object of this type is being deserialized
## but the property's assigned value is null and thus an instance needs to be created.
## See that class's docs for more info.
@export var instantiator: JSONInstantiator = JSONSmartInstantiator.new()

## Can be set so that the [member properties] of another config are included
## when serializing/deserializing. Useful when creating configs for objects within
## the same class hierarchy.
@export var extend_other_config: JSONObjectConfig 

## The [JSONProperty]s that are to be serialized. Properties with [member JSONProperty.enabled]
## as false are ignored. The order of this array is important as it determines in which order
## properties are serialized in.
## [br]Format: [member JSONProperty.json_key]:[JSONProperty]
@export var properties: Array[JSONProperty]:
	set(value):
		properties = value
		_editor_update()
		notify_property_list_changed()

## A visual property to show you if this config is properly registered in the 
## [JSONObjectConfigRegistry] or not.
var registered: bool:
	get():
		return false
		# TODO fix
		#return JSONSerialization.is_config_registered(self)
	set(value):
		assert(false, "registered is READ ONLY")


func _validate_property(property: Dictionary) -> void:
	# Make registered readonly
	if property.name == "registered":
		property.usage = PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR
	
	# Make for_class read only if set by script
	if property.name == "for_class" && set_for_class_by_script != null:
		property.usage = property.usage | PROPERTY_USAGE_READ_ONLY


func _editor_update() -> void:
	if !Engine.is_editor_hint():
		return
	for property: JSONProperty in properties:
		if property != null:
			property._editor_class_name = for_class


## Returns a new [Array] of all [JSONProperty]s of this instance and [member extend_other_config]
## (if it isn't null).
func get_properties_extended() -> Array[JSONProperty]:
	var extended: Array[JSONProperty] = []
	extended.append_array(properties)
	if extend_other_config != null:
		extended.append_array(extend_other_config.get_properties_extended())
	return extended
