## Detects if the associated [Platform] is active. No platform specific code should
## be placed here as it is not guaranteed the platform is active. This is used to
## check if the platform is active.
@tool
class_name PlatformDetector extends RefCounted


## Returns true if the [Platform] is active.
func _is_active() -> bool:
	return false
