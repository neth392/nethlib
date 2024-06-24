## A [ConditionalScene] implementation whose [member ConditionalScene.predicate]
## only returns true if the [member platform] is active.
@tool
class_name PlatformScene extends ConditionalScene

## The [PlatformReference] 
@export var platform: PlatformReference = PlatformReference.new():
	set(value):
		if value == null:
			value = PlatformReference.new()
			predicate = func(): return false
		else:
			platform = value
			predicate = func(): return PlatformManager.is_platform_active(value.platform_id)
