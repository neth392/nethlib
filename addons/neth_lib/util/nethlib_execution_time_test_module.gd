extends NethlibModule

func _get_name() -> String:
	return "ExecutionTimeTest"


func _enabled(plugin: NethLibPlugin) -> void:
	if OS.is_debug_build():
		plugin.add_autoload_singleton("ExecutionTimeTest", "util/execution_time_test.tscn")


func _disabled(plugin: NethLibPlugin) -> void:
	if OS.is_debug_build():
		plugin.remove_autoload_singleton("ExecutionTimeTest")
