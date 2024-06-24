@tool
extends PlatformDetector

func _is_active() -> bool:
	return Engine.has_singleton("Steam")
