@tool
class_name NethlibModule extends Resource

const SETTING_PREFIX = "nethlib/modules/"

var name: String:
	get():
		return _get_name()
	set(value):
		assert(false, "override _get_name() to change module name")

var dependencies: PackedStringArray:
	get():
		return _get_dependencies()
	set(value):
		assert(false, "override _get_dependencies() to change module dependencies")

var setting_path: String:
	get():
		return SETTING_PREFIX + name
	set(value):
		assert(false, "setting_path is read only")

var _is_enabled: bool = false

func is_enabled() -> bool:
	return _is_enabled


func enable(plugin: NethLibPlugin, print_to_console: bool) -> void:
	_enabled(plugin)
	_is_enabled = true
	if print_to_console:
		push_warning("NethLib: Enabled module %s" % name)


func disable(plugin: NethLibPlugin, print_to_console: bool) -> void:
	_is_enabled = false
	_disabled(plugin)
	if print_to_console:
		push_warning("NethLib: Disabled module %s" % name)


func _get_name() -> String:
	assert(false, "_get_name() not overridden")
	return ""


func _get_dependencies() -> PackedStringArray:
	return PackedStringArray()


func _enabled(plugin: NethLibPlugin) -> void:
	pass


func _disabled(plugin: NethLibPlugin) -> void:
	pass
