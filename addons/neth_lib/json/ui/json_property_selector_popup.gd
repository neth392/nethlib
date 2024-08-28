class_name JSONPropertySelectorPopup extends PopupPanel

func init() -> void:
	pass


func parse(node: Node) -> void:
	var script: Variant = node.get_script()
	if script is GDScript:
		for property: Dictionary in script.get_script_property_list():
			pass


func _handle_properties(properties: Array[Dictionary]) -> void:
	for property: Dictionary in properties:
		if is_category(property):
			## TODO handle categories
			pass
		
		if !can_handle_property(property):
			continue


func is_category(property: Dictionary) -> bool:
	return (property.usage & PROPERTY_USAGE_CATEGORY) != 0 


func can_handle_property(property: Dictionary) -> bool:
	# Properties w/ type of NIL are not real properties.
	return property.type != TYPE_NIL && JSONSerialization.is_type_serializable(property.type)
